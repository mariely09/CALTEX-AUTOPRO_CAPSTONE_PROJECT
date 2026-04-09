import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUsers extends StatefulWidget {
  const AdminUsers({super.key});

  @override
  State<AdminUsers> createState() => _AdminUsersState();
}

class _AdminUsersState extends State<AdminUsers> {
  static const _red = Color(0xFFE8001C);
  final _searchCtrl = TextEditingController();
  bool _searching = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Color _roleColor(String role) {
    if (role == 'admin') return _red;
    if (role == 'staff') return const Color(0xFF003087);
    return Colors.green;
  }

  String _roleLabel(String role) =>
      role[0].toUpperCase() + role.substring(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUserModal(),
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
                  hintText: 'Search users...',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
              )
            : const Text('User Management',
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
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];
          final users = docs.map((d) {
            final data = d.data() as Map<String, dynamic>;
            return {
              'uid': d.id,
              'name': data['name'] as String? ?? '—',
              'username': data['username'] as String? ?? '—',
              'email': data['email'] as String? ?? '—',
              'role': data['role'] as String? ?? '—',
              'status': data['status'] as String? ?? 'Active',
            };
          }).toList();

          final filtered = _searchQuery.isEmpty
              ? users
              : users.where((u) =>
                  u['name']!.toLowerCase().contains(_searchQuery) ||
                  u['username']!.toLowerCase().contains(_searchQuery) ||
                  u['role']!.toLowerCase().contains(_searchQuery)).toList();

          final total = users.length;
          final customers = users.where((u) => u['role'] == 'customer').length;
          final staff = users.where((u) => u['role'] == 'staff').length;

