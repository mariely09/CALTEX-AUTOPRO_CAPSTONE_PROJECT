import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StaffVehicleList extends StatefulWidget {
  const StaffVehicleList({super.key});

  @override
  State<StaffVehicleList> createState() => _StaffVehicleListState();
}

class _StaffVehicleListState extends State<StaffVehicleList> {
  static const _red = Color(0xFFE8001C);
  static const _col = 'vehicles';

  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  bool _searching = false;
  List<String>? _cachedTypes;

  CollectionReference get _db => FirebaseFirestore.instance.collection(_col);

  Future<List<String>> _fetchVehicleTypes() async {
    if (_cachedTypes != null) return _cachedTypes!;
    final snap = await FirebaseFirestore.instance
        .collection('domains').doc('vehicle_types').collection('items')
        .orderBy('name').get();
    _cachedTypes = snap.docs.map((d) => d['name'] as String).toList();
    return _cachedTypes!;
  }

  String _computeStatus(String lastSvcDate, String svcFreq) {
    if (lastSvcDate.isEmpty || svcFreq.isEmpty) return 'Active';
    final date = DateTime.tryParse(lastSvcDate);
    final months = int.tryParse(svcFreq);
    if (date == null || months == null) return 'Active';
    final nextPms = DateTime(date.year, date.month + months, date.day);
    final now = DateTime.now();
    final daysUntil = nextPms.difference(now).inDays;
    if (daysUntil < 0) return 'Overdue';
    if (daysUntil <= 30) return 'PMS Due Soon';
    return 'Active';
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Active': return Colors.green;
      case 'Under Maintenance': return Colors.orange;
      case 'Overdue': return _red;
      case 'PMS Due Soon': return Colors.amber.shade700;
      case 'Completed': return const Color(0xFF003087);
      default: return Colors.grey;
    }
  }

  String _calcNextPms(String lastSvcDate, String svcFreq) {
    if (lastSvcDate.isEmpty || svcFreq.isEmpty) return '—';
    final date = DateTime.tryParse(lastSvcDate);
    final months = int.tryParse(svcFreq);
    if (date == null || months == null) return '—';
    final next = DateTime(date.year, date.month + months, date.day);
    return '${next.year}-${next.month.toString().padLeft(2, '0')}-${next.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddVehicleModal(),
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
                onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search vehicles...',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
              )
            : const Text('Vehicle List',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_searching ? Icons.close : Icons.search, color: Colors.white),
            onPressed: () => setState(() {
              _searching = !_searching;
              if (!_searching) { _searchCtrl.clear(); _searchQuery = ''; }
            }),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 40),
              const SizedBox(height: 8),
              Text('Error: ${snapshot.error}', textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 12)),
            ]));
          }

          final docs = snapshot.data?.docs ?? [];
          final vehicles = docs.map((d) {
            final data = d.data() as Map<String, dynamic>;
            return {
              'id': d.id,
              'plate': data['plate'] as String? ?? '',
              'desc': data['desc'] as String? ?? '',
              'owner': data['owner'] as String? ?? '',
              'odo': data['odo'] as String? ?? '',
              'type': data['type'] as String? ?? '',
              'status': data['status'] as String? ?? 'Active',
              'lastSvcOdo': data['lastSvcOdo'] as String? ?? '',
              'lastSvcDate': data['lastSvcDate'] as String? ?? '',
              'svcFreq': data['svcFreq'] as String? ?? '',
            };
          }).toList()
            ..sort((a, b) => (a['plate'] as String).compareTo(b['plate'] as String));

          final filtered = _searchQuery.isEmpty
              ? vehicles
              : vehicles.where((v) =>
                  v['plate']!.toLowerCase().contains(_searchQuery) ||
                  v['desc']!.toLowerCase().contains(_searchQuery) ||
                  v['owner']!.toLowerCase().contains(_searchQuery)).toList();

          final good = vehicles.where((v) => v['status'] == 'Active').length;
          final maint = vehicles.where((v) => v['status'] == 'Under Maintenance').length;
          final overdue = vehicles.where((v) => v['status'] == 'Overdue').length;

          return Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(children: [
                _statChip('Total', '${vehicles.length}', Colors.blue),
                const SizedBox(width: 8),
                _statChip('Active', '$good', Colors.green),
                const SizedBox(width: 8),
                _statChip('Maintenance', '$maint', Colors.orange),
                const SizedBox(width: 8),
                _statChip('Overdue', '$overdue', _red),
              ]),
            ),
            Expanded(
              child: filtered.isEmpty
                ? const Center(child: Text('No vehicles found.', style: TextStyle(color: Color(0xFF718096))))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _vehicleCard(filtered[i]),
                  ),
            ),
          ]);
        },
      ),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
        ),
        child: Column(children: [
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF718096))),
        ]),
      ),
    );
  }

  Widget _vehicleCard(Map<String, String> v) {
    final sc = _statusColor(v['status']!);
    final isTruck = v['type']?.toLowerCase() == 'truck';
    return GestureDetector(
      onTap: () => _showVehicleDetails(v),
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
            decoration: BoxDecoration(color: const Color(0xFFF0F4FF), borderRadius: BorderRadius.circular(12)),
            child: Icon(
              isTruck ? Icons.local_shipping_outlined : Icons.directions_car_outlined,
              color: _red, size: 22,
            ),
          ),
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
    final isTruck = v['type']?.toLowerCase() == 'truck';
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
            decoration: const BoxDecoration(
              color: _red,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(v['plate']!, style: const TextStyle(
                  color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1)),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white)),
              ]),
              const SizedBox(height: 6),
              Text(v['desc']!, style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            ]),
          ),
          // Stats strip
          Container(
            color: Colors.white,
            child: Row(children: [
              _statStrip('🛣️ Odometer', v['odo']!.isNotEmpty ? v['odo']! : '—', _red),
              _divider(),
              _statStrip('🔧 Last Service', v['lastSvcDate']!.isNotEmpty ? v['lastSvcDate']! : '—', const Color(0xFF1a202c)),
              _divider(),
              _statStrip('📅 Next PMS', _calcNextPms(v['lastSvcDate']!, v['svcFreq']!), const Color(0xFF1a202c)),
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
                    _infoCell('Owner', v['owner']!.isNotEmpty ? v['owner']! : '—'),
                    _infoCell('Type', v['type']!.isNotEmpty ? v['type']! : '—'),
                    _infoCell('Plate Number', v['plate']!),
                    _infoCell('Odometer', v['odo']!.isNotEmpty ? v['odo']! : '—'),
                  ]),
                ]),
                const SizedBox(height: 12),
                _sectionCard('🔧 Maintenance Info', [
                  _infoGrid([
                    _infoCell('Last Svc Date', v['lastSvcDate']!.isNotEmpty ? v['lastSvcDate']! : '—'),
                    _infoCell('Last Svc Odo', v['lastSvcOdo']!.isNotEmpty ? '${v['lastSvcOdo']} km' : '—'),
                    _infoCell('Svc Frequency', v['svcFreq']!.isNotEmpty ? '${v['svcFreq']} months' : '—'),
                    _infoCell('Next PMS', _calcNextPms(v['lastSvcDate']!, v['svcFreq']!)),
                  ]),
                ]),
                const SizedBox(height: 12),
                _sectionCard('📋 Status', [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _statusColor(v['status']!).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(v['status']!, style: TextStyle(
                        fontSize: 13, color: _statusColor(v['status']!), fontWeight: FontWeight.w700)),
                    ),
                  ]),
                ]),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () { Navigator.pop(context); _showAddVehicleModal(vehicle: v); },
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit Vehicle'),
                  ),
                ),
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
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFe2e8f0)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(
        fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF718096), letterSpacing: 0.4)),
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
    decoration: BoxDecoration(
      color: const Color(0xFFF7F8FA),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFe2e8f0)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF718096), fontWeight: FontWeight.w700)),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1a202c))),
    ]),
  );

  void _showAddVehicleModal({Map<String, String>? vehicle}) async {
    final isEdit = vehicle != null;
    final types = await _fetchVehicleTypes();
    if (!mounted) return;

    final plateCtrl = TextEditingController(text: vehicle?['plate'] ?? '');
    final descCtrl = TextEditingController(text: vehicle?['desc'] ?? '');
    final ownerCtrl = TextEditingController(text: vehicle?['owner'] ?? '');
    final odoCtrl = TextEditingController(text: vehicle?['odo']?.replaceAll(' km', '').replaceAll(',', '') ?? '');
    final lastSvcOdoCtrl = TextEditingController(text: vehicle?['lastSvcOdo'] ?? '');
    final lastSvcDateCtrl = TextEditingController(text: vehicle?['lastSvcDate'] ?? '');
    final svcFreqCtrl = TextEditingController(text: vehicle?['svcFreq'] ?? '');
    String? selectedType = (vehicle?['type']?.isNotEmpty == true && types.contains(vehicle!['type'])) ? vehicle['type'] : null;

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setModal) => AnimatedPadding(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                decoration: const BoxDecoration(color: _red,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                child: Row(children: [
                  Container(width: 44, height: 44,
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                    child: Icon(isEdit ? Icons.edit_outlined : Icons.add, color: Colors.white, size: 22)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(isEdit ? 'Edit Vehicle' : 'Add Vehicle',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                  GestureDetector(onTap: () => Navigator.pop(sheetCtx),
                    child: const Icon(Icons.close, color: Colors.white)),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  TextField(controller: plateCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(labelText: 'Plate Number *', border: OutlineInputBorder(), hintText: 'e.g. ABC-1234')),
                  const SizedBox(height: 10),
                  TextField(controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'Description *', border: OutlineInputBorder(), hintText: 'e.g. Isuzu Truck NQR 2021')),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Vehicle Type *', border: OutlineInputBorder()),
                    hint: const Text('Select type'),
                    items: types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) => setModal(() => selectedType = v),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 10),
                  _OwnerAutocomplete(controller: ownerCtrl),
                  const SizedBox(height: 10),
                  TextField(controller: odoCtrl, keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Current Odometer (km)', border: OutlineInputBorder(), suffixText: 'km')),
                  const SizedBox(height: 10),
                  TextField(controller: lastSvcOdoCtrl, keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Last Service Odometer (km)', border: OutlineInputBorder(), suffixText: 'km')),
                  const SizedBox(height: 10),
                  TextField(controller: lastSvcDateCtrl,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Last Service Date',
                      border: OutlineInputBorder(),
                      hintText: 'Select date',
                      suffixIcon: Icon(Icons.calendar_today_outlined, size: 18),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: sheetCtx,
                        initialDate: DateTime.tryParse(lastSvcDateCtrl.text) ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        lastSvcDateCtrl.text =
                          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: svcFreqCtrl, keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Service Frequency (months)', border: OutlineInputBorder(), hintText: 'e.g. 3')),
                  const SizedBox(height: 20),
                  Row(children: [
                    Expanded(child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetCtx),
                      child: const Text('Cancel'))),
                    const SizedBox(width: 12),
                    Expanded(child: ElevatedButton(
                      onPressed: () async {
                        if (plateCtrl.text.trim().isEmpty) return;
                        final data = <String, dynamic>{
                          'plate': plateCtrl.text.trim().toUpperCase(),
                          'desc': descCtrl.text.trim(),
                          'owner': ownerCtrl.text.trim(),
                          'odo': odoCtrl.text.trim().isNotEmpty ? '${odoCtrl.text.trim()} km' : '',
                          'lastSvcOdo': lastSvcOdoCtrl.text.trim(),
                          'lastSvcDate': lastSvcDateCtrl.text.trim(),
                          'svcFreq': svcFreqCtrl.text.trim(),
                          'type': selectedType ?? '',
                          if (!isEdit) 'status': _computeStatus(lastSvcDateCtrl.text.trim(), svcFreqCtrl.text.trim()),
                        };
                        try {
                          if (isEdit) {
                            await _db.doc(vehicle!['id']).update(data);
                            if (sheetCtx.mounted) {
                              Navigator.pop(sheetCtx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(children: const [
                                    Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                                    SizedBox(width: 8),
                                    Text('Vehicle updated successfully!'),
                                  ]),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            }
                          } else {
                            final existing = await _db
                                .where('plate', isEqualTo: plateCtrl.text.trim().toUpperCase())
                                .limit(1).get();
                            if (existing.docs.isNotEmpty) {
                              if (sheetCtx.mounted) ScaffoldMessenger.of(sheetCtx).showSnackBar(
                                const SnackBar(
                                  content: Text('A vehicle with this plate number already exists.'),
                                  backgroundColor: Colors.orange));
                              return;
                            }
                            data['createdAt'] = FieldValue.serverTimestamp();
                            await _db.add(data);
                            if (sheetCtx.mounted) {
                              Navigator.pop(sheetCtx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(children: const [
                                    Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                                    SizedBox(width: 8),
                                    Text('Vehicle added successfully!'),
                                  ]),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (sheetCtx.mounted) ScaffoldMessenger.of(sheetCtx).showSnackBar(
                            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                        }
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
}

class _OwnerAutocomplete extends StatefulWidget {
  final TextEditingController controller;
  const _OwnerAutocomplete({required this.controller});

  @override
  State<_OwnerAutocomplete> createState() => _OwnerAutocompleteState();
}

class _OwnerAutocompleteState extends State<_OwnerAutocomplete> {
  List<String> _allNames = [];
  List<String> _suggestions = [];
  OverlayEntry? _overlay;
  final _layerLink = LayerLink();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadAllNames();
    widget.controller.addListener(_onChanged);
    _focusNode.addListener(() { if (!_focusNode.hasFocus) _removeOverlay(); });
  }

  Future<void> _loadAllNames() async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'customer')
        .get();
    if (!mounted) return;
    _allNames = snap.docs
        .map((d) => d['name'] as String? ?? '')
        .where((n) => n.isNotEmpty)
        .toList()
      ..sort();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onChanged() {
    final q = widget.controller.text.trim().toLowerCase();
    if (q.isEmpty) { _removeOverlay(); return; }
    final matches = _allNames
        .where((n) => n.toLowerCase().contains(q))
        .take(6)
        .toList();
    setState(() => _suggestions = matches);
    if (matches.isEmpty) { _removeOverlay(); return; }
    _showOverlay();
  }

  void _showOverlay() {
    _removeOverlay();
    _overlay = OverlayEntry(
      builder: (_) => Positioned(
        width: 300,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 58),
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) => ListTile(
                  dense: true,
                  leading: const CircleAvatar(
                    radius: 14,
                    backgroundColor: Color(0xFFF0F4FF),
                    child: Icon(Icons.person_outline, size: 16, color: Color(0xFF003087)),
                  ),
                  title: Text(_suggestions[i], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  onTap: () {
                    widget.controller.text = _suggestions[i];
                    widget.controller.selection = TextSelection.collapsed(offset: _suggestions[i].length);
                    _removeOverlay();
                    _focusNode.unfocus();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlay!);
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        decoration: const InputDecoration(
          labelText: 'Owner *',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.person_search_outlined, size: 20, color: Color(0xFF718096)),
        ),
      ),
    );
  }
}
