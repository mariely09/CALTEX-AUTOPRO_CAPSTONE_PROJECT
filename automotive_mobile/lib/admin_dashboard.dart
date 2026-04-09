import 'package:flutter/material.dart';
import 'login.dart';
import 'admin_inventory_itemaster.dart';
import 'admin_inventory_stock.dart';
import 'admin_vehicles_list.dart';
import 'admin_vehicle_maintenance.dart';
import 'profile.dart';
import 'admin_users.dart';
import 'admin_dss.dart';
import 'notifications.dart';
import 'admin_smart_reports.dart';
import 'barcode_scanner_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;
  static const _red = Color(0xFFE8001C);
  static const _bg = Color(0xFFF7F8FA);

  final _navItems = const [
    (icon: Icons.dashboard_outlined, label: 'Dashboard'),
    (icon: Icons.inventory_2_outlined, label: 'Inventory'),
    (icon: Icons.directions_car_outlined, label: 'Vehicles'),
    (icon: Icons.more_horiz, label: 'More'),
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
      title: Row(children: [
        Image.asset('assets/img/LOGO_CALTEX.png', width: 36, height: 36, fit: BoxFit.contain),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Image.asset('assets/img/CALTEX_LETTER.png', height: 18, fit: BoxFit.contain),
          const Text('AutoPro', style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 2)),
        ]),
      ]),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppNotifications(role: NotificationRole.admin))),
        ),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserProfile(role: UserRole.admin))),
          child: const CircleAvatar(radius: 16, backgroundColor: Colors.white24,
            child: Text('AD', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0: return _buildDashboard();
      case 1: return _buildInventory();
      case 2: return _buildVehicles();
      case 3: return _buildMore();
      default: return _buildDashboard();
    }
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x18000000), blurRadius: 12, offset: Offset(0, -2))]),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 2 left + center placeholder + 2 right
              Row(children: [
                _navBtn(0), // Dashboard
                _navBtn(1), // Inventory
                const Expanded(child: SizedBox()), // center placeholder
                _navBtn(2), // Vehicles
                _navBtn(3), // More
              ]),
              // Center floating scanner button
              Positioned(
                top: -20, left: 0, right: 0,
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
          Text(_navItems[i].label, style: TextStyle(fontSize: 9,
            color: active ? _red : const Color(0xFF718096),
            fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
        ]),
      ),
    );
  }

  void _showScanModal() async {
    await Navigator.push(context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()));
  }

  // ── DASHBOARD ──
  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Stats grid
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.4,
          children: [
            _statCard('Total Vehicles', '24', Icons.directions_car_outlined, const Color(0xFF003087)),
            _statCard('Due for PMS', '5', Icons.build_outlined, Colors.orange),
            _statCard('Low Stock', '3', Icons.warning_amber_outlined, _red),
            _statCard('Services This Week', '18', Icons.check_circle_outline, const Color(0xFF2c7a7b)),
          ],
        ),
        const SizedBox(height: 20),

        // Recent Services
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _sectionTitle('Recent Services'),
          TextButton(onPressed: () {}, child: const Text('See all', style: TextStyle(fontSize: 12, color: Color(0xFF003087)))),
        ]),
        const SizedBox(height: 8),
        _serviceRow('ABC-1234', 'Change Oil', 'Today, 10:30 AM', 'Completed'),
        _serviceRow('XYZ-5678', 'Brake Inspection', 'Today, 9:15 AM', 'Completed'),
        _serviceRow('DEF-9012', 'PMS Service', 'Yesterday, 3:00 PM', 'Completed'),
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

  Widget _serviceRow(String plate, String service, String time, String status) {
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
          Text(plate, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text('$service • $time', style: const TextStyle(fontSize: 11, color: Color(0xFF718096))),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: Text(status, style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }

  // ── INVENTORY ──
  int _invTab = 1; // 0=Item Master, 1=Transactions, 2=Stock

  Widget _buildInventory() {
    return Column(children: [
      Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(children: [
          _invTabBtn('Item Master', 0),
          _invTabBtn('Transactions', 1),
          _invTabBtn('Stock', 2),
        ]),
      ),
      Expanded(child: _invTab == 0
        ? _buildItemMasterRedirect()
        : _invTab == 1 ? _buildTransactions() : _buildStockRedirect()),
    ]);
  }

  Widget _buildItemMasterRedirect() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_invTab == 0) {
        Navigator.push(context,
          MaterialPageRoute(builder: (_) => const AdminInventoryItemMaster()))
          .then((_) => setState(() => _invTab = 1));
      }
    });
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildStockRedirect() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_invTab == 2) {
        Navigator.push(context,
          MaterialPageRoute(builder: (_) => const AdminInventoryStock()))
          .then((_) => setState(() => _invTab = 1));
      }
    });
    return const Center(child: CircularProgressIndicator());
  }

  Widget _invTabBtn(String label, int idx) {
    final active = _invTab == idx;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _invTab = idx),
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

  Widget _buildItemMaster() {
    final items = [
      {'num': 'ITM-001', 'name': 'Engine Oil 10W-40', 'group': 'Lubricants', 'uom': 'L', 'cost': '₱450', 'type': 'Material'},
      {'num': 'ITM-002', 'name': 'Oil Filter', 'group': 'Filters', 'uom': 'pcs', 'cost': '₱180', 'type': 'Material'},
      {'num': 'ITM-003', 'name': 'Brake Pads', 'group': 'Brakes', 'uom': 'set', 'cost': '₱1,200', 'type': 'Material'},
      {'num': 'ITM-004', 'name': 'Oil Change Service', 'group': 'Labor', 'uom': 'job', 'cost': '₱500', 'type': 'Service'},
    ];
    return Column(children: [
      _searchBar('Search items...', () {}),
      Expanded(child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final item = items[i];
          final isSvc = item['type'] == 'Service';
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
            child: Row(children: [
              Container(width: 42, height: 42,
                decoration: BoxDecoration(color: isSvc ? Colors.blue.shade50 : const Color(0xFFF0F4FF), borderRadius: BorderRadius.circular(10)),
                child: Icon(isSvc ? Icons.build_outlined : Icons.inventory_2_outlined, color: isSvc ? Colors.blue : _red, size: 20)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item['name']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text('${item['num']} • ${item['group']}', style: const TextStyle(fontSize: 11, color: Color(0xFF718096))),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(item['cost']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text('${item['uom']} • ${item['type']}', style: const TextStyle(fontSize: 10, color: Color(0xFF718096))),
              ]),
            ]),
          );
        },
      )),
    ]);
  }

  Widget _buildStock() {
    final items = [
      {'name': 'Engine Oil 10W-40', 'stock': 24, 'min': 10, 'max': 50, 'status': 'OK'},
      {'name': 'Oil Filter', 'stock': 3, 'min': 5, 'max': 20, 'status': 'Low'},
      {'name': 'Brake Pads', 'stock': 8, 'min': 4, 'max': 20, 'status': 'OK'},
      {'name': 'Air Filter', 'stock': 2, 'min': 5, 'max': 15, 'status': 'Low'},
    ];
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          _miniStatInv('Total Items', '4', Colors.blue),
          const SizedBox(width: 8),
          _miniStatInv('Low Stock', '2', _red),
          const SizedBox(width: 8),
          _miniStatInv('Total Value', '₱52K', Colors.green),
        ]),
      ),
      Expanded(child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final item = items[i];
          final isLow = item['status'] == 'Low';
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
              border: isLow ? Border.all(color: Colors.orange.shade200) : null,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
            child: Row(children: [
              Container(width: 42, height: 42,
                decoration: BoxDecoration(color: isLow ? Colors.orange.shade50 : const Color(0xFFF0F4FF), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.inventory_2_outlined, color: isLow ? Colors.orange : _red, size: 20)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text('Min: ${item['min']} • Max: ${item['max']}', style: const TextStyle(fontSize: 11, color: Color(0xFF718096))),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('${item['stock']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isLow ? Colors.orange : const Color(0xFF1a202c))),
                if (isLow) const Text('Low Stock', style: TextStyle(fontSize: 10, color: Colors.orange)),
              ]),
            ]),
          );
        },
      )),
    ]);
  }

  Widget _miniStatInv(String label, String value, Color color) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF718096)), textAlign: TextAlign.center),
      ]),
    ));
  }

  Widget _buildTransactions() {
    final txns = [
      {'date': 'Mar 28', 'item': 'Engine Oil 10W-40', 'desc': 'Stock received from delivery', 'type': 'IN', 'qty': '+20', 'by': 'Staff'},
      {'date': 'Mar 27', 'item': 'Oil Filter', 'desc': 'Issued for SVC-002 maintenance', 'type': 'OUT', 'qty': '-2', 'by': 'Staff'},
      {'date': 'Mar 26', 'item': 'Brake Pads', 'desc': 'Issued for SVC-001 maintenance', 'type': 'OUT', 'qty': '-1', 'by': 'Staff'},
      {'date': 'Mar 25', 'item': 'Air Filter', 'desc': 'Stock received from delivery', 'type': 'IN', 'qty': '+10', 'by': 'Admin'},
    ];

    final totalIn = txns.where((t) => t['type'] == 'IN').length;
    final totalOut = txns.where((t) => t['type'] == 'OUT').length;

    return Column(children: [
      // Page header
      const Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Inventory Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1a202c))),
          Text('Track all stock in and out movements', style: TextStyle(fontSize: 12, color: Color(0xFF718096))),
        ]),
      ),
      // Stats row — 3 cards only: Total, Stock In, Stock Out
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(children: [
          _txnStat('Total', '${txns.length}', Icons.swap_horiz, Colors.blue),
          const SizedBox(width: 8),
          _txnStat('Stock In', '$totalIn', Icons.download_outlined, const Color(0xFF003087)),
          const SizedBox(width: 8),
          _txnStat('Stock Out', '$totalOut', Icons.upload_outlined, _red),
        ]),
      ),
      // Transaction list
      Expanded(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: txns.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final t = txns[i];
            final isIn = t['type'] == 'IN';
            final typeColor = isIn ? const Color(0xFF003087) : _red;
            return GestureDetector(
              onTap: () => _showTxnDetails(t),
              child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
              child: Row(children: [
                Container(width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: isIn ? const Color(0xFFebf8ff) : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10)),
                  child: Icon(isIn ? Icons.download_outlined : Icons.upload_outlined,
                    color: typeColor, size: 20)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t['item']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  Text(t['desc']!, style: const TextStyle(fontSize: 11, color: Color(0xFF718096)),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Row(children: [
                    const Icon(Icons.calendar_today_outlined, size: 10, color: Color(0xFF718096)),
                    const SizedBox(width: 3),
                    Text(t['date']!, style: const TextStyle(fontSize: 10, color: Color(0xFF718096))),
                    const SizedBox(width: 8),
                    const Icon(Icons.person_outline, size: 10, color: Color(0xFF718096)),
                    const SizedBox(width: 3),
                    Text(t['by']!, style: const TextStyle(fontSize: 10, color: Color(0xFF718096))),
                  ]),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(t['qty']!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: typeColor)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text(isIn ? 'IN' : 'OUT',
                      style: TextStyle(fontSize: 10, color: typeColor, fontWeight: FontWeight.w700)),
                  ),
                ]),
              ]),
            ),
            );
          },
        ),
      ),
    ]);
  }

  void _showTxnDetails(Map<String, String> t) {
    final isIn = t['type'] == 'IN';
    final typeColor = isIn ? const Color(0xFF003087) : _red;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        expand: false, initialChildSize: 0.5, maxChildSize: 0.75,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          child: Column(children: [
            // Red/Green header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              decoration: BoxDecoration(
                color: typeColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Container(width: 44, height: 44,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                  child: Icon(isIn ? Icons.download_outlined : Icons.upload_outlined, color: Colors.white, size: 22)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t['item']!, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(isIn ? 'Stock In' : 'Stock Out', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ])),
                GestureDetector(onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white)),
              ]),
            ),
            // Details
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _txnDetailRow('Item', t['item'] ?? '—'),
                _txnDetailRow('Description', t['desc'] ?? '—'),
                _txnDetailRow('Type', isIn ? 'Stock In (IN)' : 'Stock Out (OUT)'),
                _txnDetailRow('Quantity', t['qty'] ?? '—'),
                _txnDetailRow('Date', t['date'] ?? '—'),
                _txnDetailRow('Performed By', t['by'] ?? '—'),
                const SizedBox(height: 8),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _txnDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 120, child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF718096), fontWeight: FontWeight.w500))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1a202c)))),
      ]),
    );
  }

  Widget _txnStat(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
        child: Column(children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF718096))),
        ]),
      ),
    );
  }

  // ── VEHICLES ──
  int _vehTab = 1; // 0=Vehicle List, 1=Issuances, 2=Maintenance

  Widget _buildVehicles() {
    return Column(children: [
      Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(children: [
          _vehTabBtn('Vehicle List', 0),
          _vehTabBtn('Issuances', 1),
          _vehTabBtn('Maintenance', 2),
        ]),
      ),
      Expanded(child: _vehTab == 0 ? _buildVehicleListRedirect() : _vehTab == 1 ? _buildIssuances() : _buildMaintenanceRedirect()),
    ]);
  }

  Widget _vehTabBtn(String label, int idx) {
    final active = _vehTab == idx;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _vehTab = idx),
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

  Widget _buildVehicleListRedirect() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_vehTab == 0) {
        Navigator.push(context,
          MaterialPageRoute(builder: (_) => const AdminVehiclesList()))
          .then((_) => setState(() => _vehTab = 1));
      }
    });
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildMaintenanceRedirect() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_vehTab == 2) {
        Navigator.push(context,
          MaterialPageRoute(builder: (_) => const AdminVehicleMaintenance()))
          .then((_) => setState(() => _vehTab = 1));
      }
    });
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildVehicleList() {
    final vehicles = [
      {'plate': 'ABC-1234', 'desc': 'Isuzu Truck NQR 2021', 'owner': 'Juan Dela Cruz', 'odo': '45,000 km', 'status': 'Good'},
      {'plate': 'XYZ-5678', 'desc': 'Toyota Hilux 2020', 'owner': 'Pedro Santos', 'odo': '32,000 km', 'status': 'Maintenance'},
      {'plate': 'DEF-9012', 'desc': 'Mitsubishi L300 2019', 'owner': 'Jose Reyes', 'odo': '78,000 km', 'status': 'Overdue'},
    ];
    return Column(children: [
      _searchBar('Search vehicles...', () {}),
      Expanded(child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: vehicles.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final v = vehicles[i];
          final statusColor = v['status'] == 'Good' ? Colors.green : v['status'] == 'Maintenance' ? Colors.orange : _red;
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
            child: Row(children: [
              Container(width: 44, height: 44,
                decoration: BoxDecoration(color: const Color(0xFFF0F4FF), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.local_shipping_outlined, color: _red, size: 22)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(v['plate']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(v['desc']!, style: const TextStyle(fontSize: 12, color: Color(0xFF4a5568))),
                Text('${v['owner']} • ${v['odo']}', style: const TextStyle(fontSize: 11, color: Color(0xFF718096))),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(v['status']!, style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.w600)),
              ),
            ]),
          );
        },
      )),
    ]);
  }

  Widget _buildMaintenance() {
    final services = [
      {'id': 'SVC-001', 'plate': 'ABC-1234', 'mechanic': 'Juan', 'date': 'Mar 28', 'cost': '₱2,500', 'status': 'Completed'},
      {'id': 'SVC-002', 'plate': 'XYZ-5678', 'mechanic': 'Pedro', 'date': 'Mar 28', 'cost': '₱1,800', 'status': 'Ongoing'},
      {'id': 'SVC-003', 'plate': 'DEF-9012', 'mechanic': 'Jose', 'date': 'Mar 27', 'cost': '₱3,200', 'status': 'Pending'},
    ];
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          _miniStatInv('Total', '12', Colors.blue),
          const SizedBox(width: 8),
          _miniStatInv('Ongoing', '3', Colors.orange),
          const SizedBox(width: 8),
          _miniStatInv('Completed', '9', Colors.green),
        ]),
      ),
      Expanded(child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: services.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final s = services[i];
          final statusColor = s['status'] == 'Completed' ? Colors.green : s['status'] == 'Ongoing' ? Colors.orange : const Color(0xFF718096);
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
            child: Row(children: [
              Container(width: 4, height: 52, decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(4))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${s['id']} • ${s['plate']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text('Mechanic: ${s['mechanic']} • ${s['date']}', style: const TextStyle(fontSize: 11, color: Color(0xFF718096))),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(s['cost']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(s['status']!, style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.w600)),
                ),
              ]),
            ]),
          );
        },
      )),
    ]);
  }

  Widget _buildIssuances() {
    final issuances = [
      {'id': 'ISS-001', 'date': 'Mar 28, 2026', 'assetNum': 'AST-001', 'plate': 'ABC-1234', 'assetDesc': 'Isuzu Truck NQR 2021', 'itemNum': 'ITM-004', 'itemName': 'Oil Change Service', 'itemType': 'Service', 'commodityGroup': 'Labor', 'uom': 'job', 'qty': '1', 'unitCost': '500.00', 'subtotal': '500.00', 'createdBy': 'Admin'},
      {'id': 'ISS-002', 'date': 'Mar 28, 2026', 'assetNum': 'AST-001', 'plate': 'ABC-1234', 'assetDesc': 'Isuzu Truck NQR 2021', 'itemNum': 'ITM-001', 'itemName': 'Engine Oil 10W-40', 'itemType': 'Material', 'commodityGroup': 'Lubricants', 'uom': 'L', 'qty': '4', 'unitCost': '450.00', 'subtotal': '1800.00', 'createdBy': 'Admin'},
      {'id': 'ISS-003', 'date': 'Mar 28, 2026', 'assetNum': 'AST-001', 'plate': 'ABC-1234', 'assetDesc': 'Isuzu Truck NQR 2021', 'itemNum': 'ITM-002', 'itemName': 'Oil Filter', 'itemType': 'Material', 'commodityGroup': 'Filters', 'uom': 'pcs', 'qty': '1', 'unitCost': '180.00', 'subtotal': '180.00', 'createdBy': 'Admin'},
      {'id': 'ISS-004', 'date': 'Mar 27, 2026', 'assetNum': 'AST-002', 'plate': 'XYZ-5678', 'assetDesc': 'Toyota Hilux 2020', 'itemNum': 'ITM-003', 'itemName': 'Brake Pads', 'itemType': 'Material', 'commodityGroup': 'Brakes', 'uom': 'set', 'qty': '1', 'unitCost': '1200.00', 'subtotal': '1200.00', 'createdBy': 'Admin'},
    ];

    final totalServices = issuances.where((i) => i['itemType'] == 'Service').length;
    final totalMaterials = issuances.where((i) => i['itemType'] == 'Material').length;
    final totalValue = issuances.fold<double>(0, (sum, i) => sum + (double.tryParse(i['subtotal']!) ?? 0));

    return Column(children: [
      Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const Text('Vehicle Issuances', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1a202c))),
          const Text('Items issued per service transaction', style: TextStyle(fontSize: 12, color: Color(0xFF718096))),
          const SizedBox(height: 12),
          Row(children: [
            _issStatChip('Total', '${issuances.length}', Colors.blue),
            const SizedBox(width: 8),
            _issStatChip('Services', '$totalServices', const Color(0xFF003087)),
            const SizedBox(width: 8),
            _issStatChip('Materials', '$totalMaterials', Colors.green),
          ]),
        ]),
      ),
      Expanded(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: issuances.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final iss = issuances[i];
            final isService = iss['itemType'] == 'Service';
            final typeColor = isService ? const Color(0xFF003087) : _red;
            final typeBg = isService ? const Color(0xFFebf8ff) : const Color(0xFFfff5f5);
            return GestureDetector(
              onTap: () => _showIssuanceDetails(iss),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                ),
                child: Row(children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: typeBg, borderRadius: BorderRadius.circular(12)),
                    child: Icon(isService ? Icons.build_outlined : Icons.inventory_2_outlined, color: typeColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(iss['itemName']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text('${iss['plate']} • ${iss['assetDesc']}', style: const TextStyle(fontSize: 11, color: Color(0xFF4a5568))),
                    const SizedBox(height: 2),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: typeBg, borderRadius: BorderRadius.circular(20)),
                        child: Text(iss['itemType']!, style: TextStyle(fontSize: 9, color: typeColor, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 6),
                      Text(iss['date']!, style: const TextStyle(fontSize: 10, color: Color(0xFF718096))),
                    ]),
                  ])),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('₱${double.parse(iss['subtotal']!).toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1a202c))),
                    const SizedBox(height: 4),
                    Text('${iss['qty']} ${iss['uom']}',
                      style: const TextStyle(fontSize: 10, color: Color(0xFF718096))),
                  ]),
                ]),
              ),
            );
          },
        ),
      ),
    ]);
  }

  Widget _issStatChip(String label, String value, Color color) {
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

  void _showIssuanceDetails(Map<String, String> iss) {
    final isService = iss['itemType'] == 'Service';
    final typeColor = isService ? const Color(0xFF003087) : _red;
    final typeBg = isService ? const Color(0xFFebf8ff) : const Color(0xFFfff5f5);
    final subtotal = double.tryParse(iss['subtotal']!) ?? 0;
    final unitCost = double.tryParse(iss['unitCost']!) ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        expand: false, initialChildSize: 0.75, maxChildSize: 0.92,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          child: Column(children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              decoration: BoxDecoration(
                color: isService ? const Color(0xFF003087) : _red,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(iss['itemName']!, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                  Text(iss['itemNum']!, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ])),
                GestureDetector(onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                // Subtotal + Date banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFe2e8f0)),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Subtotal', style: TextStyle(color: Color(0xFF718096), fontSize: 10, fontWeight: FontWeight.w700)),
                      Text('₱${subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(color: Color(0xFF1a202c), fontSize: 22, fontWeight: FontWeight.w800)),
                    ]),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      const Text('Date', style: TextStyle(color: Color(0xFF718096), fontSize: 10, fontWeight: FontWeight.w700)),
                      Text(iss['date']!, style: const TextStyle(color: Color(0xFF1a202c), fontSize: 13, fontWeight: FontWeight.w700)),
                    ]),
                  ]),
                ),
                const SizedBox(height: 12),
                // Item Details
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFe2e8f0))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('📋  ITEM DETAILS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF718096), letterSpacing: 0.5)),
                    const SizedBox(height: 12),
                    _issGridRow('Item Number', iss['itemNum']!),
                    _issGridRow('Item Name', iss['itemName']!),
                    _issGridRow('Item Type', iss['itemType']!),
                    _issGridRow('Commodity Group', iss['commodityGroup']!),
                    _issGridRow('UOM', iss['uom']!),
                  ]),
                ),
                const SizedBox(height: 12),
                // Cost Breakdown
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFe2e8f0))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('💰  COST BREAKDOWN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF718096), letterSpacing: 0.5)),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: _costBox('Quantity', '${iss['qty']}', iss['uom']!, const Color(0xFFF7F8FA), const Color(0xFF1a202c))),
                      const SizedBox(width: 8),
                      Expanded(child: _costBox('Unit Cost', '₱${unitCost.toStringAsFixed(2)}', '', const Color(0xFFebf8ff), const Color(0xFF2b6cb0))),
                      const SizedBox(width: 8),
                      Expanded(child: _costBox('Subtotal', '₱${subtotal.toStringAsFixed(2)}', '', const Color(0xFFfff5f5), const Color(0xFFE8001C))),
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

  Widget _issGridRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 120, child: Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF718096), fontWeight: FontWeight.w600))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1a202c)))),
      ]),
    );
  }

  Widget _costBox(String label, String value, String sub, Color bg, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF718096), fontWeight: FontWeight.w700), textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: valueColor), textAlign: TextAlign.center),
        if (sub.isNotEmpty) Text(sub, style: const TextStyle(fontSize: 9, color: Color(0xFF718096))),
      ]),
    );
  }

  // ── MORE ──
  Widget _buildMore() {
    final items = [
      {
        'icon': Icons.smart_toy_outlined,
        'label': 'DSS',
        'sub': 'Decision Support System',
        'color': const Color(0xFF003087),
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDSS())),
      },
      {
        'icon': Icons.people_outline,
        'label': 'User Management',
        'sub': 'Manage system users',
        'color': Colors.teal,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUsers())),
      },
      {
        'icon': Icons.smart_toy_outlined,
        'label': 'Smart Reports',
        'sub': 'AI-powered reports',
        'color': Colors.purple,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminSmartReports())),
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 4),
        ...items.map((item) => GestureDetector(
          onTap: item['onTap'] as VoidCallback,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: (item['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item['label'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1a202c))),
                const SizedBox(height: 2),
                Text(item['sub'] as String, style: const TextStyle(fontSize: 12, color: Color(0xFF718096))),
              ])),
              const Icon(Icons.chevron_right, color: Color(0xFFcbd5e0), size: 20),
            ]),
          ),
        )),
      ]),
    );
  }

  // ── USERS ──
  Widget _buildUsersRedirect() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_currentIndex == 4) {
        Navigator.push(context,
          MaterialPageRoute(builder: (_) => const AdminUsers()))
          .then((_) => setState(() => _currentIndex = 0));
      }
    });
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildUsers() {
    final users = [
      {'name': 'Administrator', 'username': 'admin', 'role': 'Admin', 'status': 'Active'},
      {'name': 'Staff Member', 'username': 'staff', 'role': 'Staff', 'status': 'Active'},
      {'name': 'John Doe', 'username': 'customer', 'role': 'Customer', 'status': 'Active'},
    ];
    return Column(children: [
      _searchBar('Search users...', () {}),
      Expanded(child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final u = users[i];
          final roleColor = u['role'] == 'Admin' ? _red : u['role'] == 'Staff' ? Colors.blue : Colors.green;
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
            child: Row(children: [
              CircleAvatar(radius: 22, backgroundColor: roleColor.withOpacity(0.15),
                child: Text(u['name']![0], style: TextStyle(color: roleColor, fontWeight: FontWeight.bold))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(u['name']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text('@${u['username']}', style: const TextStyle(fontSize: 11, color: Color(0xFF718096))),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: roleColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(u['role']!, style: TextStyle(fontSize: 10, color: roleColor, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 4),
                const Text('Active', style: TextStyle(fontSize: 10, color: Colors.green)),
              ]),
            ]),
          );
        },
      )),
    ]);
  }

  void _showProfileSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        expand: false, initialChildSize: 0.75, maxChildSize: 0.92,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          child: Column(children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              decoration: const BoxDecoration(
                color: _red,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                const CircleAvatar(radius: 28, backgroundColor: Colors.white24,
                  child: Text('AD', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                const SizedBox(width: 14),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Administrator', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Super Admin', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ])),
                GestureDetector(onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                _profileCard('Account Info', [
                  _profileRow(Icons.person_outline, 'Full Name', 'Administrator'),
                  _profileRow(Icons.alternate_email, 'Email', 'admin@caltex.com'),
                  _profileRow(Icons.badge_outlined, 'Role', 'Super Admin'),
                ]),
                const SizedBox(height: 12),
                _profileCard('System Overview', [
                  _profileRow(Icons.directions_car_outlined, 'Total Vehicles', '24'),
                  _profileRow(Icons.people_outline, 'Total Users', '3'),
                  _profileRow(Icons.inventory_2_outlined, 'Inventory Items', '4'),
                  _profileRow(Icons.build_outlined, 'Services This Week', '18'),
                ]),
                const SizedBox(height: 20),
                SizedBox(width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushAndRemoveUntil(context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  )),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  // ── PROFILE ──
  Widget _buildProfile() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        const SizedBox(height: 12),
        const CircleAvatar(radius: 40, backgroundColor: _red,
          child: Text('AD', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
        const SizedBox(height: 12),
        const Text('Administrator', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Text('Super Admin', style: TextStyle(color: Color(0xFF718096))),
        const SizedBox(height: 20),
        _profileCard('Account Info', [
          _profileRow(Icons.person_outline, 'Full Name', 'Administrator'),
          _profileRow(Icons.alternate_email, 'Email', 'admin@caltex.com'),
          _profileRow(Icons.badge_outlined, 'Role', 'Super Admin'),
        ]),
        const SizedBox(height: 12),
        _profileCard('System Overview', [
          _profileRow(Icons.directions_car_outlined, 'Total Vehicles', '24'),
          _profileRow(Icons.people_outline, 'Total Users', '3'),
          _profileRow(Icons.inventory_2_outlined, 'Inventory Items', '4'),
          _profileRow(Icons.build_outlined, 'Services This Week', '18'),
        ]),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          )),
      ]),
    );
  }

  Widget _profileCard(String title, List<Widget> rows) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
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

  Widget _searchBar(String hint, VoidCallback onChanged) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search, size: 20),
          filled: true, fillColor: const Color(0xFFF7F8FA),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) =>
    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1a202c)));
}
