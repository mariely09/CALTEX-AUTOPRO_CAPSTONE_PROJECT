import 'package:flutter/material.dart';
import 'barcode_scanner_screen.dart';

class AdminInventoryStock extends StatefulWidget {
  const AdminInventoryStock({super.key});

  @override
  State<AdminInventoryStock> createState() => _AdminInventoryStockState();
}

class _AdminInventoryStockState extends State<AdminInventoryStock> {
  static const _red = Color(0xFFE8001C);

  final List<Map<String, dynamic>> _items = [
    {'name': 'Engine Oil 10W-40', 'num': 'ITM-001', 'group': 'Lubricants', 'stock': 24, 'min': 10, 'max': 50, 'reorder': 20, 'unit': 'L', 'status': 'OK'},
    {'name': 'Oil Filter', 'num': 'ITM-002', 'group': 'Filters', 'stock': 3, 'min': 5, 'max': 20, 'reorder': 10, 'unit': 'pcs', 'status': 'Low'},
    {'name': 'Brake Pads', 'num': 'ITM-003', 'group': 'Brakes', 'stock': 8, 'min': 4, 'max': 20, 'reorder': 8, 'unit': 'set', 'status': 'OK'},
    {'name': 'Air Filter', 'num': 'ITM-004', 'group': 'Filters', 'stock': 2, 'min': 5, 'max': 15, 'reorder': 10, 'unit': 'pcs', 'status': 'Low'},
  ];

  List<Map<String, dynamic>> _filtered = [];
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

  void _onSearch(String q) {
    setState(() {
      _filtered = _items.where((i) =>
        (i['name'] as String).toLowerCase().contains(q.toLowerCase()) ||
        (i['num'] as String).toLowerCase().contains(q.toLowerCase()) ||
        (i['group'] as String).toLowerCase().contains(q.toLowerCase())
      ).toList();
    });
  }

  int get _lowCount => _items.where((i) => i['status'] == 'Low').length;

