import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  static const _red = Color(0xFFE8001C);

  final _currentCtrl = TextEditingController();
  final _newCtrl     = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew     = true;
  bool _obscureConfirm = true;
  bool _loading        = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final current = _currentCtrl.text.trim();
    final newPass  = _newCtrl.text.trim();
    final confirm  = _confirmCtrl.text.trim();

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      _snack('Please fill in all fields.', Colors.orange);
      return;
    }
    if (newPass.length < 6) {
      _snack('New password must be at least 6 characters.', Colors.orange);
      return;
    }
    if (newPass != confirm) {
      _snack('New passwords do not match.', Colors.orange);
      return;
    }

    setState(() => _loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      // Re-authenticate first
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: current,
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPass);

      if (mounted) {
        _snack('Password changed successfully!', Colors.green);
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      final msg = e.code == 'wrong-password'
          ? 'Current password is incorrect.'
          : e.message ?? 'An error occurred.';
      _snack(msg, Colors.red);
    } catch (e) {
      _snack('Error: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: _red,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Change Password',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFbee3f8)),
            ),
            child: const Row(children: [
              Icon(Icons.info_outline, color: Color(0xFF003087), size: 18),
              SizedBox(width: 10),
              Expanded(child: Text(
                'Your new password must be at least 6 characters.',
                style: TextStyle(fontSize: 12, color: Color(0xFF003087)),
              )),
            ]),
          ),
          const SizedBox(height: 24),

          // Current password
          _label('Current Password'),
          const SizedBox(height: 6),
          _passwordField(
            controller: _currentCtrl,
            hint: 'Enter current password',
            obscure: _obscureCurrent,
            onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
          ),
          const SizedBox(height: 16),

          // New password
          _label('New Password'),
          const SizedBox(height: 6),
          _passwordField(
            controller: _newCtrl,
            hint: 'Enter new password',
            obscure: _obscureNew,
            onToggle: () => setState(() => _obscureNew = !_obscureNew),
          ),
          const SizedBox(height: 16),

          // Confirm password
          _label('Confirm New Password'),
          const SizedBox(height: 6),
          _passwordField(
            controller: _confirmCtrl,
            hint: 'Re-enter new password',
            obscure: _obscureConfirm,
            onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: _red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _loading
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Update Password',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _label(String text) => Text(text,
    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4a5568)));

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF718096)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFe2e8f0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _red, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 20, color: const Color(0xFF718096)),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
