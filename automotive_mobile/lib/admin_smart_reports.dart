import 'package:flutter/material.dart';

class AdminSmartReports extends StatefulWidget {
  const AdminSmartReports({super.key});

  @override
  State<AdminSmartReports> createState() => _AdminSmartReportsState();
}

class _AdminSmartReportsState extends State<AdminSmartReports> {
  static const _red = Color(0xFFE8001C);
  static const _blue = Color(0xFF003087);

  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<_ChatMessage> _messages = [];

  // Sample data for query processing
  static const _assets = [
    {'plate': 'ABC-1234', 'desc': 'Isuzu Truck NQR 2021', 'owner': 'Juan Dela Cruz', 'status': 'active', 'nextPMS': '2026-02-15'},
    {'plate': 'XYZ-5678', 'desc': 'Toyota Hilux 2020', 'owner': 'Pedro Santos', 'status': 'maintenance', 'nextPMS': '2026-04-10'},
    {'plate': 'DEF-9012', 'desc': 'Mitsubishi L300 2019', 'owner': 'Jose Reyes', 'status': 'active', 'nextPMS': '2026-03-01'},
  ];

  static const _inventory = [
    {'num': 'ITM-001', 'name': 'Engine Oil 10W-40', 'stock': 24, 'min': 10, 'unit': 'L'},
    {'num': 'ITM-002', 'name': 'Oil Filter', 'stock': 3, 'min': 5, 'unit': 'pcs'},
    {'num': 'ITM-003', 'name': 'Brake Pads', 'stock': 8, 'min': 4, 'unit': 'set'},
    {'num': 'ITM-004', 'name': 'Air Filter', 'stock': 2, 'min': 5, 'unit': 'pcs'},
  ];