  bool _searching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showActionChoice(),
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
            : const Text('Stock Inventory',
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
        // Stats
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(children: [
            _statChip('Total Items', '${_items.length}', Colors.blue),
            const SizedBox(width: 8),
            _statChip('Low Stock', '$_lowCount', _red),
            const SizedBox(width: 8),
            _statChip('Total Value', '₱52K', Colors.green),
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
                itemBuilder: (_, i) => _stockCard(_filtered[i]),
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

  Widget _stockCard(Map<String, dynamic> item) {
    final isLow = item['status'] == 'Low';
    final stock = item['stock'] as int;
    final min = item['min'] as int;
    final max = item['max'] as int;
    final isOverMax = stock > max;
    // progress: clamp to 1.0 but show over-max visually
    final progress = (stock / max).clamp(0.0, 1.0);
    // color logic: low=orange, over max=purple, in stock=green
    final barColor = isLow ? Colors.orange : isOverMax ? Colors.purple : Colors.green;
    final statusLabel = isLow ? 'Low Stock' : isOverMax ? 'Over Max' : 'In Stock';
    final statusColor = isLow ? Colors.orange : isOverMax ? Colors.purple : Colors.green;

    return GestureDetector(
      onTap: () => _showStockDetails(item),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isLow ? Border.all(color: Colors.orange.shade200)
            : isOverMax ? Border.all(color: Colors.purple.shade200) : null,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 42, height: 42,
              decoration: BoxDecoration(
                color: isLow ? Colors.orange.shade50 : isOverMax ? Colors.purple.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.inventory_2_outlined, color: barColor, size: 20)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Text('${item['num']} • ${item['group']}', style: const TextStyle(fontSize: 11, color: Color(0xFF718096))),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('$stock ${item['unit']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,
                color: statusColor)),
              Text(statusLabel, style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.w500)),
            ]),
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 18, color: Color(0xFF718096)),
              onSelected: (val) {
                if (val == 'edit') _showAddStockModal(item: item);
                if (val == 'delete') _confirmDelete(item);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 16), SizedBox(width: 8), Text('Edit')])),
                PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 16, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
              ],
            ),
          ]),
          const SizedBox(height: 10),
          // Stock level bar
          Stack(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: const Color(0xFFe2e8f0),
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
                minHeight: 6,
              ),
            ),
            // Over-max indicator: small overflow marker at the end
            if (isOverMax)
              Positioned(
                right: 0, top: 0, bottom: 0,
                child: Container(width: 6, decoration: BoxDecoration(color: Colors.purple, borderRadius: BorderRadius.circular(4))),
              ),
          ]),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Min: $min', style: const TextStyle(fontSize: 10, color: Color(0xFF718096))),
            Text('$stock / $max', style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.w500)),
            Text('Max: $max', style: const TextStyle(fontSize: 10, color: Color(0xFF718096))),
          ]),
        ]),
      ),
    );
  }

  void _showActionChoice() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('What would you like to do?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1a202c))),
          const SizedBox(height: 6),
          const Text('Choose an action below', style: TextStyle(fontSize: 12, color: Color(0xFF718096))),
          const SizedBox(height: 20),
          // Receive Items
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              _showReceiveModal(null);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFebf8ff),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF90cdf4)),
              ),
              child: Row(children: [
                Container(width: 48, height: 48,
                  decoration: BoxDecoration(color: const Color(0xFF003087), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.download_outlined, color: Colors.white, size: 24)),
                const SizedBox(width: 14),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Receive Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1a202c))),
                  Text('Update stock from delivery', style: TextStyle(fontSize: 12, color: Color(0xFF718096))),
                ])),
                const Icon(Icons.chevron_right, color: Color(0xFF718096)),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          // Add Stock Item
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              _showAddStockModal();
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFbee3f8)),
              ),
              child: Row(children: [
                Container(width: 48, height: 48,
                  decoration: BoxDecoration(color: _red, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.add_box_outlined, color: Colors.white, size: 24)),
                const SizedBox(width: 14),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Add Stock Item', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1a202c))),
                  Text('Add a new item to inventory', style: TextStyle(fontSize: 12, color: Color(0xFF718096))),
                ])),
                const Icon(Icons.chevron_right, color: Color(0xFF718096)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  void _showStockDetails(Map<String, dynamic> item) {
    final isLow = item['status'] == 'Low';
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        expand: false, initialChildSize: 0.55, maxChildSize: 0.85,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          child: Column(children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              decoration: const BoxDecoration(
                color: _red,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Container(width: 44, height: 44,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 22)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(item['group'] as String, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ])),
                GestureDetector(onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _detailRow('Item Number', item['num'] as String),
                _detailRow('Item Name', item['name'] as String),
                _detailRow('Commodity Group', item['group'] as String),
                _detailRow('Current Stock', '${item['stock']} ${item['unit']}'),
                _detailRow('Minimum Level', '${item['min']} ${item['unit']}'),
                _detailRow('Maximum Level', '${item['max']} ${item['unit']}'),
                _detailRow('Reorder Quantity', '${item['reorder']} ${item['unit']}'),
                _detailRow('Status', item['status'] as String),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: ElevatedButton.icon(
                    onPressed: () { Navigator.pop(context); _showAddStockModal(item: item); },
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit'),
                    style: ElevatedButton.styleFrom(backgroundColor: _red, foregroundColor: Colors.white),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: OutlinedButton.icon(
                    onPressed: () { Navigator.pop(context); _confirmDelete(item); },
                    icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                    label: const Text('Delete', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                  )),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  void _showReceiveModal(Map<String, dynamic>? preSelected) {
    Map<String, dynamic>? selectedItem = preSelected;
    final scanCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => DraggableScrollableSheet(
          expand: false, initialChildSize: 0.7, maxChildSize: 0.92,
          builder: (_, ctrl) => SingleChildScrollView(
            controller: ctrl,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                    child: const Icon(Icons.download_outlined, color: Colors.white, size: 22)),
                  const SizedBox(width: 12),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Receive Items', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('Scan or search item to receive stock', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ])),
                  GestureDetector(onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.white)),
                ]),
              ),
              // Form content
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Scan section
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFebf8ff),
                  border: Border.all(color: const Color(0xFF90cdf4)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Row(children: [
                    Icon(Icons.qr_code_scanner, color: Color(0xFF003087), size: 18),
                    SizedBox(width: 6),
                    Text('Scan Item', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF003087), fontSize: 13)),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: scanCtrl,
                        decoration: InputDecoration(
                          hintText: 'Barcode, QR code, or item name...',
                          filled: true, fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF90cdf4))),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        onSubmitted: (v) {
                          final match = _findItem(v);
                          setModal(() => selectedItem = match);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Camera scan
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF003087),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.all(10),
                      ),
                      icon: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 22),
                      onPressed: () async {
                        final result = await Navigator.push<String>(context,
                          MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()));
                        if (result != null) {
                          scanCtrl.text = result;
                          final match = _findItem(result);
                          setModal(() => selectedItem = match);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final match = _findItem(scanCtrl.text.trim());
                        setModal(() => selectedItem = match);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF003087), foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: const Text('Search'),
                    ),
                  ]),
                ]),
              ),
              const SizedBox(height: 12),

              // Item found / not found feedback
              if (selectedItem != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFebf8ff),
                    border: Border.all(color: const Color(0xFF90cdf4)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    Container(width: 44, height: 44,
                      decoration: BoxDecoration(color: const Color(0xFF003087), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 22)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(selectedItem!['name'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('${selectedItem!['num']} • ${selectedItem!['group']}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF718096))),
                      Text('Current stock: ${selectedItem!['stock']} ${selectedItem!['unit']}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF2c5282), fontWeight: FontWeight.w500)),
                    ])),
                    GestureDetector(
                      onTap: () => setModal(() { selectedItem = null; scanCtrl.clear(); }),
                      child: const Icon(Icons.close, size: 18, color: Color(0xFF718096)),
                    ),
                  ]),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: qtyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Quantity Received *',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.add_box_outlined),
                    helperText: 'Will be added to current stock of ${selectedItem!['stock']} ${selectedItem!['unit']}',
                  ),
                ),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'))),
                  const SizedBox(width: 12),
                  Expanded(child: ElevatedButton(
                    onPressed: () {
                      final qty = int.tryParse(qtyCtrl.text) ?? 0;
                      if (qty <= 0) return;
                      setState(() {
                        final idx = _items.indexWhere((e) => e['num'] == selectedItem!['num']);
                        if (idx != -1) {
                          _items[idx]['stock'] = (_items[idx]['stock'] as int) + qty;
                          _items[idx]['status'] = _items[idx]['stock'] >= _items[idx]['min'] ? 'OK' : 'Low';
                          _filtered = List.from(_items);
                        }
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF003087), foregroundColor: Colors.white),
                    child: const Text('✅ Confirm Receive'),
                  )),
                ]),
              ] else if (scanCtrl.text.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200)),
                  child: const Row(children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 16),
                    SizedBox(width: 8),
                    Text('No item found for that code.', style: TextStyle(color: Colors.red, fontSize: 12)),
                  ]),
                ),
                ]), // end Padding Column
              ), // end Padding
            ]), // end outer Column
          ),
        ),
      ),
    );
  }

  Map<String, dynamic>? _findItem(String query) {
    if (query.isEmpty) return null;
    final q = query.toLowerCase();
    // Search in stock items first
    final inStock = _items.where((e) =>
      (e['num'] as String).toLowerCase() == q ||
      (e['name'] as String).toLowerCase().contains(q)
    ).firstOrNull;
    if (inStock != null) return inStock;
    // Search in item master by barcode/qr
    final master = _itemMaster.where((e) =>
      e['barcode'] == query || e['qr'] == query ||
      e['name']!.toLowerCase().contains(q) ||
      e['num']!.toLowerCase() == q
    ).firstOrNull;
    if (master != null) {
      // Return as stock item format if exists, else null
      return _items.where((e) => e['num'] == master['num']).firstOrNull;
    }
    return null;
  }

  // Mock item master data for scan lookup
  final List<Map<String, String>> _itemMaster = [
    {'num': 'ITM-001', 'name': 'Engine Oil 10W-40', 'group': 'Lubricants', 'unit': 'L', 'barcode': '1234567890', 'qr': 'QR-ITM-001'},
    {'num': 'ITM-002', 'name': 'Oil Filter', 'group': 'Filters', 'unit': 'pcs', 'barcode': '0987654321', 'qr': 'QR-ITM-002'},
    {'num': 'ITM-003', 'name': 'Brake Pads', 'group': 'Brakes', 'unit': 'set', 'barcode': '1122334455', 'qr': 'QR-ITM-003'},
    {'num': 'ITM-004', 'name': 'Air Filter', 'group': 'Filters', 'unit': 'pcs', 'barcode': '5544332211', 'qr': 'QR-ITM-004'},
    {'num': 'ITM-005', 'name': 'Coolant', 'group': 'Fluids', 'unit': 'L', 'barcode': '6677889900', 'qr': 'QR-ITM-005'},
  ];

  void _confirmDelete(Map<String, dynamic> item) {
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

  void _showAddStockModal({Map<String, dynamic>? item}) {
    final isEdit = item != null;
    final scanCtrl = TextEditingController();
    final stockCtrl = TextEditingController(text: item != null ? '${item['stock']}' : '');
    final minCtrl = TextEditingController(text: item != null ? '${item['min']}' : '');
    final maxCtrl = TextEditingController(text: item != null ? '${item['max']}' : '');
    final reorderCtrl = TextEditingController(text: item != null ? '${item['reorder']}' : '');
    Map<String, String>? foundItem = isEdit
        ? _itemMaster.firstWhere((e) => e['num'] == item!['num'], orElse: () => {})
        : null;
    if (foundItem?.isEmpty == true) foundItem = null;

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => DraggableScrollableSheet(
          expand: false, initialChildSize: 0.75, maxChildSize: 0.95,
          builder: (_, ctrl) => SingleChildScrollView(
            controller: ctrl,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Red header — edge to edge
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
                    child: Icon(isEdit ? Icons.edit_outlined : Icons.add_box_outlined, color: Colors.white, size: 22)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(isEdit ? 'Edit Stock Item' : 'Add Stock Item',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                  GestureDetector(onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.white)),
                ]),
              ),
              // Form content
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Scan section (hidden in edit mode)
              if (!isEdit) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFebf8ff),
                    border: Border.all(color: const Color(0xFFbee3f8)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Row(children: [
                      Icon(Icons.qr_code_scanner, color: Color(0xFF003087), size: 18),
                      SizedBox(width: 6),
                      Text('Scan Item Barcode / QR Code',
                        style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF003087), fontSize: 13)),
                    ]),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(
                        child: TextField(
                          controller: scanCtrl,
                          decoration: InputDecoration(
                            hintText: 'Scan or type barcode / QR code...',
                            filled: true, fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFbee3f8))),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          onSubmitted: (v) {
                            final match = _itemMaster.where((e) =>
                              e['barcode'] == v.trim() || e['qr'] == v.trim() ||
                              e['name']!.toLowerCase().contains(v.toLowerCase()) ||
                              e['num']!.toLowerCase().contains(v.toLowerCase())
                            ).firstOrNull;
                            setModal(() => foundItem = match);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Camera scan button
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF003087),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.all(10),
                        ),
                        icon: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 22),
                        onPressed: () async {
                          final result = await Navigator.push<String>(context,
                            MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()));
                          if (result != null) {
                            scanCtrl.text = result;
                            final match = _itemMaster.where((e) =>
                              e['barcode'] == result || e['qr'] == result ||
                              e['name']!.toLowerCase().contains(result.toLowerCase()) ||
                              e['num']!.toLowerCase().contains(result.toLowerCase())
                            ).firstOrNull;
                            setModal(() => foundItem = match);
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final v = scanCtrl.text.trim();
                          final match = _itemMaster.where((e) =>
                            e['barcode'] == v || e['qr'] == v ||
                            e['name']!.toLowerCase().contains(v.toLowerCase()) ||
                            e['num']!.toLowerCase().contains(v.toLowerCase())
                          ).firstOrNull;
                          setModal(() => foundItem = match);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF003087), foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        child: const Text('Search'),
                      ),
                    ]),
                  ]),
                ),
                const SizedBox(height: 12),

                // Found item preview
                if (foundItem != null)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFf0fff4),
                      border: Border.all(color: const Color(0xFF68d391)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Row(children: [
                        Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
                        SizedBox(width: 6),
                        Text('Item Found', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.green, fontSize: 12)),
                      ]),
                      const SizedBox(height: 8),
                      _infoRow('Item Number', foundItem!['num']!),
                      _infoRow('Item Name', foundItem!['name']!),
                      _infoRow('Commodity Group', foundItem!['group']!),
                      _infoRow('Unit', foundItem!['unit']!),
                    ]),
                  )
                else if (scanCtrl.text.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200)),
                    child: const Row(children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 16),
                      SizedBox(width: 8),
                      Text('No item found for that code.', style: TextStyle(color: Colors.red, fontSize: 12)),
                    ]),
                  ),
                const SizedBox(height: 12),
              ],

              // Edit mode: show item info
              if (isEdit)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFFF7F8FA), borderRadius: BorderRadius.circular(12)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _infoRow('Item Number', item!['num'] as String),
                    _infoRow('Item Name', item['name'] as String),
                    _infoRow('Group', item['group'] as String),
                    _infoRow('Unit', item['unit'] as String),
                  ]),
                ),

              // Stock level fields — show only when item is found or editing
              if (foundItem != null || isEdit) ...[
                const SizedBox(height: 14),
                const Text('Stock Level Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 10),
                TextField(controller: stockCtrl, keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Current Quantity *', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: TextField(controller: minCtrl, keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Min Level *', border: OutlineInputBorder()))),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: maxCtrl, keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Max Level *', border: OutlineInputBorder()))),
                ]),
                const SizedBox(height: 10),
                TextField(controller: reorderCtrl, keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Reorder Quantity *', border: OutlineInputBorder())),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
                  const SizedBox(width: 12),
                  Expanded(child: ElevatedButton(
                    onPressed: () {
                      final src = isEdit ? item! : foundItem!;
                      final stock = int.tryParse(stockCtrl.text) ?? 0;
                      final min = int.tryParse(minCtrl.text) ?? 0;
                      setState(() {
                        final newItem = {
                          'num': src['num'],
                          'name': src['name'],
                          'group': src['group'],
                          'unit': src['unit'],
                          'stock': stock,
                          'min': min,
                          'max': int.tryParse(maxCtrl.text) ?? 0,
                          'reorder': int.tryParse(reorderCtrl.text) ?? 0,
                          'status': stock >= min ? 'OK' : 'Low',
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
              ],
                ]), // end Padding Column
              ), // end Padding
            ]), // end outer Column
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        SizedBox(width: 120, child: Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF718096)))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
      ]),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 140, child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF718096), fontWeight: FontWeight.w500))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1a202c)))),
      ]),
    );
  }
}
