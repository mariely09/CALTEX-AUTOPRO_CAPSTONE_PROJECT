import 'package:flutter/material.dart';

class CustomerPms extends StatelessWidget {
  const CustomerPms({super.key});

  static const _red = Color(0xFFE8001C);
  static const _bg = Color(0xFFF7F8FA);

  // ── Mock data ──
  static final _history = [
    {
      'plate': 'ABC-1234',
      'desc': 'Isuzu Truck NQR 2021',
      'type': 'truck',
      'totalSpent': '₱7,900',
      'records': [
        {
          'date': 'Mar 15, 2026',
          'mechanic': 'Juan Dela Cruz',
          'odo': '45,000 km',
          'totalCost': '₱1,200',
          'services': [
            {'name': 'Oil Change Service', 'qty': '1', 'uom': 'job', 'cost': '₱500'},
          ],
          'materials': [
            {'name': 'Engine Oil 10W-40', 'qty': '4', 'uom': 'L', 'cost': '₱450'},
            {'name': 'Oil Filter', 'qty': '1', 'uom': 'pcs', 'cost': '₱250'},
          ],
        },
        {
          'date': 'Oct 10, 2025',
          'mechanic': 'Pedro Santos',
          'odo': '40,000 km',
          'totalCost': '₱3,500',
          'services': [
            {'name': 'PMS - 40,000 km', 'qty': '1', 'uom': 'job', 'cost': '₱500'},
            {'name': 'Brake Inspection', 'qty': '1', 'uom': 'job', 'cost': '₱300'},
          ],
          'materials': [
            {'name': 'Engine Oil 10W-40', 'qty': '4', 'uom': 'L', 'cost': '₱450'},
            {'name': 'Oil Filter', 'qty': '1', 'uom': 'pcs', 'cost': '₱250'},
            {'name': 'Brake Pads', 'qty': '1', 'uom': 'set', 'cost': '₱2,000'},
          ],
        },
      ],
    },
    {
      'plate': 'XYZ-5678',
      'desc': 'Toyota Hilux 2020',
      'type': 'car',
      'totalSpent': '₱3,700',
      'records': [
        {
          'date': 'Mar 20, 2026',
          'mechanic': 'Juan Dela Cruz',
          'odo': '32,000 km',
          'totalCost': '₱800',
          'services': [
            {'name': 'Tire Rotation', 'qty': '1', 'uom': 'job', 'cost': '₱800'},
          ],
          'materials': [],
        },
        {
          'date': 'Nov 12, 2025',
          'mechanic': 'Pedro Santos',
          'odo': '30,000 km',
          'totalCost': '₱2,900',
          'services': [
            {'name': 'PMS - 30,000 km', 'qty': '1', 'uom': 'job', 'cost': '₱500'},
          ],
          'materials': [
            {'name': 'Engine Oil 10W-40', 'qty': '4', 'uom': 'L', 'cost': '₱450'},
            {'name': 'Oil Filter', 'qty': '1', 'uom': 'pcs', 'cost': '₱250'},
            {'name': 'Air Filter', 'qty': '1', 'uom': 'pcs', 'cost': '₱1,700'},
          ],
        },
      ],
    },
    {
      'plate': 'DEF-9012',
      'desc': 'Mitsubishi L300 2019',
      'type': 'truck',
      'totalSpent': '₱10,400',
      'records': [
        {
          'date': 'Jan 10, 2026',
          'mechanic': 'Jose Reyes',
          'odo': '78,000 km',
          'totalCost': '₱2,500',
          'services': [
            {'name': 'Brake Inspection', 'qty': '1', 'uom': 'job', 'cost': '₱500'},
          ],
          'materials': [
            {'name': 'Brake Pads', 'qty': '2', 'uom': 'set', 'cost': '₱2,000'},
          ],
        },
        {
          'date': 'Aug 22, 2025',
          'mechanic': 'Juan Dela Cruz',
          'odo': '75,000 km',
          'totalCost': '₱4,100',
          'services': [
            {'name': 'PMS - 75,000 km', 'qty': '1', 'uom': 'job', 'cost': '₱500'},
            {'name': 'Oil Change Service', 'qty': '1', 'uom': 'job', 'cost': '₱500'},
          ],
          'materials': [
            {'name': 'Engine Oil 10W-40', 'qty': '6', 'uom': 'L', 'cost': '₱450'},
            {'name': 'Oil Filter', 'qty': '1', 'uom': 'pcs', 'cost': '₱250'},
            {'name': 'Air Filter', 'qty': '1', 'uom': 'pcs', 'cost': '₱1,400'},
          ],
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(children: [
              const Icon(Icons.history, color: _red, size: 20),
              const SizedBox(width: 8),
              const Expanded(child: Text('PMS History',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1a202c)))),
              Text('${_history.length} vehicles',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF718096))),
            ]),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: _history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final v = _history[i];
                final records = v['records'] as List<Map<String, dynamic>>;
                final isTruck = v['type'] == 'truck';
                return GestureDetector(
                  onTap: () => _showVehicleHistory(ctx, v),
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
                        child: Icon(isTruck ? Icons.local_shipping_outlined : Icons.directions_car_outlined, color: _red, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(v['plate'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1a202c))),
                        Text(v['desc'] as String,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF718096))),
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.receipt_long_outlined, size: 12, color: Color(0xFF718096)),
                          const SizedBox(width: 4),
                          Text('${records.length} service records',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF718096))),
                        ]),
                      ])),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text(v['totalSpent'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1a202c))),
                        const Text('total spent', style: TextStyle(fontSize: 9, color: Color(0xFF718096))),
                        const SizedBox(height: 6),
                        const Icon(Icons.chevron_right, color: Color(0xFF718096), size: 18),
                      ]),
                    ]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showVehicleHistory(BuildContext context, Map<String, dynamic> v) {
    final records = v['records'] as List<Map<String, dynamic>>;
    final isTruck = v['type'] == 'truck';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        builder: (_, ctrl) => Column(children: [
          // Sheet header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            decoration: const BoxDecoration(
              color: _red,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ),
              Icon(isTruck ? Icons.local_shipping : Icons.directions_car, color: Colors.white, size: 36),
              const SizedBox(height: 8),
              Text(v['desc'] as String,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              Text(v['plate'] as String,
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 4),
              Text('${records.length} service records  •  ${v['totalSpent']} total',
                  style: const TextStyle(color: Colors.white60, fontSize: 11)),
            ]),
          ),
          // Records list
          Expanded(
            child: ListView.separated(
              controller: ctrl,
              padding: const EdgeInsets.all(16),
              itemCount: records.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (_, i) {
                final r = records[i];
                final services = (r['services'] as List<dynamic>).cast<Map<String, dynamic>>();
                final materials = (r['materials'] as List<dynamic>).cast<Map<String, dynamic>>();
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Record header
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FA),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.calendar_today_outlined, size: 13, color: Color(0xFF718096)),
                        const SizedBox(width: 6),
                        Text(r['date'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1a202c))),
                        const Spacer(),
                        const Icon(Icons.speed_outlined, size: 13, color: Color(0xFF718096)),
                        const SizedBox(width: 4),
                        Text(r['odo'] as String,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF718096))),
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        // Mechanic
                        Row(children: [
                          const Icon(Icons.person_outline, size: 13, color: Color(0xFF718096)),
                          const SizedBox(width: 5),
                          Text('Mechanic: ${r['mechanic']}',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF718096))),
                        ]),
                        const SizedBox(height: 12),
                        // Services Rendered
                        _sectionLabel(Icons.build_outlined, 'Services Rendered', const Color(0xFF2b6cb0)),
                        const SizedBox(height: 6),
                        ...services.map((s) => _lineItem(s, const Color(0xFF2b6cb0))),
                        if (materials.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _sectionLabel(Icons.inventory_2_outlined, 'Materials Used', Colors.teal),
                          const SizedBox(height: 6),
                          ...materials.map((m) => _lineItem(m, Colors.teal)),
                        ],
                        const Divider(height: 20),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          const Text('Total', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF4a5568))),
                          Text(r['totalCost'] as String,
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
      Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
        child: Icon(icon, size: 13, color: color),
      ),
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
        Expanded(child: Text(item['name']!, style: const TextStyle(fontSize: 12, color: Color(0xFF1a202c)))),
        Text('${item['qty']} ${item['uom']}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF718096))),
        const SizedBox(width: 10),
        Text(item['cost']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1a202c))),
      ]),
    );
  }
}
