import 'package:flutter/material.dart';

class AdminInventoryItemMaster extends StatefulWidget {
  const AdminInventoryItemMaster({super.key});

  @override
  State<AdminInventoryItemMaster> createState() => _AdminInventoryItemMasterState();
}

class _AdminInventoryItemMasterState extends State<AdminInventoryItemMaster> {
  static const _red = Color(0xFFE8001C);

  final List<Map<String, String>> _items = [
    {'num': 'ITM-001', 'name': 'Engine Oil 10W-40', 'group': 'Lubricants', 'uom': 'L', 'cost': '₱450', 'type': 'Material'},
    {'num': 'ITM-002', 'name': 'Oil Filter', 'group': 'Filters', 'uom': 'pcs', 'cost': '₱180', 'type': 'Material'},
    {'num': 'ITM-003', 'name': 'Brake Pads', 'group': 'Brakes', 'uom': 'set', 'cost': '₱1,200', 'type': 'Material'},
    {'num': 'ITM-004', 'name': 'Oil Change Service', 'group': 'Labor', 'uom': 'job', 'cost': '₱500', 'type': 'Service'},
  ];

  List<Map<String, String>> _filtered = [];
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = List.from(_items);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      _filtered = _items.where((item) =>
        item['name']!.toLowerCase().contains(query.toLowerCase()) ||
        item['num']!.toLowerCase().contains(query.toLowerCase()) ||
        item['group']!.toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }

