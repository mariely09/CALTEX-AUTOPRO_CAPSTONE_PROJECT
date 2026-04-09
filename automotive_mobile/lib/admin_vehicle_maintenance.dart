import 'package:flutter/material.dart';
import 'barcode_scanner_screen.dart';

class AdminVehicleMaintenance extends StatefulWidget {
  const AdminVehicleMaintenance({super.key});

  @override
  State<AdminVehicleMaintenance> createState() => _AdminVehicleMaintenanceState();
}

class _AdminVehicleMaintenanceState extends State<AdminVehicleMaintenance> {
  static const _red = Color(0xFFE8001C);

  // Service items — synced from Item Master (type: Service)
  static const _serviceItems = [
    'Oil Change Service',
  ];

  // Service item master with UOM and cost — synced from Item Master
  static const _serviceItemData = {
    'Oil Change Service': {'uom': 'job', 'cost': '500'},
  };

  // Material items — synced from Item Master (type: Material)
  static const _materialItems = [
    'Engine Oil 10W-40', 'Oil Filter', 'Brake Pads',
  ];

  // Item master with UOM and cost for auto-fill — synced from Item Master
  static const _itemMasterData = {
    'Engine Oil 10W-40': {'uom': 'L',   'cost': '450',  'barcode': '1234567890', 'qr': 'QR-ITM-001'},
    'Oil Filter':        {'uom': 'pcs', 'cost': '180',  'barcode': '0987654321', 'qr': 'QR-ITM-002'},
    'Brake Pads':        {'uom': 'set', 'cost': '1200', 'barcode': '1122334455', 'qr': 'QR-ITM-003'},
  };

  static const _vehicles = {
    'ABC-1234': {'desc': 'Isuzu Truck NQR 2021', 'owner': 'Juan Dela Cruz', 'type': 'Truck'},
    'XYZ-5678': {'desc': 'Toyota Hilux 2020', 'owner': 'Pedro Santos', 'type': 'Car'},
    'DEF-9012': {'desc': 'Mitsubishi L300 2019', 'owner': 'Jose Reyes', 'type': 'Truck'},
  };

  final List<Map<String, String>> _services = [
    {'id': 'SVC-001', 'plate': 'ABC-1234', 'desc': 'Isuzu Truck NQR 2021', 'mechanic': 'Juan Dela Cruz', 'date': 'Mar 28, 2026', 'cost': '₱2,500', 'status': 'Completed'},
    {'id': 'SVC-002', 'plate': 'XYZ-5678', 'desc': 'Toyota Hilux 2020', 'mechanic': 'Pedro Santos', 'date': 'Mar 28, 2026', 'cost': '₱1,800', 'status': 'Ongoing'},
    {'id': 'SVC-003', 'plate': 'DEF-9012', 'desc': 'Mitsubishi L300 2019', 'mechanic': 'Jose Reyes', 'date': 'Mar 27, 2026', 'cost': '₱3,200', 'status': 'Pending'},
  ];

  // Stores services rendered rows per service id: { 'SVC-001': [{'name':..,'qty':..,'uom':..,'cost':..}] }
  final Map<String, List<Map<String, String>>> _svcRowsData = {};
  final Map<String, List<Map<String, String>>> _matRowsData = {};

