import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerPms extends StatefulWidget {
  const CustomerPms({super.key});

  @override
  State<CustomerPms> createState() => _CustomerPmsState();
}

class _CustomerPmsState extends State<CustomerPms> {
  static const _red = Color(0xFFE8001C);
  static const _bg = Color(0xFFF7F8FA);

  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (mounted) setState(() => _userName = doc['name'] as String? ?? '');
  }

  @override
  Widget build(BuildContext context) {
    if (_userName.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: _bg,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('vehicles')
            .snapshots(),
        builder: (context, vSnap) {
          if (vSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final myVehicles = (vSnap.data?.docs ?? [])
              .where((d) => (d['owner'] as String? ?? '').toLowerCase() == _userName.toLowerCase())
              .toList();

          if (myVehicles.isEmpty) {
            return const Center(child: Text('No vehicles registered under your name.',
              style: TextStyle(color: Color(0xFF718096))));
          }

          return Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Row(children: [
                const Icon(Icons.history, color: _red, size: 20),
                const SizedBox(width: 8),
                const Expanded(child: Text('PMS History',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1a202c)))),
                Text('${myVehicles.length} vehicle${myVehicles.length != 1 ? 's' : ''}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF718096))),
              ]),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: myVehicles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) {
                  final vData = myVehicles[i].data() as Map<String, dynamic>;
                  final plate = vData['plate'] as String? ?? '';
                  final desc = vData['desc'] as String? ?? '';
                  return _VehicleHistoryCard(plate: plate, desc: desc);
                },
              ),
            ),
          ]);
        },
      ),
    );
  }
}

class _VehicleHistoryCard extends StatelessWidget {
  final String plate;
  final String desc;
  static const _red = Color(0xFFE8001C);

  const _VehicleHistoryCard({required this.plate, required this.desc});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('maintenance')
          .where('plate', isEqualTo: plate)
          .where('status', isEqualTo: 'Completed')
          .snapshots(),
      builder: (context, snap) {
        final docs = (snap.data?.docs ?? [])
          ..sort((a, b) {
            final aTime = (a.data() as Map)['createdAt'];
            final bTime = (b.data() as Map)['createdAt'];
            if (aTime == null || bTime == null) return 0;
            return (bTime as Timestamp).compareTo(aTime as Timestamp);
          });
        final totalCost = docs.fold<double>(0, (sum, d) {
          final cost = (d['cost'] as String? ?? '0').replaceAll('₱', '').replaceAll(',', '');
          return sum + (double.tryParse(cost) ?? 0);
        });

        return GestureDetector(
          onTap: () => _showHistory(context, docs),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(color: _red.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.directions_car_outlined, color: _red, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(plate, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1a202c))),
                Text(desc, style: const TextStyle(fontSize: 11, color: Color(0xFF718096))),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.receipt_long_outlined, size: 12, color: Color(0xFF718096)),
                  const SizedBox(width: 4),
                  Text('${docs.length} service record${docs.length != 1 ? 's' : ''}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF718096))),
                ]),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('₱${totalCost.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1a202c))),
                const Text('total spent', style: TextStyle(fontSize: 9, color: Color(0xFF718096))),
                const SizedBox(height: 6),
                const Icon(Icons.chevron_right, color: Color(0xFF718096), size: 18),
              ]),
            ]),
          ),
        );
      },
    );
  }

  void _showHistory(BuildContext context, List<QueryDocumentSnapshot> docs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        expand: false, initialChildSize: 0.85, maxChildSize: 0.95,
        builder: (_, ctrl) => Column(children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            decoration: const BoxDecoration(color: _red,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            child: Column(children: [
              Align(alignment: Alignment.topRight,
                child: GestureDetector(onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white))),
              const Icon(Icons.directions_car_outlined, color: Colors.white, size: 36),
              const SizedBox(height: 8),
              Text(desc, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              Text(plate, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 4),
              Text('${docs.length} completed service${docs.length != 1 ? 's' : ''}',
                style: const TextStyle(color: Colors.white60, fontSize: 11)),
            ]),
          ),
          Expanded(
            child: docs.isEmpty
              ? const Center(child: Text('No completed services yet.', style: TextStyle(color: Color(0xFF718096))))
              : ListView.separated(
                  controller: ctrl,
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (_, i) {
                    final r = docs[i].data() as Map<String, dynamic>;
                    final svcRows = (r['svcRows'] as List<dynamic>? ?? [])
                        .where((x) => (x['name'] as String? ?? '').isNotEmpty).toList();
                    final matRows = (r['matRows'] as List<dynamic>? ?? [])
                        .where((x) => (x['name'] as String? ?? '').isNotEmpty).toList();

                    return Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: const Color(0xFFF7F8FA),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                            border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
                          child: Row(children: [
                            const Icon(Icons.calendar_today_outlined, size: 13, color: Color(0xFF718096)),
                            const SizedBox(width: 6),
                            Text(r['date'] as String? ?? '—',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1a202c))),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                              child: const Text('Completed', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.w600)),
                            ),
                          ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              const Icon(Icons.person_outline, size: 13, color: Color(0xFF718096)),
                              const SizedBox(width: 5),
                              Text('Mechanic: ${r['mechanic'] ?? '—'}',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF718096))),
                            ]),
                            if (svcRows.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _sectionLabel(Icons.build_outlined, 'Services Rendered', const Color(0xFF2b6cb0)),
                              const SizedBox(height: 6),
                              ...svcRows.map((s) => _lineItem(s as Map<String, dynamic>, const Color(0xFF2b6cb0))),
                            ],
                            if (matRows.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              _sectionLabel(Icons.inventory_2_outlined, 'Materials Used', Colors.teal),
                              const SizedBox(height: 6),
                              ...matRows.map((m) => _lineItem(m as Map<String, dynamic>, Colors.teal)),
                            ],
                            const Divider(height: 20),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              const Text('Total', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF4a5568))),
                              Text(r['cost'] as String? ?? '—',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: _red)),
                            ]),
                          ]),
                        ),
                      ]),
                    );
                  },
                ),
          ),
        ]),
      ),
    );
  }

  Widget _sectionLabel(IconData icon, String label, Color color) {
    return Row(children: [
      Container(padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
        child: Icon(icon, size: 13, color: color)),
      const SizedBox(width: 6),
      Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    ]);
  }

  Widget _lineItem(Map<String, dynamic> item, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Container(width: 4, height: 4, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Text(item['name'] as String? ?? '', style: const TextStyle(fontSize: 12, color: Color(0xFF1a202c)))),
        Text('${item['qty']} ${item['uom']}', style: const TextStyle(fontSize: 11, color: Color(0xFF718096))),
        const SizedBox(width: 10),
        Text('₱${((double.tryParse((item['cost'] as String? ?? '0').replaceAll('₱', '')) ?? 0) * (double.tryParse(item['qty'] as String? ?? '1') ?? 1)).toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1a202c))),
      ]),
    );
  }
}
