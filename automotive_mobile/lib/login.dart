import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'staff_dashboard.dart';
import 'customer_dashboard.dart';
import 'admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _passVisible = false;
  bool _loading = false;
  static const _red = Color(0xFFE8001C);

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter email and password.');
      return;
    }

    setState(() => _loading = true);
    try {
      final cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .get();

      if (!doc.exists) {
        await FirebaseAuth.instance.signOut();
        _showError('Account not found.');
        return;
      }

      final role = doc.data()?['role'] as String? ?? '';

      if (!mounted) return;
      switch (role) {
        case 'admin':
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
          break;
        case 'staff':
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StaffDashboard()));
          break;
        case 'customer':
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CustomerDashboard()));
          break;
        default:
          await FirebaseAuth.instance.signOut();
          _showError('Unknown account role.');
      }
    } on FirebaseAuthException catch (e) {
      final msg = (e.code == 'user-not-found' ||
              e.code == 'wrong-password' ||
              e.code == 'invalid-credential')
          ? 'Invalid email or password.'
          : e.message ?? 'Login failed.';
      _showError(msg);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [
            // ── Header ──
            Stack(children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 70, 20, 60),
                color: _red,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/img/LOGO_CALTEX.png', width: 72, height: 72, fit: BoxFit.contain),
                    const SizedBox(width: 16),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                      Image.asset('assets/img/CALTEX_LETTER.png', height: 44, fit: BoxFit.contain),
                      const SizedBox(height: 4),
                      const Text('AutoPro', style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 4)),
                    ]),
                  ],
                ),
              ),
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                  ),
                ),
              ),
            ]),
            // ── Login form ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Center(child: Text('Welcome to Caltex AutoPro',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1a202c)))),
                const SizedBox(height: 4),
                const Center(child: Text('Sign in to your account',
                  style: TextStyle(fontSize: 13, color: Color(0xFF718096)))),
                const SizedBox(height: 28),
                // Email
                const Text('Email Address', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF4a5568))),
                const SizedBox(height: 6),
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF1a202c)),
                  decoration: _inputDecoration('Enter your email', Icons.person_outline),
                ),
                const SizedBox(height: 16),
                // Password
                const Text('Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF4a5568))),
                const SizedBox(height: 6),
                TextField(
                  controller: _passwordCtrl,
                  obscureText: !_passVisible,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF1a202c)),
                  onSubmitted: (_) => _handleLogin(),
                  decoration: _inputDecoration('Enter your password', Icons.lock_outline,
                    suffix: IconButton(
                      icon: Icon(_passVisible ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF718096)),
                      onPressed: () => setState(() => _passVisible = !_passVisible),
                    )),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 4,
                    ),
                    child: _loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Sign In', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFa0aec0), fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFF718096), size: 20),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFe2e8f0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFe2e8f0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _red, width: 1.5)),
      filled: true,
      fillColor: const Color(0xFFF7F8FA),
    );
  }
}