  List<Map<String, String>> _filtered = [];
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = List.from(_services);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String q) {
    setState(() {
      _filtered = _services.where((s) =>
        s['id']!.toLowerCase().contains(q.toLowerCase()) ||
        s['plate']!.toLowerCase().contains(q.toLowerCase()) ||
        s['mechanic']!.toLowerCase().contains(q.toLowerCase())
      ).toList();
    });
  }

  Color _statusColor(String status) {
    if (status == 'Completed') return Colors.green;
    if (status == 'Ongoing') return Colors.orange;
    return const Color(0xFF718096);
  }

  bool _searching = false;

  @override
  Widget build(BuildContext context) {
    final total = _services.length;
    final ongoing = _services.where((s) => s['status'] == 'Ongoing').length;
    final completed = _services.where((s) => s['status'] == 'Completed').length;
    final pending = _services.where((s) => s['status'] == 'Pending').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddServiceModal(),
        backgroundColor: _red,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      appBar: AppBar(
        backgroundColor: _red,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: _searching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                onChanged: _onSearch,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search services...',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
              )
            : const Text('Vehicle Maintenance',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_searching ? Icons.close : Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                _searching = !_searching;
                if (!_searching) {
                  _searchCtrl.clear();
                  _filtered = List.from(_services);
                }
              });
            },
          ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(children: [
            _statChip('Total', '$total', Colors.blue),
            const SizedBox(width: 8),
            _statChip('Ongoing', '$ongoing', Colors.orange),
            const SizedBox(width: 8),
            _statChip('Completed', '$completed', Colors.green),
            const SizedBox(width: 8),
            _statChip('Pending', '$pending', const Color(0xFF718096)),
          ]),
        ),
        Expanded(
          child: _filtered.isEmpty
            ? const Center(child: Text('No services found.', style: TextStyle(color: Color(0xFF718096))))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _serviceCard(_filtered[i]),
              ),
        ),
      ]),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
        child: Column(children: [
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF718096))),
        ]),
      ),
    );
  }

  Widget _serviceCard(Map<String, String> s) {
    final sc = _statusColor(s['status']!);
    return GestureDetector(
      onTap: () => _showServiceDetails(s),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
        child: Row(children: [
          Container(width: 44, height: 44,
            decoration: BoxDecoration(color: const Color(0xFFF0F4FF), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.build_outlined, color: _red, size: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s['plate']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(s['desc']!.isNotEmpty ? s['desc']! : s['plate']!, style: const TextStyle(fontSize: 12, color: Color(0xFF4a5568))),
            Text('${s['mechanic']} • ${s['date']}', style: const TextStyle(fontSize: 11, color: Color(0xFF718096))),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(s['cost']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: sc.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(s['status']!, style: TextStyle(fontSize: 10, color: sc, fontWeight: FontWeight.w600)),
            ),
          ]),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 18, color: Color(0xFF718096)),
            onSelected: (val) {
              if (val == 'edit') _showAddServiceModal(service: s);
              if (val == 'delete') _confirmDelete(s);
            },
            itemBuilder: (_) => [
              if (s['status'] != 'Completed')
                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 16), SizedBox(width: 8), Text('Edit')])),
              const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 16, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
            ],
          ),
        ]),
      ),
    );
  }

  void _showServiceDetails(Map<String, String> s) {
    final sc = _statusColor(s['status']!);
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        expand: false, initialChildSize: 0.6, maxChildSize: 0.85,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          child: Column(children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              decoration: const BoxDecoration(color: _red, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
              child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Container(width: 44, height: 44,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.build_outlined, color: Colors.white, size: 22)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s['plate']!, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(s['desc'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ])),
                GestureDetector(onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _detailRow('Plate Number', s['plate'] ?? '—'),
                _detailRow('Mechanic', s['mechanic'] ?? '—'),
                _detailRow('Date Serviced', s['date'] ?? '—'),
                _detailRow('Total Cost', s['cost'] ?? '—'),
                Row(children: [
                  const SizedBox(width: 130, child: Text('Status', style: TextStyle(fontSize: 12, color: Color(0xFF718096), fontWeight: FontWeight.w500))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: sc.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text(s['status']!, style: TextStyle(fontSize: 12, color: sc, fontWeight: FontWeight.w600)),
                  ),
                ]),
                const SizedBox(height: 16),
                if (s['status'] == 'Pending') ...[
                  SizedBox(width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Approve Service'),
                            content: Text('Approve "${s['plate']}" and set status to Ongoing?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Approve', style: TextStyle(color: Colors.orange)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          setState(() {
                            final idx = _services.indexWhere((e) => e['id'] == s['id']);
                            if (idx != -1) {
                              _services[idx] = Map.from(_services[idx])..['status'] = 'Ongoing';
                              _filtered = List.from(_services);
                            }
                            s['status'] = 'Ongoing';
                          });
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 16),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                    )),
                  const SizedBox(height: 8),
                ],
                if (s['status'] == 'Ongoing') ...[
                  SizedBox(width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Complete Service'),
                            content: Text('Mark "${s['plate']}" as Completed?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Complete', style: TextStyle(color: Colors.green)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          setState(() {
                            final idx = _services.indexWhere((e) => e['id'] == s['id']);
                            if (idx != -1) {
                              _services[idx] = Map.from(_services[idx])..['status'] = 'Completed';
                              _filtered = List.from(_services);
                            }
                            s['status'] = 'Completed';
                          });
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.done_all, size: 16),
                      label: const Text('Mark as Completed'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    )),
                  const SizedBox(height: 8),
                ],
                if (s['status'] != 'Completed')
                  SizedBox(width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () { Navigator.pop(context); _showAddServiceModal(service: s); },
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Edit'),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 130, child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF718096), fontWeight: FontWeight.w500))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1a202c)))),
      ]),
    );
  }

  void _showAddServiceModal({Map<String, String>? service}) {
    final isEdit = service != null;
    final plateCtrl = TextEditingController(text: service?['plate'] ?? '');
    final mechanicCtrl = TextEditingController(text: service?['mechanic'] ?? '');
    final dateCtrl = TextEditingController(text: service?['date'] ?? '');

    Map<String, String>? foundVehicle = isEdit ? _vehicles[service!['plate']] : null;

    // Pre-populate rows from saved data when editing
    List<Map<String, TextEditingController>> _makeRows(List<Map<String, String>>? saved) {
      if (saved != null && saved.isNotEmpty) {
        return saved.map((r) => {
          'name': TextEditingController(text: r['name'] ?? ''),
          'qty':  TextEditingController(text: r['qty']  ?? ''),
          'uom':  TextEditingController(text: r['uom']  ?? ''),
          'cost': TextEditingController(text: r['cost'] ?? ''),
        }).toList();
      }
      return [{'name': TextEditingController(), 'qty': TextEditingController(), 'uom': TextEditingController(), 'cost': TextEditingController()}];
    }

    final String? editId = service?['id'];
    final List<Map<String, TextEditingController>> svcRows = _makeRows(isEdit ? _svcRowsData[editId] : null);
    final List<Map<String, TextEditingController>> matRows = _makeRows(isEdit ? _matRowsData[editId] : null);

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) {
          double totalCost() {
            double t = 0;
            for (final r in [...svcRows, ...matRows]) {
              t += (double.tryParse(r['cost']!.text) ?? 0) * (double.tryParse(r['qty']!.text) ?? 0);
            }
            return t;
          }

          return DraggableScrollableSheet(
            expand: false, initialChildSize: 0.92, maxChildSize: 0.97,
            builder: (_, ctrl) => SingleChildScrollView(
              controller: ctrl,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  decoration: const BoxDecoration(color: _red, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Container(width: 44, height: 44,
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                      child: Icon(isEdit ? Icons.edit_outlined : Icons.add, color: Colors.white, size: 22)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(isEdit ? 'Edit Service' : 'New Service',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                    GestureDetector(onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: Colors.white)),
                  ]),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, top: 20,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Plate Number *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4a5568))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: plateCtrl,
                      textCapitalization: TextCapitalization.characters,
                      onChanged: (v) => setModal(() => foundVehicle = _vehicles[v.trim().toUpperCase()]),
                      decoration: InputDecoration(
                        hintText: 'Type or scan plate number...',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.qr_code_scanner, color: Color(0xFF718096)),
                          tooltip: 'Scan Plate Number',
                          onPressed: () async {
                            final result = await Navigator.push<String>(context,
                              MaterialPageRoute(builder: (_) => const BarcodeScannerScreen(
                                title: 'Scan Plate Number',
                                hint: 'Point camera at the plate number',
                              )));
                            if (result != null) {
                              plateCtrl.text = result.toUpperCase();
                              setModal(() => foundVehicle = _vehicles[result.toUpperCase()]);
                            }
                          },
                        ),
                      ),
                    ),
                    if (foundVehicle != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFF0F4FF), borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFbee3f8))),
                        child: Row(children: [
                          const Icon(Icons.local_shipping_outlined, color: _red, size: 20),
                          const SizedBox(width: 10),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(foundVehicle!['desc']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            Text('${foundVehicle!['owner']} • ${foundVehicle!['type']}',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF718096))),
                          ])),
                        ]),
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextField(controller: mechanicCtrl,
                      decoration: const InputDecoration(labelText: 'Mechanic Name *', border: OutlineInputBorder())),
                    const SizedBox(height: 10),
                    TextField(controller: dateCtrl,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Date Serviced *',
                        border: const OutlineInputBorder(),
                        hintText: 'Select date',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today_outlined, color: Color(0xFF718096)),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                              builder: (c, child) => Theme(
                                data: Theme.of(c).copyWith(
                                  colorScheme: const ColorScheme.light(primary: _red),
                                ),
                                child: child!,
                              ),
                            );
                            if (picked != null) {
                              dateCtrl.text = '${_monthName(picked.month)} ${picked.day}, ${picked.year}';
                              setModal(() {});
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Services Rendered
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Services Rendered', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF4a5568))),
                      TextButton.icon(
                        onPressed: () => setModal(() => svcRows.add({'name': TextEditingController(), 'qty': TextEditingController(), 'uom': TextEditingController(), 'cost': TextEditingController()})),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Row', style: TextStyle(fontSize: 12)),
                      ),
                    ]),
                    ...svcRows.asMap().entries.map((e) => _itemRow(e.value, true, () => setModal(() => svcRows.removeAt(e.key)), setModal, ctx)),
                    const SizedBox(height: 12),
                    // Materials Used
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Materials Used', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF4a5568))),
                      TextButton.icon(
                        onPressed: () => setModal(() => matRows.add({'name': TextEditingController(), 'qty': TextEditingController(), 'uom': TextEditingController(), 'cost': TextEditingController()})),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Row', style: TextStyle(fontSize: 12)),
                      ),
                    ]),
                    ...matRows.asMap().entries.map((e) => _itemRow(e.value, false, () => setModal(() => matRows.removeAt(e.key)), setModal, ctx)),
                    const SizedBox(height: 12),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Total Cost:', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2c5282), fontSize: 14)),
                      Text('₱${totalCost().toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2b6cb0))),
                    ]),
                    const SizedBox(height: 20),
                    Row(children: [
                      Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
                      const SizedBox(width: 12),
                      Expanded(child: ElevatedButton(
                        onPressed: () {
                          if (plateCtrl.text.trim().isEmpty) return;
                          setState(() {
                            final id = isEdit ? service!['id']! : 'SVC-${(_services.length + 1).toString().padLeft(3, '0')}';
                            final newS = {
                              'id': id,
                              'plate': plateCtrl.text.trim().toUpperCase(),
                              'desc': foundVehicle?['desc'] ?? '',
                              'mechanic': mechanicCtrl.text.trim(),
                              'date': dateCtrl.text.trim(),
                              'cost': '₱${totalCost().toStringAsFixed(2)}',
                              'status': isEdit ? service!['status']! : 'Pending',
                            };
                            // Save rows data
                            _svcRowsData[id] = svcRows.map((r) => {
                              'name': r['name']!.text,
                              'qty':  r['qty']!.text,
                              'uom':  r['uom']!.text,
                              'cost': r['cost']!.text,
                            }).toList();
                            _matRowsData[id] = matRows.map((r) => {
                              'name': r['name']!.text,
                              'qty':  r['qty']!.text,
                              'uom':  r['uom']!.text,
                              'cost': r['cost']!.text,
                            }).toList();
                            if (isEdit) {
                              final idx = _services.indexWhere((e) => e['id'] == service!['id']);
                              if (idx != -1) _services[idx] = newS;
                            } else {
                              _services.add(newS);
                            }
                            _filtered = List.from(_services);
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: _red, foregroundColor: Colors.white),
                        child: Text(isEdit ? '💾 Update' : '💾 Save'),
                      )),
                    ]),
                  ]),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _rowHeader() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Expanded(flex: 3, child: Text('Item', style: TextStyle(fontSize: 10, color: Color(0xFF718096), fontWeight: FontWeight.w600))),
        SizedBox(width: 4),
        SizedBox(width: 44, child: Text('Qty', style: TextStyle(fontSize: 10, color: Color(0xFF718096), fontWeight: FontWeight.w600))),
        SizedBox(width: 4),
        SizedBox(width: 44, child: Text('UOM', style: TextStyle(fontSize: 10, color: Color(0xFF718096), fontWeight: FontWeight.w600))),
        SizedBox(width: 4),
        SizedBox(width: 60, child: Text('Cost (₱)', style: TextStyle(fontSize: 10, color: Color(0xFF718096), fontWeight: FontWeight.w600))),
        SizedBox(width: 28),
      ]),
    );
  }

  Widget _itemRow(Map<String, TextEditingController> row, bool isService, VoidCallback onRemove, StateSetter setModal, BuildContext ctx) {
    if (!isService) return _materialRow(row, onRemove, setModal, ctx);

    // Service row: dropdown with auto-fill + qty only
    final isFound = row['name']!.text.isNotEmpty;
    final currentVal = _serviceItems.contains(row['name']!.text) ? row['name']!.text : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: DropdownButtonFormField<String>(
            value: currentVal,
            hint: const Text('Select service...', style: TextStyle(fontSize: 11)),
            isExpanded: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              isDense: true,
            ),
            items: _serviceItems.map((s) => DropdownMenuItem(
              value: s,
              child: Text(s, style: const TextStyle(fontSize: 12)),
            )).toList(),
            onChanged: (v) {
              if (v != null) {
                row['name']!.text = v;
                final data = _serviceItemData[v];
                row['uom']!.text = data?['uom'] ?? 'job';
                row['cost']!.text = data?['cost'] ?? '0';
              }
              setModal(() {});
            },
          )),
          SizedBox(width: 32, child: IconButton(
            icon: const Icon(Icons.close, size: 16, color: Colors.red),
            padding: EdgeInsets.zero,
            onPressed: onRemove,
          )),
        ]),
        if (isFound) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFebf8ff),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF90cdf4)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.build_outlined, size: 16, color: Color(0xFF003087)),
                const SizedBox(width: 6),
                Expanded(child: Text(row['name']!.text,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
              ]),
              const SizedBox(height: 4),
              Text('UOM: ${row['uom']!.text}  •  Unit Cost: ₱${row['cost']!.text}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF718096))),
              const SizedBox(height: 8),
              TextField(
                controller: row['qty'],
                keyboardType: TextInputType.number,
                onChanged: (_) => setModal(() {}),
                decoration: const InputDecoration(
                  labelText: 'Quantity *',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  isDense: true,
                ),
              ),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _materialRow(Map<String, TextEditingController> row, VoidCallback onRemove, StateSetter setModal, BuildContext ctx) {
    final scanCtrl = TextEditingController();

    void lookup(String query) {
      final q = query.trim().toLowerCase();
      if (q.isEmpty) return;
      for (final entry in _itemMasterData.entries) {
        final d = entry.value;
        if (entry.key.toLowerCase().contains(q) ||
            d['barcode'] == query.trim() ||
            d['qr'] == query.trim()) {
          row['name']!.text = entry.key;
          row['uom']!.text = d['uom']!;
          row['cost']!.text = d['cost']!;
          setModal(() {});
          return;
        }
      }
      // Not found — clear
      row['name']!.text = '';
      row['uom']!.text = '';
      row['cost']!.text = '';
      setModal(() {});
    }

    final isFound = row['name']!.text.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Scan/search field
        Row(children: [
          Expanded(child: TextField(
            controller: scanCtrl,
            decoration: InputDecoration(
              hintText: 'Scan or type item name / barcode...',
              hintStyle: const TextStyle(fontSize: 11),
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              isDense: true,
              suffixIcon: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(
                  icon: const Icon(Icons.search, size: 18, color: Color(0xFF718096)),
                  padding: EdgeInsets.zero,
                  tooltip: 'Search',
                  onPressed: () => lookup(scanCtrl.text),
                ),
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner, size: 18, color: Color(0xFF003087)),
                  padding: EdgeInsets.zero,
                  tooltip: 'Scan',
                  onPressed: () async {
                    final result = await Navigator.push<String>(
                      ctx,
                      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
                    );
                    if (result != null) {
                      scanCtrl.text = result;
                      lookup(result);
                    }
                  },
                ),
              ]),
            ),
            onSubmitted: lookup,
          )),
          SizedBox(width: 32, child: IconButton(
            icon: const Icon(Icons.close, size: 16, color: Colors.red),
            padding: EdgeInsets.zero,
            onPressed: onRemove,
          )),
        ]),
        // Found item details + qty
        if (isFound) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFebf8ff),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF90cdf4)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.inventory_2_outlined, size: 16, color: Color(0xFF003087)),
                const SizedBox(width: 6),
                Expanded(child: Text(row['name']!.text,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                GestureDetector(
                  onTap: () {
                    row['name']!.text = '';
                    row['uom']!.text = '';
                    row['cost']!.text = '';
                    scanCtrl.clear();
                    setModal(() {});
                  },
                  child: const Icon(Icons.close, size: 14, color: Color(0xFF718096)),
                ),
              ]),
              const SizedBox(height: 4),
              Text('UOM: ${row['uom']!.text}  •  Unit Cost: ₱${row['cost']!.text}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF718096))),
              const SizedBox(height: 8),
              TextField(
                controller: row['qty'],
                keyboardType: TextInputType.number,
                onChanged: (_) => setModal(() {}),
                decoration: const InputDecoration(
                  labelText: 'Quantity *',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  isDense: true,
                ),
              ),
            ]),
          ),
        ] else if (scanCtrl.text.isNotEmpty) ...[
          const SizedBox(height: 4),
          const Text('No item found for that code.', style: TextStyle(fontSize: 11, color: Colors.red)),
        ],
      ]),
    );
  }

  String _monthName(int m) => const ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m - 1];

  void _confirmDelete(Map<String, String> s) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text('Delete "${s['id']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() {
                _services.removeWhere((e) => e['id'] == s['id']);
                _filtered = List.from(_services);
              });
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