  static const _services = [
    {'plate': 'ABC-1234', 'desc': 'Change Oil', 'cost': 2500, 'status': 'Completed'},
    {'plate': 'XYZ-5678', 'desc': 'Brake Inspection', 'cost': 1800, 'status': 'Ongoing'},
    {'plate': 'DEF-9012', 'desc': 'PMS Service', 'cost': 3200, 'status': 'Pending'},
  ];

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  void _sendQuery([String? preset]) {
    final text = preset ?? _inputCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(role: 'user', text: text));
      _inputCtrl.clear();
    });
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 600), () {
      final result = _processQuery(text);
      setState(() => _messages.add(_ChatMessage(role: 'ai', result: result)));
      _scrollToBottom();
    });
  }

  _QueryResult _processQuery(String query) {
    final q = query.toLowerCase();

    // Under maintenance
    if (q.contains('under maintenance') || q.contains('being maintained') || q.contains('currently') && q.contains('maintenance')) {
      final list = _assets.where((a) => a['status'] == 'maintenance').toList();
      if (list.isEmpty) return _QueryResult(type: 'success', icon: '✅', title: 'Assets Under Maintenance', body: 'No assets are currently under maintenance.', rows: []);
      return _QueryResult(type: 'blue', icon: '🔵', title: 'Assets Under Maintenance',
        body: '${list.length} asset(s) are currently under maintenance.',
        rows: list.map((a) => _Row(label: '${a['plate']} – ${a['desc']}', value: a['owner'] as String)).toList());
    }

    // PMS overdue
    if (q.contains('overdue') || q.contains('past due') || q.contains('missed')) {
      final now = DateTime.now();
      final list = _assets.where((a) {
        final due = DateTime.tryParse(a['nextPMS'] as String);
        return due != null && due.isBefore(now) && a['status'] != 'maintenance';
      }).toList();
      if (list.isEmpty) return _QueryResult(type: 'success', icon: '✅', title: 'PMS Overdue', body: 'No assets are overdue for PMS.', rows: []);
      return _QueryResult(type: 'danger', icon: '⚠️', title: 'Assets with PMS Overdue',
        body: '${list.length} asset(s) have overdue PMS schedules.',
        rows: list.map((a) {
          final due = DateTime.parse(a['nextPMS'] as String);
          final days = now.difference(due).inDays;
          return _Row(label: '${a['plate']} – ${a['desc']}', value: 'Overdue by $days day(s)');
        }).toList());
    }

    // PMS due soon
    if (q.contains('due soon') || q.contains('upcoming') || q.contains('pms') && q.contains('schedule')) {
      final now = DateTime.now();
      final list = _assets.where((a) {
        final due = DateTime.tryParse(a['nextPMS'] as String);
        if (due == null) return false;
        final diff = due.difference(now).inDays;
        return diff >= 0 && diff <= 30;
      }).toList();
      if (list.isEmpty) return _QueryResult(type: 'success', icon: '✅', title: 'PMS Due Soon', body: 'No assets have PMS due in the next 30 days.', rows: []);
      return _QueryResult(type: 'warning', icon: '📅', title: 'Assets with PMS Due Soon',
        body: '${list.length} asset(s) have PMS due within 30 days.',
        rows: list.map((a) {
          final due = DateTime.parse(a['nextPMS'] as String);
          final diff = due.difference(now).inDays;
          return _Row(label: '${a['plate']} – ${a['desc']}', value: diff == 0 ? 'Due today!' : 'Due in $diff day(s)');
        }).toList());
    }

    // Low stock
    if (q.contains('low stock') || q.contains('reorder') || q.contains('running low') || q.contains('low in stock')) {
      final list = _inventory.where((i) => (i['stock'] as int) <= (i['min'] as int)).toList();
      if (list.isEmpty) return _QueryResult(type: 'success', icon: '✅', title: 'Low Stock Items', body: 'All inventory items are sufficiently stocked.', rows: []);
      return _QueryResult(type: 'warning', icon: '📦', title: 'Low Stock Inventory Items',
        body: '${list.length} item(s) are at or below minimum stock level.',
        rows: list.map((i) => _Row(label: '${i['num']} – ${i['name']}', value: '${i['stock']} ${i['unit']} (min: ${i['min']})')).toList());
    }

    // Total cost / monthly cost
    if (q.contains('cost') || q.contains('expense') || q.contains('repair cost') || q.contains('monthly')) {
      final total = _services.fold<int>(0, (sum, s) => sum + (s['cost'] as int));
      return _QueryResult(type: 'blue', icon: '💰', title: 'Total Repair Cost This Month',
        body: 'Total maintenance cost across all service transactions.',
        rows: [
          ..._services.map((s) => _Row(label: '${s['plate']} – ${s['desc']}', value: '₱${(s['cost'] as int).toStringAsFixed(0)}')),
          _Row(label: 'TOTAL', value: '₱$total', isBold: true),
        ]);
    }

    // Asset list
    if (q.contains('list') && (q.contains('asset') || q.contains('vehicle')) || q.contains('all vehicle') || q.contains('fleet')) {
      return _QueryResult(type: 'blue', icon: '🚗', title: 'All Vehicles',
        body: '${_assets.length} vehicle(s) registered in the system.',
        rows: _assets.map((a) => _Row(label: '${a['plate']} – ${a['desc']}', value: a['owner'] as String)).toList());
    }

    // Inventory status
    if (q.contains('inventory') || q.contains('stock status') || q.contains('parts')) {
      return _QueryResult(type: 'blue', icon: '📦', title: 'Inventory Status',
        body: '${_inventory.length} item(s) in inventory.',
        rows: _inventory.map((i) => _Row(
          label: '${i['num']} – ${i['name']}',
          value: '${i['stock']} ${i['unit']}',
          isWarning: (i['stock'] as int) <= (i['min'] as int),
        )).toList());
    }

    // Frequently maintained
    if (q.contains('frequent') || q.contains('most maintained') || q.contains('often')) {
      return _QueryResult(type: 'warning', icon: '🔧', title: 'Frequently Maintained Assets',
        body: 'Based on service history, these assets have the most maintenance records.',
        rows: _services.map((s) => _Row(label: '${s['plate']} – ${s['desc']}', value: s['status'] as String)).toList());
    }

    // Default
    return _QueryResult(type: 'info', icon: '🤖', title: 'No Results Found',
      body: 'I couldn\'t understand your query. Try asking about:\n• Low stock items\n• PMS overdue assets\n• Total repair cost\n• Assets under maintenance',
      rows: []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: _red,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Smart Reports',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          if (_messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              tooltip: 'Clear chat',
              onPressed: () => setState(() => _messages.clear()),
            ),
        ],
      ),
      body: Column(children: [
        // Chat area
        Expanded(
          child: _messages.isEmpty ? _buildWelcome() : ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (_, i) => _buildBubble(_messages[i]),
          ),
        ),
        // Input bar
        SafeArea(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(children: [
            Expanded(
              child: TextField(
                controller: _inputCtrl,
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendQuery(),
                decoration: InputDecoration(
                  hintText: 'Ask something about your fleet...',
                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF718096)),
                  filled: true, fillColor: const Color(0xFFF7F8FA),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendQuery,
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: _red, shape: BoxShape.circle),
                child: const Icon(Icons.send, color: Colors.white, size: 18),
              ),
            ),
          ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildWelcome() {
    final chips = [
      ('🔧 Frequently maintained assets', 'Which assets are frequently under maintenance?'),
      ('📦 Low stock items', 'What items are low in stock?'),
      ('💰 Repair cost this month', 'Total repair cost this month'),
      ('⚠️ PMS overdue assets', 'Assets with PMS overdue'),
      ('🔵 Under maintenance', 'Which assets are under maintenance?'),
      ('📋 All vehicles', 'List all vehicles'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        const SizedBox(height: 12),
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(color: _blue.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: const Icon(Icons.smart_toy_outlined, color: _blue, size: 32),
        ),
        const SizedBox(height: 14),
        const Text('Smart Reports AI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1a202c))),
        const SizedBox(height: 6),
        const Text('Ask me anything about your fleet — assets, inventory, maintenance costs, and more.',
          style: TextStyle(fontSize: 13, color: Color(0xFF718096)), textAlign: TextAlign.center),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: chips.map((c) => GestureDetector(
            onTap: () => _sendQuery(c.$2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFe2e8f0)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
              ),
              child: Text(c.$1, style: const TextStyle(fontSize: 12, color: Color(0xFF4a5568), fontWeight: FontWeight.w500)),
            ),
          )).toList(),
        ),
      ]),
    );
  }

  Widget _buildBubble(_ChatMessage msg) {
    if (msg.role == 'user') {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 48),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: _red, borderRadius: BorderRadius.circular(18)),
          child: Text(msg.text!, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ),
      );
    }

    final r = msg.result!;
    final headerColor = r.type == 'danger' ? _red
        : r.type == 'warning' ? Colors.orange
        : r.type == 'success' ? const Color(0xFF2c7a7b)
        : _blue;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, right: 48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(children: [
              Text(r.icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(child: Text(r.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
            ]),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.body, style: const TextStyle(fontSize: 12, color: Color(0xFF4a5568))),
              if (r.rows.isNotEmpty) ...[
                const SizedBox(height: 10),
                ...r.rows.map((row) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Expanded(child: Text(row.label,
                      style: TextStyle(fontSize: 12, fontWeight: row.isBold ? FontWeight.bold : FontWeight.w500,
                        color: const Color(0xFF1a202c)))),
                    Text(row.value,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                        color: row.isBold ? headerColor : row.isWarning ? Colors.orange : headerColor)),
                  ]),
                )),
              ],
            ]),
          ),
        ]),
      ),
    );
  }
}

class _ChatMessage {
  final String role;
  final String? text;
  final _QueryResult? result;
  _ChatMessage({required this.role, this.text, this.result});
}

class _QueryResult {
  final String type, icon, title, body;
  final List<_Row> rows;
  _QueryResult({required this.type, required this.icon, required this.title, required this.body, required this.rows});
}

class _Row {
  final String label, value;
  final bool isBold, isWarning;
  _Row({required this.label, required this.value, this.isBold = false, this.isWarning = false});
}
