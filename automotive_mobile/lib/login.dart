import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  Future<void> _handleGoogleSignIn() async {
    setState(() => _loading = true);
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) { setState(() => _loading = false); return; }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final cred = await FirebaseAuth.instance.signInWithCredential(credential);
      final uid = cred.user!.uid;

      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      String role;
      if (!doc.exists) {
        // Auto-register as customer
        role = 'customer';
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'name': cred.user!.displayName ?? '',
          'email': cred.user!.email ?? '',
          'photoUrl': cred.user!.photoURL ?? '',
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        role = doc.data()?['role'] as String? ?? '';
      }

      if (!mounted) return;
      switch (role) {
        case 'admin':
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
          break;
        case 'staff':
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StaffDashboard()));
          break;
        case 'customer':
        default:
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CustomerDashboard()));
      }
    } catch (e) {
      _showError('Google sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));
  }

  void _showForgotPassword() {
    final emailCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: _red.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.lock_reset_outlined, color: _red, size: 20)),
              const SizedBox(width: 12),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Reset Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1a202c))),
                Text("We'll send a reset link to your email", style: TextStyle(fontSize: 12, color: Color(0xFF718096))),
              ])),
              GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: const Icon(Icons.close, color: Color(0xFF718096))),
            ]),
            const SizedBox(height: 20),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              decoration: _inputDecoration('Enter your email', Icons.email_outlined),
            ),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (ctx2, setSt) {
                bool sending = false;
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: sending ? null : () async {
                      final email = emailCtrl.text.trim();
                      if (email.isEmpty) return;
                      setSt(() => sending = true);
                      try {
                        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Reset link sent! Check your email.'),
                              backgroundColor: Colors.green));
                        }
                      } on FirebaseAuthException catch (e) {
                        if (ctx2.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.message ?? 'Failed to send reset email.'),
                              backgroundColor: Colors.redAccent));
                          setSt(() => sending = false);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _red, foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: sending
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Send Reset Link', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                );
              },
            ),
          ]),
        ),
      ),
    );
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
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _loading ? null : _showForgotPassword,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Forgot Password?',
                      style: TextStyle(fontSize: 12, color: Color(0xFF718096))),
                  ),
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
                const SizedBox(height: 16),
                Row(children: [
                  const Expanded(child: Divider(color: Color(0xFFe2e8f0))),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or', style: TextStyle(fontSize: 13, color: Color(0xFF718096))),
                  ),
                  const Expanded(child: Divider(color: Color(0xFFe2e8f0))),
                ]),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _loading ? null : _handleGoogleSignIn,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      side: const BorderSide(color: Color(0xFFe2e8f0)),
                      backgroundColor: Colors.white,
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      _GoogleLogo(size: 20),
                      const SizedBox(width: 10),
                      const Text('Continue with Google',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1a202c))),
                    ]),
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

class _GoogleLogo extends StatelessWidget {
  final double size;
  const _GoogleLogo({this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size, height: size,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // Draw colored arcs (blue, red, yellow, green)
    final segments = [
      // [startAngle, sweepAngle, color]
      [-0.52, 1.57, const Color(0xFF4285F4)],  // blue (top-right)
      [1.05,  1.57, const Color(0xFF34A853)],  // green (bottom-right)
      [2.62,  0.79, const Color(0xFFFBBC05)],  // yellow (bottom-left)
      [3.41,  1.57, const Color(0xFFEA4335)],  // red (top-left)
    ];

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.22
      ..strokeCap = StrokeCap.butt;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.72);

    for (final seg in segments) {
      strokePaint.color = seg[2] as Color;
      canvas.drawArc(rect, seg[0] as double, seg[1] as double, false, strokePaint);
    }

    // White cutout for the "G" bar (right side horizontal bar)
    final barPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(cx, cy - size.height * 0.11, r * 0.72, size.height * 0.22),
      barPaint,
    );

    // Blue fill for the bar
    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(cx, cy - size.height * 0.11, r * 0.68, size.height * 0.22),
      bluePaint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