          return Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(children: [
                _statChip('Total', '$total', Colors.blue),
                const SizedBox(width: 8),
                _statChip('Customer', '$customers', Colors.green),
                const SizedBox(width: 8),
                _statChip('Staff', '$staff', const Color(0xFF003087)),
              ]),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text('No users found.', style: TextStyle(color: Color(0xFF718096))))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _userCard(filtered[i]),
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
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
        child: Column(children: [
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF718096))),
        ]),
      ),
    );
  }

  Widget _userCard(Map<String, String> u) {
    final rc = _roleColor(u['role']!);
    return GestureDetector(
      onTap: () => _showUserDetails(u),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
        child: Row(children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: rc.withOpacity(0.15),
            child: Text(u['name']![0].toUpperCase(),
              style: TextStyle(color: rc, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(u['name']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text('@${u['username']}', style: const TextStyle(fontSize: 11, color: Color(0xFF718096))),
            Text(u['email']!, style: const TextStyle(fontSize: 11, color: Color(0xFF718096))),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: rc.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(_roleLabel(u['role']!), style: TextStyle(fontSize: 10, color: rc, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 4),
            Text(u['status']!,
              style: TextStyle(fontSize: 10,
                color: u['status'] == 'Active' ? Colors.green : const Color(0xFF718096),
                fontWeight: FontWeight.w500)),
          ]),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 18, color: Color(0xFF718096)),
            onSelected: (val) {
              if (val == 'edit') _showAddUserModal(user: u);
              if (val == 'delete') _confirmDelete(u);
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

  void _showUserDetails(Map<String, String> u) {
    final rc = _roleColor(u['role']!);
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        expand: false, initialChildSize: 0.55, maxChildSize: 0.8,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          child: Column(children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              decoration: BoxDecoration(color: rc, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
              child: Row(children: [
                CircleAvatar(radius: 26, backgroundColor: Colors.white24,
                  child: Text(u['name']![0].toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(u['name']!, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('@${u['username']}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ])),
                GestureDetector(onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _detailRow('Full Name', u['name']!),
                _detailRow('Username', '@${u['username']}'),
                _detailRow('Email', u['email']!),
                _detailRow('Role', _roleLabel(u['role']!)),
                _detailRow('Status', u['status']!),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () { Navigator.pop(context); _showAddUserModal(user: u); },
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
        SizedBox(width: 110, child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF718096), fontWeight: FontWeight.w500))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1a202c)))),
      ]),
    );
  }

  void _showAddUserModal({Map<String, String>? user}) {
    final isEdit = user != null;
    final nameCtrl = TextEditingController(text: user?['name'] ?? '');
    final usernameCtrl = TextEditingController(text: user?['username'] ?? '');
    final emailCtrl = TextEditingController(text: user?['email'] ?? '');
    final passCtrl = TextEditingController();
    String selectedRole = isEdit
        ? (user!['role']![0].toUpperCase() + user['role']!.substring(1))
        : 'Staff';
    String selectedStatus = user?['status'] ?? 'Active';

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) {
        bool obscurePass = true;
        return StatefulBuilder(
        builder: (ctx, setModal) => DraggableScrollableSheet(
          expand: false, initialChildSize: 0.9, maxChildSize: 0.97,
          builder: (_, ctrl) => SingleChildScrollView(
            controller: ctrl,
            child: Column(children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                decoration: const BoxDecoration(color: _red, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                child: Row(children: [
                  Container(width: 44, height: 44,
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                    child: Icon(isEdit ? Icons.edit_outlined : Icons.person_add_outlined, color: Colors.white, size: 22)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(isEdit ? 'Edit User' : 'Add User',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                  GestureDetector(onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.white)),
                ]),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24),
                child: Column(children: [
                  TextField(controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Full Name *', border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  TextField(controller: usernameCtrl,
                    decoration: const InputDecoration(labelText: 'Username *', border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  TextField(controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email *', border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  Theme(
                    data: Theme.of(context).copyWith(
                      inputDecorationTheme: const InputDecorationTheme(
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      ),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedRole,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Role *', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                        DropdownMenuItem(value: 'Staff', child: Text('Staff')),
                        DropdownMenuItem(value: 'Customer', child: Text('Customer')),
                      ],
                      onChanged: (v) => setModal(() => selectedRole = v!),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passCtrl,
                    obscureText: obscurePass,
                    decoration: InputDecoration(
                      labelText: isEdit ? 'New Password (leave blank to keep)' : 'Password *',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(obscurePass ? Icons.visibility_off : Icons.visibility, size: 20),
                        onPressed: () => setModal(() => obscurePass = !obscurePass),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(children: [
                    Expanded(child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'))),
                    const SizedBox(width: 12),
                    Expanded(child: ElevatedButton(
                      onPressed: () async {
                        if (nameCtrl.text.trim().isEmpty ||
                            usernameCtrl.text.trim().isEmpty ||
                            emailCtrl.text.trim().isEmpty) return;
                        if (!isEdit && passCtrl.text.trim().isEmpty) return;
                        try {
                          if (isEdit) {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user!['uid'])
                                .update({
                              'name': nameCtrl.text.trim(),
                              'username': usernameCtrl.text.trim(),
                              'email': emailCtrl.text.trim(),
                              'role': selectedRole.toLowerCase(),
                              'status': selectedStatus,
                            });
                          } else {
                            final cred = await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                                    email: emailCtrl.text.trim(),
                                    password: passCtrl.text.trim());
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(cred.user!.uid)
                                .set({
                              'name': nameCtrl.text.trim(),
                              'username': usernameCtrl.text.trim(),
                              'email': emailCtrl.text.trim(),
                              'role': selectedRole.toLowerCase(),
                              'status': selectedStatus,
                              'createdAt': FieldValue.serverTimestamp(),
                            });
                          }
                          if (context.mounted) Navigator.pop(context);
                        } on FirebaseAuthException catch (e) {
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.message ?? 'Error'), backgroundColor: Colors.red));
                        } catch (e) {
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
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
      );
      },
    );
  }

  void _confirmDelete(Map<String, String> u) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Delete "${u['name']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(u['uid'])
                    .delete();
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
