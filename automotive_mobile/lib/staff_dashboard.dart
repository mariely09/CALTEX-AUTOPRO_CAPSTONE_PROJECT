import 'package:flutter/material.dart';
import 'login.dart';
import 'profile.dart';
import 'staff_inventory.dart';
import 'staff_maintenance.dart';
import 'staff_vehicle_list.dart';
import 'notifications.dart';
import 'barcode_scanner_screen.dart';

class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  int _currentIndex = 0;
  static const _red = Color(0xFFE8001C);
  static const _bg = Color(0xFFF7F8FA);

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.dashboard_outlined, label: 'Dashboard'),
    _NavItem(icon: Icons.inventory_2_outlined, label: 'Inventory'),
    _NavItem(icon: Icons.build_outlined, label: 'Maintenance'),
    _NavItem(icon: Icons.directions_car_outlined, label: 'Vehicle'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildTopBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildTopBar() {
    return AppBar(
      backgroundColor: _red,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Image.asset('assets/img/LOGO_CALTEX.png', width: 36, height: 36, fit: BoxFit.contain),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/img/CALTEX_LETTER.png', height: 18, fit: BoxFit.contain),
              const Text('AutoPro', style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 2)),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppNotifications(role: NotificationRole.staff))),
        ),
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.white24,
          child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserProfile(role: UserRole.staff))),
            child: const Text('ST', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0: return _buildDashboard();
      case 1: return const StaffInventory();
      case 2: return const StaffMaintenance();
      case 3: return const StaffVehicleList();
      default: return _buildDashboard();
    }
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x18000000), blurRadius: 12, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 5 slots: 2 left + center placeholder + 2 right
              Row(children: [
                _navBtn(0), // Dashboard
                _navBtn(1), // Inventory
                const Expanded(child: SizedBox()), // center placeholder for scan button
                _navBtn(2), // Maintenance
                _navBtn(3), // Vehicle
              ]),
              // Center scan button
              Positioned(
                top: -20,
                left: 0, right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () => _showScanModal(),
                    child: Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: _red,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: _red.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 26),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navBtn(int i) {
    final active = _currentIndex == i;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = i),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(_navItems[i].icon, color: active ? _red : const Color(0xFF718096), size: 22),
          const SizedBox(height: 2),
          Text(_navItems[i].label,
            style: TextStyle(fontSize: 10, color: active ? _red : const Color(0xFF718096),
              fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
        ]),
      ),
    );
  }

  // Item lookup data (barcode/QR → item info)
  static const _itemLookup = {
    '1234567890': {'name': 'Engine Oil 10W-40', 'code': 'OIL-001', 'unit': 'L'},
    '0987654321': {'name': 'Oil Filter', 'code': 'FLT-002', 'unit': 'pcs'},
    '1122334455': {'name': 'Brake Pads', 'code': 'BRK-003', 'unit': 'set'},
    '5566778899': {'name': 'Air Filter', 'code': 'FLT-004', 'unit': 'pcs'},
    'QR-OIL-001': {'name': 'Engine Oil 10W-40', 'code': 'OIL-001', 'unit': 'L'},
    'QR-FLT-002': {'name': 'Oil Filter', 'code': 'FLT-002', 'unit': 'pcs'},
    'QR-BRK-003': {'name': 'Brake Pads', 'code': 'BRK-003', 'unit': 'set'},
    'QR-FLT-004': {'name': 'Air Filter', 'code': 'FLT-004', 'unit': 'pcs'},
  };

  void _showScanModal() async {
    await Navigator.push(context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()));
  }

  void _showReceiveScanModal() {
    final manualCtrl = TextEditingController();
    Map<String, String>? foundItem;

    void lookup(String code, StateSetter setModal) {
      final q = code.trim();
      Map<String, String>? result = _itemLookup[q];
      if (result == null) {
        for (final entry in _itemLookup.entries) {
          if (entry.value['name']!.toLowerCase().contains(q.toLowerCase()) ||
              entry.value['code']!.toLowerCase().contains(q.toLowerCase())) {
            result = entry.value;
            break;
          }
        }
      }
      setModal(() => foundItem = result);
    }

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => DraggableScrollableSheet(
          expand: false, initialChildSize: 0.65, maxChildSize: 0.9,
          builder: (_, ctrl) => SingleChildScrollView(
            controller: ctrl,
            child: Column(children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                decoration: const BoxDecoration(color: Color(0xFF003087), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                child: Row(children: [
                  Container(width: 44, height: 44,
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 22)),
                  const SizedBox(width: 12),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Receive Items', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('Scan to receive stock', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ])),
                  GestureDetector(onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.white)),
                ]),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20),
                child: Column(children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push<String>(context,
                          MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()));
                        if (result != null) {
                          manualCtrl.text = result;
                          lookup(result, setModal);
                        }
                      },
                      icon: const Icon(Icons.camera_alt_outlined, size: 18),
                      label: const Text('Open Camera Scanner'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003087), foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Row(children: [
                    Expanded(child: Divider()),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('or enter manually', style: TextStyle(fontSize: 11, color: Color(0xFF718096)))),
                    Expanded(child: Divider()),
                  ]),
                  const SizedBox(height: 14),
                  TextField(
                    controller: manualCtrl,
                    onChanged: (v) => lookup(v, setModal),
                    onSubmitted: (v) => lookup(v, setModal),
                    decoration: InputDecoration(
                      hintText: 'Barcode / QR code / Item name...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  if (foundItem != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: const Color(0xFFebf8ff), borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF003087).withOpacity(0.3))),
                      child: Row(children: [
                        Container(width: 40, height: 40,
                          decoration: BoxDecoration(color: const Color(0xFF003087).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF003087), size: 20)),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(foundItem!['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('${foundItem!['code']} • ${foundItem!['unit']}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF718096))),
                        ])),
                        const Icon(Icons.check_circle, color: Color(0xFF003087), size: 20),
                      ]),
                    ),
                  ] else if (manualCtrl.text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text('No item found for that code.', style: TextStyle(fontSize: 12, color: Colors.red)),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: foundItem == null ? null : () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Receive: ${foundItem!['name']}'), backgroundColor: const Color(0xFF003087)));
                      },
                      icon: const Icon(Icons.download_outlined, size: 16),
                      label: const Text('Confirm Receive'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003087), foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                    )),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  // ── DASHBOARD ──
  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.4,
          children: [
            _statCard('Total Services', '12', Icons.build_outlined, _red),
            _statCard('Ongoing', '3', Icons.autorenew, Colors.orange),
            _statCard('Completed', '9', Icons.check_circle_outline, const Color(0xFF2c7a7b)),
            _statCard('Low Stock', '5', Icons.warning_amber_outlined, const Color(0xFF003087)),
          ],
        ),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _sectionTitle("Today's Service Schedule"),
          TextButton(onPressed: () => setState(() => _currentIndex = 2),
            child: const Text('See all', style: TextStyle(fontSize: 12, color: Color(0xFF003087)))),
        ]),
        const SizedBox(height: 8),
        _buildScheduleCard('SVC-001', 'ABC-1234', 'Oil Change', 'Ongoing'),
        _buildScheduleCard('SVC-002', 'XYZ-5678', 'Tire Rotation', 'Pending'),
        _buildScheduleCard('SVC-003', 'DEF-9012', 'Brake Inspection', 'Completed'),
      ]),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 6),
        FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color))),
        Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF718096)), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
      ]),
    );
  }

  Widget _buildScheduleCard(String id, String plate, String service, String status) {
    final statusColor = status == 'Completed' ? Colors.green : status == 'Ongoing' ? Colors.orange : const Color(0xFF718096);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: const Color(0xFFF0F4FF), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.build_outlined, color: _red, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text('$plate • $service', style: const TextStyle(fontSize: 11, color: Color(0xFF718096))),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: Text(status, style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }

  // ── INVENTORY ──
  Widget _buildInventory() {
    final items = [
      {'name': 'Engine Oil 10W-40', 'code': 'OIL-001', 'stock': 24, 'unit': 'L', 'low': false},
      {'name': 'Oil Filter', 'code': 'FLT-002', 'stock': 3, 'unit': 'pcs', 'low': true},
      {'name': 'Brake Pads', 'code': 'BRK-003', 'stock': 8, 'unit': 'set', 'low': false},
      {'name': 'Air Filter', 'code': 'FLT-004', 'stock': 2, 'unit': 'pcs', 'low': true},
      {'name': 'Coolant', 'code': 'CLT-005', 'stock': 15, 'unit': 'L', 'low': false},
    ];
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search parts...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true, fillColor: const Color(0xFFF7F8FA),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () => _showReceiveModal(),
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Receive'),
                style: ElevatedButton.styleFrom(backgroundColor: _red, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final item = items[i];
              final isLow = item['low'] as bool;
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: isLow ? Border.all(color: Colors.orange.shade200) : null,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(color: isLow ? Colors.orange.shade50 : const Color(0xFFF0F4FF), borderRadius: BorderRadius.circular(10)),
                      child: Icon(Icons.inventory_2_outlined, color: isLow ? Colors.orange : _red, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          Text(item['code'] as String, style: const TextStyle(fontSize: 11, color: Color(0xFF718096))),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${item['stock']} ${item['unit']}', style: TextStyle(fontWeight: FontWeight.bold, color: isLow ? Colors.orange : const Color(0xFF1a202c))),
                        if (isLow) const Text('Low Stock', style: TextStyle(fontSize: 10, color: Colors.orange)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showReceiveModal() {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('📥 Receive Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ]),
              const SizedBox(height: 12),
              const TextField(decoration: InputDecoration(labelText: 'Search Item', prefixIcon: Icon(Icons.search), border: OutlineInputBorder())),
              const SizedBox(height: 12),
              const TextField(decoration: InputDecoration(labelText: 'Quantity Received', prefixIcon: Icon(Icons.add_box_outlined), border: OutlineInputBorder()), keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('✅ Confirm', style: TextStyle(color: Colors.white)),
                )),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // ── MAINTENANCE ──
  Widget _buildMaintenance() {
    final services = [
      {'id': 'SVC-001', 'plate': 'ABC-1234', 'vehicle': 'Isuzu Truck NQR', 'mechanic': 'Juan Dela Cruz', 'date': '2026-03-28', 'status': 'Ongoing', 'total': '₱2,500'},
      {'id': 'SVC-002', 'plate': 'XYZ-5678', 'vehicle': 'Toyota Hilux', 'mechanic': 'Pedro Santos', 'date': '2026-03-28', 'status': 'Pending', 'total': '₱1,800'},
      {'id': 'SVC-003', 'plate': 'DEF-9012', 'vehicle': 'Mitsubishi L300', 'mechanic': 'Jose Reyes', 'date': '2026-03-27', 'status': 'Completed', 'total': '₱3,200'},
    ];
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Expanded(child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search services...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true, fillColor: const Color(0xFFF7F8FA),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              )),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () => _showNewServiceModal(),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('New'),
                style: ElevatedButton.styleFrom(backgroundColor: _red, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: services.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final s = services[i];
              final statusColor = s['status'] == 'Completed' ? Colors.green : s['status'] == 'Ongoing' ? Colors.orange : const Color(0xFF718096);
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(s['id']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                        child: Text(s['status']!, style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600)),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    Text('${s['plate']} • ${s['vehicle']}', style: const TextStyle(fontSize: 12, color: Color(0xFF4a5568))),
                    Text('Mechanic: ${s['mechanic']}', style: const TextStyle(fontSize: 12, color: Color(0xFF718096))),
                    const SizedBox(height: 6),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(s['date']!, style: const TextStyle(fontSize: 11, color: Color(0xFF718096))),
                      Text(s['total']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1a202c))),
                    ]),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Service modal data (same as admin) ──
  static const _serviceItems = ['Oil Change Service'];
  static const _serviceItemData = {
    'Oil Change Service': {'uom': 'job', 'cost': '500'},
  };
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

  void _showNewServiceModal() {
    final plateCtrl = TextEditingController();
    final mechanicCtrl = TextEditingController();
    final dateCtrl = TextEditingController();
    Map<String, String>? foundVehicle;

    final List<Map<String, TextEditingController>> svcRows = [
      {'name': TextEditingController(), 'qty': TextEditingController(), 'uom': TextEditingController(), 'cost': TextEditingController()},
    ];
    final List<Map<String, TextEditingController>> matRows = [
      {'name': TextEditingController(), 'qty': TextEditingController(), 'uom': TextEditingController(), 'cost': TextEditingController()},
    ];

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
                  child: Row(children: [
                    Container(width: 44, height: 44,
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.add, color: Colors.white, size: 22)),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('New Service', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
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
                        hintText: 'Type plate number...',
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
                    TextField(controller: dateCtrl, readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Date Serviced *',
                        border: const OutlineInputBorder(),
                        hintText: 'Select date',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today_outlined, color: Color(0xFF718096)),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: ctx, initialDate: DateTime.now(),
                              firstDate: DateTime(2020), lastDate: DateTime(2030),
                              builder: (c, child) => Theme(
                                data: Theme.of(c).copyWith(colorScheme: const ColorScheme.light(primary: _red)),
                                child: child!),
                            );
                            if (picked != null) {
                              dateCtrl.text = '${_monthName(picked.month)} ${picked.day}, ${picked.year}';
                              setModal(() {});
                            }
                          },
                        ),
                      )),
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
                    ...svcRows.asMap().entries.map((e) => _svcItemRow(e.value, () => setModal(() => svcRows.removeAt(e.key)), setModal, ctx)),
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
                    ...matRows.asMap().entries.map((e) => _matItemRow(e.value, () => setModal(() => matRows.removeAt(e.key)), setModal, ctx)),
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
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Service saved successfully'), backgroundColor: Colors.green));
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: _red, foregroundColor: Colors.white),
                        child: const Text('💾 Save'),
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

  Widget _svcItemRow(Map<String, TextEditingController> row, VoidCallback onRemove, StateSetter setModal, BuildContext ctx) {
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
            decoration: const InputDecoration(border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10), isDense: true),
            items: _serviceItems.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12)))).toList(),
            onChanged: (v) {
              if (v != null) {
                row['name']!.text = v;
                final d = _serviceItemData[v];
                row['uom']!.text = d?['uom'] ?? 'job';
                row['cost']!.text = d?['cost'] ?? '0';
              }
              setModal(() {});
            },
          )),
          SizedBox(width: 32, child: IconButton(icon: const Icon(Icons.close, size: 16, color: Colors.red), padding: EdgeInsets.zero, onPressed: onRemove)),
        ]),
        if (isFound) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFebf8ff), borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF90cdf4))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.build_outlined, size: 16, color: Color(0xFF003087)),
                const SizedBox(width: 6),
                Expanded(child: Text(row['name']!.text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
              ]),
              const SizedBox(height: 4),
              Text('UOM: ${row['uom']!.text}  •  Unit Cost: ₱${row['cost']!.text}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF718096))),
              const SizedBox(height: 8),
              TextField(controller: row['qty'], keyboardType: TextInputType.number,
                onChanged: (_) => setModal(() {}),
                decoration: const InputDecoration(labelText: 'Quantity *', border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8), isDense: true)),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _matItemRow(Map<String, TextEditingController> row, VoidCallback onRemove, StateSetter setModal, BuildContext ctx) {
    final scanCtrl = TextEditingController();
    void lookup(String query) {
      final q = query.trim().toLowerCase();
      if (q.isEmpty) return;
      for (final entry in _itemMasterData.entries) {
        final d = entry.value;
        if (entry.key.toLowerCase().contains(q) || d['barcode'] == query.trim() || d['qr'] == query.trim()) {
          row['name']!.text = entry.key;
          row['uom']!.text = d['uom']!;
          row['cost']!.text = d['cost']!;
          setModal(() {});
          return;
        }
      }
      row['name']!.text = ''; row['uom']!.text = ''; row['cost']!.text = '';
      setModal(() {});
    }
    final isFound = row['name']!.text.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                IconButton(icon: const Icon(Icons.search, size: 18, color: Color(0xFF718096)), padding: EdgeInsets.zero,
                  onPressed: () => lookup(scanCtrl.text)),
                IconButton(icon: const Icon(Icons.qr_code_scanner, size: 18, color: Color(0xFF003087)), padding: EdgeInsets.zero,
                  onPressed: () async {
                    final result = await Navigator.push<String>(ctx, MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()));
                    if (result != null) { scanCtrl.text = result; lookup(result); }
                  }),
              ]),
            ),
            onSubmitted: lookup,
          )),
          SizedBox(width: 32, child: IconButton(icon: const Icon(Icons.close, size: 16, color: Colors.red), padding: EdgeInsets.zero, onPressed: onRemove)),
        ]),
        if (isFound) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFebf8ff), borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF90cdf4))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.inventory_2_outlined, size: 16, color: Color(0xFF003087)),
                const SizedBox(width: 6),
                Expanded(child: Text(row['name']!.text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                GestureDetector(onTap: () { row['name']!.text = ''; row['uom']!.text = ''; row['cost']!.text = ''; scanCtrl.clear(); setModal(() {}); },
                  child: const Icon(Icons.close, size: 14, color: Color(0xFF718096))),
              ]),
              const SizedBox(height: 4),
              Text('UOM: ${row['uom']!.text}  •  Unit Cost: ₱${row['cost']!.text}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF718096))),
              const SizedBox(height: 8),
              TextField(controller: row['qty'], keyboardType: TextInputType.number,
                onChanged: (_) => setModal(() {}),
                decoration: const InputDecoration(labelText: 'Quantity *', border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8), isDense: true)),
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

  // ── VEHICLES ──
  Widget _buildVehicles() {
    final vehicles = [
      {'plate': 'ABC-1234', 'desc': 'Isuzu Truck NQR 2021', 'type': 'truck', 'owner': 'Juan Dela Cruz', 'odo': '45,000 km'},
      {'plate': 'XYZ-5678', 'desc': 'Toyota Hilux 2020', 'type': 'car', 'owner': 'Pedro Santos', 'odo': '32,000 km'},
      {'plate': 'DEF-9012', 'desc': 'Mitsubishi L300 2019', 'type': 'truck', 'owner': 'Jose Reyes', 'odo': '78,000 km'},
    ];
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(children: [
            Expanded(child: TextField(
              decoration: InputDecoration(
                hintText: 'Search vehicles...',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true, fillColor: const Color(0xFFF7F8FA),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            )),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add'),
              style: ElevatedButton.styleFrom(backgroundColor: _red, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            ),
          ]),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: vehicles.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final v = vehicles[i];
              final isTruck = v['type'] == 'truck';
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
                child: Row(children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(color: const Color(0xFFF0F4FF), borderRadius: BorderRadius.circular(12)),
                    child: Icon(isTruck ? Icons.local_shipping_outlined : Icons.directions_car_outlined, color: _red, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(v['plate']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(v['desc']!, style: const TextStyle(fontSize: 12, color: Color(0xFF4a5568))),
                    Text('Owner: ${v['owner']}', style: const TextStyle(fontSize: 11, color: Color(0xFF718096))),
                  ])),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    const Icon(Icons.speed_outlined, size: 14, color: Color(0xFF718096)),
                    Text(v['odo']!, style: const TextStyle(fontSize: 11, color: Color(0xFF718096))),
                  ]),
                ]),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── NOTIFICATIONS ──
  Widget _buildNotifications() {
    final notifs = [
      {'title': 'Low Stock Alert', 'msg': 'Oil Filter is running low (3 pcs)', 'time': '2 hrs ago', 'icon': Icons.warning_amber_outlined, 'color': Colors.orange},
      {'title': 'Service Due', 'msg': 'ABC-1234 is due for service', 'time': '5 hrs ago', 'icon': Icons.build_outlined, 'color': _red},
      {'title': 'Stock Received', 'msg': 'Engine Oil 10W-40 restocked (+20L)', 'time': 'Yesterday', 'icon': Icons.check_circle_outline, 'color': Colors.green},
    ];
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: notifs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final n = notifs[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
          child: Row(children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(color: (n['color'] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(n['icon'] as IconData, color: n['color'] as Color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(n['title'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Text(n['msg'] as String, style: const TextStyle(fontSize: 12, color: Color(0xFF718096))),
            ])),
            Text(n['time'] as String, style: const TextStyle(fontSize: 10, color: Color(0xFF718096))),
          ]),
        );
      },
    );
  }

  // ── PROFILE ──
  Widget _buildProfile() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        const SizedBox(height: 12),
        CircleAvatar(radius: 40, backgroundColor: _red,
          child: const Text('ST', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
        const SizedBox(height: 12),
        const Text('Staff Member', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Text('Service Staff', style: TextStyle(color: Color(0xFF718096))),
        const SizedBox(height: 20),
        _profileCard('Account Info', [
          _profileRow(Icons.person_outline, 'Full Name', 'Staff Member'),
          _profileRow(Icons.alternate_email, 'Email', 'staff@caltex.com'),
          _profileRow(Icons.badge_outlined, 'Role', 'Service Staff'),
        ]),
        const SizedBox(height: 12),
        _profileCard('Quick Stats', [
          _profileRow(Icons.build_outlined, 'Total Services', '12'),
          _profileRow(Icons.autorenew, 'Ongoing', '3'),
          _profileRow(Icons.warning_amber_outlined, 'Low Stock Items', '5'),
        ]),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (_) => const _LogoutPlaceholder()), (_) => false),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ),
      ]),
    );
  }

  Widget _profileCard(String title, List<Widget> rows) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1a202c))),
        const Divider(height: 20),
        ...rows,
      ]),
    );
  }

  Widget _profileRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(icon, size: 18, color: _red),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF718096))),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ])),
      ]),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1a202c)));
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _LogoutPlaceholder extends StatelessWidget {
  const _LogoutPlaceholder();
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
    });
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