  bool _searching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemModal(),
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
                  hintText: 'Search items...',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
              )
            : const Text('Item Master',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_searching ? Icons.close : Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                _searching = !_searching;
                if (!_searching) {
                  _searchCtrl.clear();
                  _filtered = List.from(_items);
                }
              });
            },
          ),
        ],
      ),
      body: Column(children: [
        // Stats row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(children: [
            _statChip('Total Items', '${_items.length}', Colors.blue),
            const SizedBox(width: 8),
            _statChip('Materials', '${_items.where((i) => i['type'] == 'Material').length}', _red),
            const SizedBox(width: 8),
            _statChip('Services', '${_items.where((i) => i['type'] == 'Service').length}', const Color(0xFF003087)),
          ]),
        ),
        // List
        Expanded(
          child: _filtered.isEmpty
            ? const Center(child: Text('No items found.', style: TextStyle(color: Color(0xFF718096))))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _itemCard(_filtered[i]),
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
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF718096))),
        ]),
      ),
    );
  }

  Widget _itemCard(Map<String, String> item) {
    final isSvc = item['type'] == 'Service';
    return GestureDetector(
      onTap: () => _showItemDetails(item),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: isSvc ? const Color(0xFFebf8ff) : const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(10)),
            child: Icon(isSvc ? Icons.build_outlined : Icons.inventory_2_outlined,
              color: isSvc ? const Color(0xFF003087) : _red, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item['name']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text('${item['num']} • ${item['group']}', style: const TextStyle(fontSize: 11, color: Color(0xFF718096))),
            if ((item['desc'] ?? '').isNotEmpty)
              Text(item['desc']!, style: const TextStyle(fontSize: 11, color: Color(0xFF718096)),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(item['cost']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text('${item['uom']} • ${item['type']}', style: const TextStyle(fontSize: 10, color: Color(0xFF718096))),
          ]),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 18, color: Color(0xFF718096)),
            onSelected: (val) {
              if (val == 'edit') _showAddItemModal(item: item);
              if (val == 'delete') _confirmDelete(item);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 16), SizedBox(width: 8), Text('Edit')])),
              PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 16, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
            ],
          ),
        ]),
      ),
    );
  }

  void _showItemDetails(Map<String, String> item) {
    final isSvc = item['type'] == 'Service';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        expand: false, initialChildSize: 0.6, maxChildSize: 0.9,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          child: Column(children: [
            // Hero header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              decoration: BoxDecoration(
                color: isSvc ? const Color(0xFF003087) : _red,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Container(width: 48, height: 48,
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                    child: Icon(isSvc ? Icons.build_outlined : Icons.inventory_2_outlined, color: Colors.white, size: 24)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item['name']!, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(item['group'] ?? '—', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ])),
                  GestureDetector(onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.white)),
                ]),
              ]),
            ),
            // Details
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _detailRow('Item Number', item['num'] ?? '—'),
                _detailRow('SKU', item['sku']?.isNotEmpty == true ? item['sku']! : '—'),
                _detailRow('Item Name', item['name'] ?? '—'),
                _detailRow('Description', item['desc']?.isNotEmpty == true ? item['desc']! : '—'),
                _detailRow('Commodity Group', item['group']?.isNotEmpty == true ? item['group']! : '—'),
                _detailRow('UOM', item['uom']?.isNotEmpty == true ? item['uom']! : '—'),
                _detailRow('Cost', item['cost'] ?? '—'),
                _detailRow('Type', item['type'] ?? '—'),
                if (!isSvc) ...[
                  const Divider(height: 24),
                  const Text('Scan Codes', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF718096))),
                  const SizedBox(height: 8),
                  _detailRow('Barcode', item['barcode']?.isNotEmpty == true ? item['barcode']! : '—'),
                  _detailRow('QR Code', item['qr']?.isNotEmpty == true ? item['qr']! : '—'),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () { Navigator.pop(context); _showAddItemModal(item: item); },
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit'),
                  ),
                ),
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

  void _showAddItemModal({Map<String, String>? item}) {
    final isEdit = item != null;
    final numCtrl = TextEditingController(text: item?['num'] ?? 'ITM-${(_items.length + 1).toString().padLeft(3, '0')}');
    final skuCtrl = TextEditingController(text: item?['sku'] ?? '');
    final nameCtrl = TextEditingController(text: item?['name'] ?? '');
    final descCtrl = TextEditingController(text: item?['desc'] ?? '');
    final groupCtrl = TextEditingController(text: item?['group'] ?? '');
    final uomCtrl = TextEditingController(text: item?['uom'] ?? '');
    final costCtrl = TextEditingController(text: item?['cost']?.replaceAll('₱', '').replaceAll(',', '') ?? '');
    final barcodeCtrl = TextEditingController(text: item?['barcode'] ?? '');
    final qrCtrl = TextEditingController(text: item?['qr'] ?? '');
    String selectedType = item?['type'] ?? 'Material';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.85,
            maxChildSize: 0.95,
            builder: (_, ctrl) {
              return SingleChildScrollView(
                controller: ctrl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Red header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      decoration: const BoxDecoration(
                        color: _red,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                        Container(width: 44, height: 44,
                          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                          child: Icon(isEdit ? Icons.edit_outlined : Icons.add, color: Colors.white, size: 22)),
                        const SizedBox(width: 12),
                        Expanded(child: Text(isEdit ? 'Edit Item' : 'Add Item',
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close, color: Colors.white)),
                      ]),
                    ),
                    // Form
                    Padding(
                      padding: EdgeInsets.only(left: 20, right: 20, top: 20,
                        bottom: MediaQuery.of(context).viewInsets.bottom + 24),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        TextField(
                          controller: numCtrl,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Item Number',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Color(0xFFF7F8FA),
                            suffixIcon: Icon(Icons.lock_outline, size: 16, color: Color(0xFF718096)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(controller: nameCtrl,
                          decoration: const InputDecoration(labelText: 'Item Name *', border: OutlineInputBorder())),
                        const SizedBox(height: 10),
                        TextField(controller: skuCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'SKU', border: OutlineInputBorder(), hintText: 'e.g. 10001')),
                        const SizedBox(height: 10),
                        TextField(controller: descCtrl, maxLines: 2,
                          decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder(), hintText: 'Detailed description...')),
                        const SizedBox(height: 10),
                        Row(children: [
                          Expanded(child: TextField(controller: groupCtrl,
                            decoration: const InputDecoration(labelText: 'Commodity Group', border: OutlineInputBorder()))),
                          const SizedBox(width: 10),
                          Expanded(child: TextField(controller: uomCtrl,
                            decoration: const InputDecoration(labelText: 'UOM', border: OutlineInputBorder()))),
                        ]),
                        const SizedBox(height: 10),
                        Row(children: [
                          Expanded(child: TextField(controller: costCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Cost (₱)', border: OutlineInputBorder(), prefixText: '₱'))),
                          const SizedBox(width: 10),
                          Expanded(child: DropdownButtonFormField<String>(
                            value: selectedType,
                            decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                            items: const [
                              DropdownMenuItem(value: 'Material', child: Text('Material')),
                              DropdownMenuItem(value: 'Service', child: Text('Service')),
                            ],
                            onChanged: (v) => setModalState(() => selectedType = v!),
                          )),
                        ]),
                        if (selectedType == 'Material') ...[
                          const SizedBox(height: 10),
                          Row(children: [
                            Expanded(child: TextField(controller: barcodeCtrl,
                              decoration: InputDecoration(
                                labelText: 'Barcode',
                                border: const OutlineInputBorder(),
                                hintText: 'e.g. 1234567890',
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.auto_fix_high, size: 18),
                                  onPressed: () {
                                    barcodeCtrl.text = DateTime.now().millisecondsSinceEpoch.toString().substring(3);
                                    setModalState(() {});
                                  },
                                ),
                              ))),
                            const SizedBox(width: 10),
                            Expanded(child: TextField(controller: qrCtrl,
                              decoration: InputDecoration(
                                labelText: 'QR Code',
                                border: const OutlineInputBorder(),
                                hintText: 'e.g. QR-ITM-001',
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.auto_fix_high, size: 18),
                                  onPressed: () {
                                    qrCtrl.text = 'QR-${numCtrl.text}';
                                    setModalState(() {});
                                  },
                                ),
                              ))),
                          ]),
                        ],
                        const SizedBox(height: 20),
                        Row(children: [
                          Expanded(child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'))),
                          const SizedBox(width: 12),
                          Expanded(child: ElevatedButton(
                            onPressed: () {
                              if (nameCtrl.text.trim().isEmpty) return;
                              setState(() {
                                final newItem = {
                                  'num': numCtrl.text,
                                  'sku': skuCtrl.text.trim(),
                                  'name': nameCtrl.text.trim(),
                                  'desc': descCtrl.text.trim(),
                                  'group': groupCtrl.text.trim(),
                                  'uom': uomCtrl.text.trim(),
                                  'cost': '₱${costCtrl.text.trim()}',
                                  'type': selectedType,
                                  'barcode': selectedType == 'Material' ? barcodeCtrl.text.trim() : '',
                                  'qr': selectedType == 'Material' ? qrCtrl.text.trim() : '',
                                };
                                if (isEdit) {
                                  final idx = _items.indexWhere((e) => e['num'] == item!['num']);
                                  if (idx != -1) _items[idx] = newItem;
                                } else {
                                  _items.add(newItem);
                                }
                                _filtered = List.from(_items);
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: _red, foregroundColor: Colors.white),
                            child: Text(isEdit ? '💾 Update' : '💾 Save'),
                          )),
                        ]),
                      ]),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(Map<String, String> item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item['name']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() {
                _items.removeWhere((e) => e['num'] == item['num']);
                _filtered = List.from(_items);
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
