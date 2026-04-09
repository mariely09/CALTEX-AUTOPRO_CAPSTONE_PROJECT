import 'package:flutter/material.dart';

class StaffVehicleList extends StatefulWidget {
  const StaffVehicleList({super.key});

  @override
  State<StaffVehicleList> createState() => _StaffVehicleListState();
}

class _StaffVehicleListState extends State<StaffVehicleList> {
  static const _red = Color(0xFFE8001C);

  final List<Map<String, String>> _vehicles = [
    {'plate': 'ABC-1234', 'desc': 'Isuzu Truck NQR 2021', 'owner': 'Juan Dela Cruz', 'odo': '45,000 km', 'type': 'truck', 'status': 'Active'},
    {'plate': 'XYZ-5678', 'desc': 'Toyota Hilux 2020', 'owner': 'Pedro Santos', 'odo': '32,000 km', 'type': 'car', 'status': 'Under Maintenance'},
    {'plate': 'DEF-9012', 'desc': 'Mitsubishi L300 2019', 'owner': 'Jose Reyes', 'odo': '78,000 km', 'type': 'truck', 'status': 'Overdue'},
  ];

  List<Map<String, String>> _filtered = [];
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = List.from(_vehicles);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String q) {
    setState(() {
      _filtered = _vehicles.where((v) =>
        v['plate']!.toLowerCase().contains(q.toLowerCase()) ||
        v['desc']!.toLowerCase().contains(q.toLowerCase()) ||
        v['owner']!.toLowerCase().contains(q.toLowerCase())
      ).toList();
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Active': return Colors.green;
      case 'Under Maintenance': return Colors.orange;
      case 'Overdue': return _red;
      case 'PMS Due Soon': return Colors.amber.shade700;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final good = _vehicles.where((v) => v['status'] == 'Active').length;
    final maint = _vehicles.where((v) => v['status'] == 'Under Maintenance').length;
    final overdue = _vehicles.where((v) => v['status'] == 'Overdue').length;

    return Stack(children: [
      Column(children: [
      Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const Text('Vehicle List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1a202c))),
          const Text('Registered vehicles', style: TextStyle(fontSize: 12, color: Color(0xFF718096))),
          const SizedBox(height: 12),
          TextField(
            controller: _searchCtrl,
            onChanged: _onSearch,
            decoration: InputDecoration(
              hintText: 'Search vehicles...',
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true, fillColor: const Color(0xFFF7F8FA),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Row(children: [
          _statChip('Total', '${_vehicles.length}', Colors.blue),
          const SizedBox(width: 8),
          _statChip('Active', '$good', Colors.green),
          const SizedBox(width: 8),
          _statChip('Maintenance', '$maint', Colors.orange),
          const SizedBox(width: 8),
          _statChip('Overdue', '$overdue', _red),
        ]),
      ),
      Expanded(
        child: _filtered.isEmpty
          ? const Center(child: Text('No vehicles found.', style: TextStyle(color: Color(0xFF718096))))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _vehicleCard(_filtered[i]),
            ),
      ),
      ]),
      // FAB
      Positioned(
        bottom: 16, right: 16,
        child: FloatingActionButton(
          onPressed: () => _showAddVehicleModal(),
          backgroundColor: _red,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    ]);
  }

  void _showAddVehicleModal({Map<String, String>? vehicle}) {
    final isEdit = vehicle != null;
    final plateCtrl = TextEditingController(text: vehicle?['plate'] ?? '');
    final descCtrl = TextEditingController(text: vehicle?['desc'] ?? '');
    final ownerCtrl = TextEditingController(text: vehicle?['owner'] ?? '');
    final odoCtrl = TextEditingController(text: vehicle?['odo']?.replaceAll(' km', '').replaceAll(',', '') ?? '');
    String selectedType = vehicle?['type'] ?? 'truck';

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => DraggableScrollableSheet(
          expand: false, initialChildSize: 0.85, maxChildSize: 0.95,
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
                    child: Icon(isEdit ? Icons.edit_outlined : Icons.add, color: Colors.white, size: 22)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(isEdit ? 'Edit Vehicle' : 'Add Vehicle',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                  GestureDetector(onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.white)),
                ]),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  TextField(controller: plateCtrl, textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(labelText: 'Plate Number *', border: OutlineInputBorder(), hintText: 'e.g. ABC-1234')),
                  const SizedBox(height: 10),
                  TextField(controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'Description *', border: OutlineInputBorder(), hintText: 'e.g. Isuzu Truck NQR 2021')),
                  const SizedBox(height: 10),
                  TextField(controller: ownerCtrl,
                    decoration: const InputDecoration(labelText: 'Owner *', border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  TextField(controller: odoCtrl, keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Current Odometer (km) *', border: OutlineInputBorder(), suffixText: 'km')),
                  const SizedBox(height: 10),
                  TextField(keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Last Service Odometer (km)', border: OutlineInputBorder(), suffixText: 'km')),
                  const SizedBox(height: 10),
                  TextField(keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Service Frequency (months) *', border: OutlineInputBorder(), hintText: 'e.g. 3')),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(border: Border.all(color: const Color(0xFFbdbdbd)), borderRadius: BorderRadius.circular(4)),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButton<String>(
                      value: selectedType, isExpanded: true, underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'truck', child: Text('🚛 Truck')),
                        DropdownMenuItem(value: 'car', child: Text('🚗 Car')),
                      ],
                      onChanged: (v) => setModal(() => selectedType = v!),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(children: [
                    Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
                    const SizedBox(width: 12),
                    Expanded(child: ElevatedButton(
                      onPressed: () {
                        if (plateCtrl.text.trim().isEmpty) return;
                        setState(() {
                          final newV = {
                            'plate': plateCtrl.text.trim().toUpperCase(),
                            'desc': descCtrl.text.trim(),
                            'owner': ownerCtrl.text.trim(),
                            'odo': '${odoCtrl.text.trim()} km',
                            'type': selectedType,
                            'status': 'Active',
                          };
                          if (isEdit) {
                            final idx = _vehicles.indexWhere((e) => e['plate'] == vehicle!['plate']);
                            if (idx != -1) _vehicles[idx] = newV;
                          } else {
                            _vehicles.add(newV);
                          }
                          _filtered = List.from(_vehicles);
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
        ),
      ),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
        child: Column(children: [
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF718096))),
        ]),
      ),
    );
  }

  Widget _vehicleCard(Map<String, String> v) {
    final sc = _statusColor(v['status']!);
    final isTruck = v['type'] == 'truck';
    return GestureDetector(
      onTap: () => _showVehicleDetails(v),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
        child: Row(children: [
          Container(width: 44, height: 44,
            decoration: BoxDecoration(color: const Color(0xFFF0F4FF), borderRadius: BorderRadius.circular(12)),
            child: Icon(isTruck ? Icons.local_shipping_outlined : Icons.directions_car_outlined, color: _red, size: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(v['plate']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(v['desc']!, style: const TextStyle(fontSize: 12, color: Color(0xFF4a5568))),
            Text('${v['owner']} • ${v['odo']}', style: const TextStyle(fontSize: 11, color: Color(0xFF718096))),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: sc.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(v['status']!, style: TextStyle(fontSize: 10, color: sc, fontWeight: FontWeight.w600)),
          ),
        ]),
      ),
    );
  }

  void _showVehicleDetails(Map<String, String> v) {
    final isTruck = v['type'] == 'truck';
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        expand: false, initialChildSize: 0.75, maxChildSize: 0.92,
        builder: (_, ctrl) => Column(children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: const BoxDecoration(color: _red, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(v['plate']!, style: const TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1)),
                GestureDetector(onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white)),
              ]),
              const SizedBox(height: 6),
              Text(v['desc']!, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            ]),
          ),
          // Stats strip
          Container(
            color: Colors.white,
            child: Row(children: [
              _statStrip('🛣️ Odometer', v['odo'] ?? '—', _red),
              _divider(),
              _statStrip('🔧 Last Service', v['lastService'] ?? '—', const Color(0xFF1a202c)),
              _divider(),
              _statStrip('📅 Next PMS', v['nextPms'] ?? '—', const Color(0xFF1a202c)),
            ]),
          ),
          const Divider(height: 1, color: Color(0xFFf0f4f8)),
          // Body
          Expanded(
            child: SingleChildScrollView(
              controller: ctrl,
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                _sectionCard('🚗 Vehicle Information', [
                  _infoGrid([
                    _infoCell('Owner', v['owner'] ?? '—'),
                    _infoCell('Type', isTruck ? 'Truck' : 'Car'),
                    _infoCell('Plate Number', v['plate'] ?? '—'),
                    _infoCell('Odometer', v['odo'] ?? '—'),
                  ]),
                ]),
                const SizedBox(height: 12),
                _sectionCard('🔧 Maintenance Summary', [
                  Row(children: [
                    Expanded(child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: const Color(0xFFF7F8FA), borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFe2e8f0))),
                      child: const Column(children: [
                        Text('TOTAL SERVICES', style: TextStyle(fontSize: 9, color: Color(0xFF718096), fontWeight: FontWeight.w700)),
                        SizedBox(height: 4),
                        Text('0', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF1a202c))),
                      ]),
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFfff5f5), Color(0xFFfed7d7)]),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFfeb2b2))),
                      child: const Column(children: [
                        Text('TOTAL COST', style: TextStyle(fontSize: 9, color: Color(0xFFc53030), fontWeight: FontWeight.w700)),
                        SizedBox(height: 4),
                        Text('₱0', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: _red)),
                      ]),
                    )),
                  ]),
                ]),
                const SizedBox(height: 12),
                _sectionCard('📋 Maintenance History', [
                  const Center(child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('No maintenance records yet.', style: TextStyle(color: Color(0xFF718096), fontSize: 13)),
                  )),
                ]),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _statStrip(String label, String value, Color valueColor) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(children: [
        Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFFa0aec0), fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: valueColor)),
      ]),
    ),
  );

  Widget _divider() => Container(width: 1, height: 40, color: const Color(0xFFf0f4f8));

  Widget _sectionCard(String title, List<Widget> children) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFe2e8f0))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF718096), letterSpacing: 0.4)),
      const SizedBox(height: 12),
      ...children,
    ]),
  );

  Widget _infoGrid(List<Widget> cells) => GridView.count(
    crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
    crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 2.5,
    children: cells,
  );

  Widget _infoCell(String label, String value) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: const Color(0xFFF7F8FA), borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFe2e8f0))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF718096), fontWeight: FontWeight.w700)),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1a202c))),
    ]),
  );
}
