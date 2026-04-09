import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'login.dart';

enum UserRole { customer, staff, admin }

class UserProfile extends StatefulWidget {
  final UserRole role;
  const UserProfile({super.key, required this.role});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  static const _red = Color(0xFFE8001C);
  static const _blue = Color(0xFF003087);

  File? _avatarImage;
  bool _editingInfo = false;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _roleCtrl;

  @override
  void initState() {
    super.initState();
    switch (widget.role) {
      case UserRole.admin:
        _nameCtrl  = TextEditingController(text: 'Administrator');
        _emailCtrl = TextEditingController(text: 'admin@caltex.com');
        _roleCtrl  = TextEditingController(text: 'Super Admin');
        break;
      case UserRole.staff:
        _nameCtrl  = TextEditingController(text: 'Staff Member');
        _emailCtrl = TextEditingController(text: 'staff@caltex.com');
        _roleCtrl  = TextEditingController(text: 'Service Staff');
        break;
      case UserRole.customer:
        _nameCtrl  = TextEditingController(text: 'John Doe');
        _emailCtrl = TextEditingController(text: 'customer@caltex.com');
        _roleCtrl  = TextEditingController(text: 'Vehicle Owner');
        break;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _roleCtrl.dispose();
    super.dispose();
  }

  String get _initials {
    switch (widget.role) {
      case UserRole.admin:    return 'AD';
      case UserRole.staff:    return 'ST';
      case UserRole.customer: return 'JD';
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _avatarImage = File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    final isStandalone = widget.role != UserRole.customer;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: isStandalone ? AppBar(
        backgroundColor: _red,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Profile',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ) : null,
      body: SingleChildScrollView(
        child: Column(children: [
          // ── Hero header ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 36, 20, 32),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_red, Color(0xFFC41E3A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(children: [
              GestureDetector(
                onTap: _pickImage,
                child: Stack(alignment: Alignment.bottomRight, children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12)],
                    ),
                    child: CircleAvatar(
                      radius: 44,
                      backgroundColor: Colors.white24,
                      backgroundImage: _avatarImage != null ? FileImage(_avatarImage!) : null,
                      child: _avatarImage == null
                          ? Text(_initials, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold))
                          : null,
                    ),
                  ),
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4)]),
                    child: const Icon(Icons.camera_alt, size: 15, color: _red),
                  ),
                ]),
              ),
              const SizedBox(height: 14),
              Text(_nameCtrl.text,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                child: Text(_roleCtrl.text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ]),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              // ── Account Info ──
              _sectionLabel('ACCOUNT INFORMATION'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Info', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF718096))),
                      TextButton.icon(
                        onPressed: () => setState(() => _editingInfo = !_editingInfo),
                        icon: Icon(_editingInfo ? Icons.check : Icons.edit_outlined, size: 15),
                        label: Text(_editingInfo ? 'Save' : 'Edit', style: const TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(foregroundColor: _red),
                      ),
                    ]),
                  ),
                  _editableTile(Icons.person_outline, 'Full Name', _nameCtrl),
                  _editableTile(Icons.alternate_email, 'Email', _emailCtrl),
                  _editableTile(Icons.badge_outlined, 'Role', _roleCtrl, isLast: true),
                ]),
              ),
              const SizedBox(height: 16),

              // ── Settings ──
              _sectionLabel('SETTINGS'),
              const SizedBox(height: 8),
              _actionCard([
                _actionTile(Icons.notifications_outlined, 'Notifications', 'Manage alerts', () {}),
                _actionTile(Icons.lock_outline, 'Change Password', 'Update credentials', () {}),
                _actionTile(Icons.help_outline, 'Help & Support', 'Get assistance', () {}, isLast: true),
              ]),
              const SizedBox(height: 20),

              // ── Logout ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _confirmLogout,
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Logout', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _red, foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text('v1.0.0 • JA Noble Enterprise',
                style: TextStyle(fontSize: 11, color: Color(0xFFa0aec0))),
              const SizedBox(height: 8),
            ]),
          ),
        ]),
      ),
    );
  }

  // ── Helpers ──

  Widget _sectionLabel(String label) => Align(
    alignment: Alignment.centerLeft,
    child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF718096), letterSpacing: 0.8)),
  );

  Widget _editableTile(IconData icon, String label, TextEditingController ctrl, {bool isLast = false}) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [
          Container(width: 36, height: 36,
            decoration: BoxDecoration(color: const Color(0xFFF0F4FF), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: _red)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF718096))),
            _editingInfo
                ? TextField(controller: ctrl,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1a202c)),
                    decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 4), border: UnderlineInputBorder()))
                : Text(ctrl.text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1a202c))),
          ])),
        ]),
      ),
      if (!isLast) const Divider(height: 1, indent: 64),
    ]);
  }

  Widget _infoCard(List<Widget> tiles) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
    child: Column(children: tiles),
  );

  Widget _infoTile(IconData icon, String label, String value, {bool isLast = false}) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(children: [
          Container(width: 36, height: 36,
            decoration: BoxDecoration(color: const Color(0xFFF0F4FF), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: _red)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF718096))),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1a202c))),
          ])),
        ]),
      ),
      if (!isLast) const Divider(height: 1, indent: 64),
    ]);
  }

  Widget _actionCard(List<Widget> tiles) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
    child: Column(children: tiles),
  );

  Widget _actionTile(IconData icon, String label, String sub, VoidCallback onTap, {bool isLast = false}) {
    return Column(children: [
      InkWell(
        onTap: onTap,
        borderRadius: isLast ? const BorderRadius.vertical(bottom: Radius.circular(14)) : BorderRadius.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(children: [
            Container(width: 36, height: 36,
              decoration: BoxDecoration(color: const Color(0xFFF0F4FF), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 18, color: _blue)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1a202c))),
              Text(sub, style: const TextStyle(fontSize: 11, color: Color(0xFF718096))),
            ])),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFF718096)),
          ]),
        ),
      ),
      if (!isLast) const Divider(height: 1, indent: 64),
    ]);
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false),
            child: const Text('Logout', style: TextStyle(color: _red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
