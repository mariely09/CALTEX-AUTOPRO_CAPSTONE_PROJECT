import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDSS extends StatefulWidget {
  const AdminDSS({super.key});

  @override
  State<AdminDSS> createState() => _AdminDSSState();
}

class _AdminDSSState extends State<AdminDSS> {
  static const _red = Color(0xFFE8001C);
  static const _blue = Color(0xFF003087);
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: _red,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Decision Support System',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: Column(children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(children: [
            _tabBtn('Stock Replenishment', 0),
            _tabBtn('PMS Scheduling', 1),
          ]),
        ),
        Expanded(child: _tab == 0 ? _buildStockDSS() : _buildPMSDSS()),
      ]),
    );
  }

  Widget _tabBtn(String label, int idx) {
    final active = _tab == idx;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _tab = idx),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: active ? _red : Colors.transparent, width: 2))),
        child: Text(label, textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, fontWeight: active ? FontWeight.w700 : FontWeight.normal,
            color: active ? _red : const Color(0xFF718096))),
      ),
    ));
  }

  Widget _buildStockDSS() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('stock_inventory').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data?.docs ?? [];
        final items = docs.map((d) {
          final data = d.data() as Map<String, dynamic>;
          final stock = (data['stock'] as num?)?.toInt() ?? 0;
          final min = (data['min'] as num?)?.toInt() ?? 0;
          final reorder = (data['reorder'] as num?)?.toInt() ?? 0;
          final uom = data['uom'] as String? ?? '';
          final isCritical = stock <= min;
          // Estimate days left: assume consumption = reorder/30 per day if reorder set, else 1/day
          final dailyRate = reorder > 0 ? reorder / 30.0 : 1.0;
          final daysLeft = dailyRate > 0 ? (stock / dailyRate).round() : 999;
          final orderQty = reorder > 0 ? '$reorder $uom' : '—';
          return {
            'name': data['name'] as String? ?? '—',
            'stock': '$stock $uom',
            'days': daysLeft < 999 ? '$daysLeft days' : '—',
            'order': orderQty,
            'priority': isCritical ? 'Critical' : 'OK',
            'group': data['group'] as String? ?? '—',
            'consumptionRate': dailyRate > 0 ? '${dailyRate.toStringAsFixed(1)} $uom/day' : '—',
          };
        }).toList()
          ..sort((a, b) {
            if (a['priority'] == 'Critical' && b['priority'] != 'Critical') return -1;
            if (a['priority'] != 'Critical' && b['priority'] == 'Critical') return 1;
            return 0;
          });

        return _buildStockDSSContent(items);
      },
    );
  }

  Widget _buildStockDSSContent(List<Map<String, String>> items) {

    return Column(children: [
      Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Stock Replenishment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1a202c))),
              Text('Inventory replenishment recommendations', style: TextStyle(fontSize: 12, color: Color(0xFF718096))),
            ]),
            IconButton(
              onPressed: () => _printCriticalItems(items),
              icon: const Icon(Icons.print_outlined, color: _red),
              tooltip: 'Print Critical Items',
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _kpiChip('Total Items', '${items.length}', _blue),
            const SizedBox(width: 8),
            _kpiChip('Critical', '${items.where((i) => i['priority'] == 'Critical').length}', _red),
            const SizedBox(width: 8),
            _kpiChip('Adequate', '${items.where((i) => i['priority'] == 'OK').length}', _blue),
          ]),
        ]),
      ),
      Expanded(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final item = items[i];
            final isCritical = item['priority'] == 'Critical';
            final color = isCritical ? _red : _blue;
            return GestureDetector(
              onTap: () => _showStockDetails(item),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: isCritical ? Border.all(color: _red.withOpacity(0.25)) : null,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Row(children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                            child: Icon(Icons.inventory_2_outlined, color: color, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(item['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(item['group']!, style: const TextStyle(fontSize: 11, color: Color(0xFF718096))),
                          ]),
                        ]),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                          child: Text(item['priority']!, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700)),
                        ),
                      ]),
                      const SizedBox(height: 14),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(children: [
                        _infoBox(Icons.inventory_outlined, 'Stock', item['stock']!, const Color(0xFF003087), const Color(0xFFebf8ff)),
                        const SizedBox(width: 6),
                        _infoBox(Icons.trending_down_outlined, 'Consumption', item['consumptionRate']!, const Color(0xFFE8001C), const Color(0xFFfff5f5)),
                        const SizedBox(width: 6),
                        _infoBox(Icons.schedule_outlined, 'Days Left', item['days']!, const Color(0xFFdd6b20), const Color(0xFFfffaf0)),
                        const SizedBox(width: 6),
                        _infoBox(Icons.shopping_cart_outlined, 'Order Qty', item['order']!, const Color(0xFF2c7a7b), const Color(0xFFe6fffa)),
                      ]),
                    ]),
                  ),
                ]),
              ),
            );
          },
        ),
      ),
    ]);
  }

  Future<void> _printCriticalItems(List<Map<String, String>> items) async {
    final critical = items.where((i) => i['priority'] == 'Critical').toList();
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr = '${now.day.toString().padLeft(2,'0')}/${now.month.toString().padLeft(2,'0')}/${now.year}';

    // Load logo
    final logoBytes = await rootBundle.load('assets/img/LOGO_CALTEX.png');
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    final letterBytes = await rootBundle.load('assets/img/CALTEX_LETTER.png');
    final letterImage = pw.MemoryImage(letterBytes.buffer.asUint8List());

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
      build: (pw.Context ctx) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // ── Header ──
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Row(children: [
                  pw.Image(logoImage, width: 44, height: 44),
                  pw.SizedBox(width: 10),
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    pw.Image(letterImage, height: 18),
                    pw.SizedBox(height: 2),
                    pw.Text('AutoPro Fleet Management',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                  ]),
                ]),
                pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
                  pw.Text('Stock Replenishment Report',
                    style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold,
                      color: const PdfColor.fromInt(0xFF1a202c))),
                  pw.SizedBox(height: 2),
                  pw.Text('Date Generated: $dateStr',
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                ]),
              ],
            ),
            pw.SizedBox(height: 6),
            pw.Divider(color: const PdfColor.fromInt(0xFFE8001C), thickness: 1.5),
            pw.SizedBox(height: 16),

            // ── Report Title ──
            pw.Text('Critical Stock Items — Immediate Reorder Required',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold,
                color: const PdfColor.fromInt(0xFF1a202c))),
            pw.SizedBox(height: 4),
            pw.Text(
              'The following ${critical.length} item(s) have critically low stock levels and require immediate procurement action.',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 18),

            // ── Table ──
            pw.Table(
              border: pw.TableBorder(
                top: const pw.BorderSide(color: PdfColor.fromInt(0xFF003087), width: 1.5),
                bottom: const pw.BorderSide(color: PdfColor.fromInt(0xFF003087), width: 1.5),
                horizontalInside: const pw.BorderSide(color: PdfColors.grey300, width: 0.5),
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(2),
              },
              children: [
                // Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF003087)),
                  children: ['Item Name', 'Commodity Group', 'Recommended Order Qty']
                    .map((h) => pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                      child: pw.Text(h,
                        style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9,
                          letterSpacing: 0.3)),
                    )).toList(),
                ),
                // Rows
                ...critical.asMap().entries.map((e) {
                  final item = e.value;
                  final isEven = e.key % 2 == 0;
                  return pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: isEven ? PdfColors.white : const PdfColor.fromInt(0xFFF7F8FA),
                    ),
                    children: [item['name']!, item['group']!, item['order']!]
                      .asMap().entries.map((ce) => pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                        child: pw.Text(ce.value,
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: ce.key == 2 ? pw.FontWeight.bold : pw.FontWeight.normal,
                            color: ce.key == 2
                              ? const PdfColor.fromInt(0xFFE8001C)
                              : const PdfColor.fromInt(0xFF1a202c),
                          )),
                      )).toList(),
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 20),

            // ── Note ──
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: pw.BoxDecoration(
                border: pw.Border(left: const pw.BorderSide(color: PdfColor.fromInt(0xFFE8001C), width: 3)),
                color: const PdfColor.fromInt(0xFFFFF5F5),
              ),
              child: pw.Text(
                'Note: Items listed above are critically low. Immediate reordering is recommended to avoid service disruption.',
                style: const pw.TextStyle(fontSize: 8.5, color: PdfColor.fromInt(0xFF4a5568)),
              ),
            ),

            pw.Spacer(),

            // ── Footer ──
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Caltex AutoPro — Decision Support System',
                  style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey500)),
                pw.Text('Page 1 of 1  •  $dateStr',
                  style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey500)),
              ],
            ),
          ],
        );
      },
    ));

    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }

  pw.Widget _pdfChip(String label, String value, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(value, style: pw.TextStyle(color: PdfColors.white, fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.Text(label, style: const pw.TextStyle(color: PdfColors.grey300, fontSize: 9)),
      ]),
    );
  }

  void _showStockDetails(Map<String, String> item) {
    final isCritical = item['priority'] == 'Critical';
    final color = isCritical ? _red : _blue;
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        expand: false, initialChildSize: 0.55, maxChildSize: 0.8,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          child: Column(children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
              child: Row(children: [
                Container(width: 44, height: 44,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 22)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item['name']!, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(item['group'] ?? '—', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ])),
                GestureDetector(onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFe2e8f0))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('📦  STOCK INFO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF718096), letterSpacing: 0.5)),
                    const SizedBox(height: 12),
                    _detailRow('Item Name', item['name']!),
                    _detailRow('Commodity Group', item['group']!),
                    _detailRow('Priority', item['priority']!),
                  ]),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFe2e8f0))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('📊  ANALYSIS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF718096), letterSpacing: 0.5)),
                    const SizedBox(height: 12),
                    Row(children: [
                      _statBox('Current Stock', item['stock']!, const Color(0xFFebf8ff), const Color(0xFF003087)),
                      const SizedBox(width: 8),
                      _statBox('Consumption', item['consumptionRate']!, const Color(0xFFfff5f5), const Color(0xFFE8001C)),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      _statBox('Days Left', item['days']!, const Color(0xFFfffaf0), const Color(0xFFdd6b20)),
                      const SizedBox(width: 8),
                      _statBox('Order Qty', item['order']!, const Color(0xFFe6fffa), const Color(0xFF2c7a7b)),
                    ]),
                  ]),
                ),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('Close'),
                  )),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildPMSDSS() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('vehicles').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data?.docs ?? [];
        final now = DateTime.now();
        final assets = docs.map((d) {
          final data = d.data() as Map<String, dynamic>;
          final plate = data['plate'] as String? ?? '';
          final desc = data['desc'] as String? ?? '';
          final lastSvcDate = data['lastSvcDate'] as String? ?? '';
          final svcFreq = data['svcFreq'] as String? ?? '';
          final lastDate = DateTime.tryParse(lastSvcDate);
          final months = int.tryParse(svcFreq);

          String due = '—';
          String priority = 'On Track';
          String nextPMS = '—';
          String lastService = lastSvcDate.isNotEmpty ? lastSvcDate : '—';

          if (lastDate != null && months != null) {
            final next = DateTime(lastDate.year, lastDate.month + months, lastDate.day);
            nextPMS = '${next.year}-${next.month.toString().padLeft(2,'0')}-${next.day.toString().padLeft(2,'0')}';
            final daysUntil = next.difference(now).inDays;
            if (daysUntil < 0) {
              due = 'Overdue ${(-daysUntil)} days';
              priority = 'Overdue';
            } else if (daysUntil <= 30) {
              due = 'Due in $daysUntil days';
              priority = 'Due Soon';
            } else {
              due = 'Due in ${(daysUntil / 30).round()} month(s)';
              priority = 'On Track';
            }
          }

          return {
            'plate': plate,
            'desc': desc,
            'due': due,
            'priority': priority,
            'lastService': lastService,
            'nextPMS': nextPMS,
          };
        }).toList()
          ..sort((a, b) {
            const order = {'Overdue': 0, 'Due Soon': 1, 'On Track': 2};
            return (order[a['priority']] ?? 3).compareTo(order[b['priority']] ?? 3);
          });

        return _buildPMSDSSContent(assets);
      },
    );
  }

  Widget _buildPMSDSSContent(List<Map<String, String>> assets) {
    return Column(children: [
      Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const Text('PMS Scheduling', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1a202c))),
          const Text('Preventive maintenance schedule recommendations', style: TextStyle(fontSize: 12, color: Color(0xFF718096))),
          const SizedBox(height: 12),
          Row(children: [
            _kpiChip('Total', '${assets.length}', _blue),
            const SizedBox(width: 8),
            _kpiChip('Overdue', '${assets.where((a) => a['priority'] == 'Overdue').length}', _red),
            const SizedBox(width: 8),
            _kpiChip('On Track', '${assets.where((a) => a['priority'] == 'On Track').length}', _blue),
          ]),
        ]),
      ),
      Expanded(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: assets.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final a = assets[i];
            final color = a['priority'] == 'Overdue' ? _red
                : a['priority'] == 'Due Soon' ? Colors.orange
                : _blue;
            return GestureDetector(
              onTap: () => _showPMSDetails(a),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: Icon(Icons.directions_car_outlined, color: color, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(a['plate']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(a['desc']!, style: const TextStyle(fontSize: 12, color: Color(0xFF4a5568))),
                        const SizedBox(height: 4),
                        Row(children: [
                          Icon(Icons.schedule_outlined, size: 12, color: color),
                          const SizedBox(width: 4),
                          Text(a['due']!, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
                        ]),
                      ])),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                        child: Text(a['priority']!, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700)),
                      ),
                    ]),
                  ),
                ]),
              ),
            );
          },
        ),
      ),
    ]);
  }

  void _showPMSDetails(Map<String, String> a) {
    final color = a['priority'] == 'Overdue' ? _red
        : a['priority'] == 'Due Soon' ? Colors.orange
        : _blue;
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        expand: false, initialChildSize: 0.55, maxChildSize: 0.8,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          child: Column(children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
              child: Row(children: [
                Container(width: 44, height: 44,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.directions_car_outlined, color: Colors.white, size: 22)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(a['plate']!, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(a['desc']!, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ])),
                GestureDetector(onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFe2e8f0))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('🚗  VEHICLE INFO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF718096), letterSpacing: 0.5)),
                    const SizedBox(height: 12),
                    _detailRow('Plate Number', a['plate']!),
                    _detailRow('Description', a['desc']!),
                    _detailRow('Priority', a['priority']!),
                    _detailRow('Status', a['due']!),
                  ]),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFe2e8f0))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('🔧  MAINTENANCE SCHEDULE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF718096), letterSpacing: 0.5)),
                    const SizedBox(height: 12),
                    Row(children: [
                      _statBox('Last Service', a['lastService']!, const Color(0xFFF7F8FA), const Color(0xFF1a202c)),
                      const SizedBox(width: 8),
                      _statBox('Next PMS Due', a['nextPMS']!, color.withOpacity(0.08), color),
                    ]),
                  ]),
                ),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('Close'),
                  )),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 130, child: Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF718096), fontWeight: FontWeight.w600))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1a202c)))),
      ]),
    );
  }

  Widget _statBox(String label, String value, Color bg, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
        child: Column(children: [
          Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF718096), fontWeight: FontWeight.w700), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: valueColor), textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  Widget _infoBox(IconData icon, String label, String value, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
        child: Column(children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF718096)), textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  Widget _kpiChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: const Color(0xFFF7F8FA), borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2))),
        child: Column(children: [
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF718096))),
        ]),
      ),
    );
  }

  Widget _dssInfo(String label, String value) {
    return Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF718096))),
      Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    ]));
  }
}
