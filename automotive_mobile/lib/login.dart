import 'package:flutter/material.dart';
import 'staff_dashboard.dart';
import 'customer_dashboard.dart';
import 'admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _customerEmailCtrl = TextEditingController();
  final _customerPasswordCtrl = TextEditingController();
  final _staffEmailCtrl = TextEditingController();
  final _staffPasswordCtrl = TextEditingController();
  final _adminEmailCtrl = TextEditingController();
  final _adminPasswordCtrl = TextEditingController();

  bool _customerPassVisible = false;
  bool _staffPassVisible = false;
  bool _adminPassVisible = false;

  static const _red = Color(0xFFE8001C);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _customerEmailCtrl.dispose();
    _customerPasswordCtrl.dispose();
    _staffEmailCtrl.dispose();
    _staffPasswordCtrl.dispose();
    _adminEmailCtrl.dispose();
    _adminPasswordCtrl.dispose();
    super.dispose();
  }

  void _handleLogin(String role, String email, String password) {
    final Map<String, Map<String, String>> credentials = {
      'customer': {'email': 'customer@caltex.com', 'password': 'customer123'},
      'staff': {'email': 'staff@caltex.com', 'password': 'staff123'},
      'admin': {'email': 'admin@caltex.com', 'password': 'admin123'},
    };
    final cred = credentials[role];
    if (cred == null) return;
    if (email == cred['email'] && password == cred['password']) {
      if (role == 'staff') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StaffDashboard()));
      } else if (role == 'customer') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CustomerDashboard()));
      } else if (role == 'admin') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Welcome, $role!'), backgroundColor: _red),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid email or password.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 70, 20, 60),
                      color: _red,
                      child: _buildHeaderContent(),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                _buildLoginCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset('assets/img/LOGO_CALTEX.png', width: 72, height: 72, fit: BoxFit.contain),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/img/CALTEX_LETTER.png', height: 44, fit: BoxFit.contain),
            const SizedBox(height: 4),
            const Text(
              'AutoPro',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 4,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 500),
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Text(
            'Welcome to Caltex AutoPro',
            style: TextStyle(color: Color(0xFF1a202c), fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Sign in to your account',
            style: TextStyle(color: Color(0xFF718096), fontSize: 13),
          ),
          const SizedBox(height: 16),
          _buildTabs(),
          _buildTabViews(),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF718096),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        indicator: BoxDecoration(color: _red, borderRadius: BorderRadius.circular(8)),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Customer'),
          Tab(text: 'Staff'),
          Tab(text: 'Admin'),
        ],
      ),
    );
  }

  Widget _buildTabViews() {
    return SizedBox(
      height: 360,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildForm(
            emailCtrl: _customerEmailCtrl,
            passwordCtrl: _customerPasswordCtrl,
            passwordVisible: _customerPassVisible,
            onTogglePassword: () => setState(() => _customerPassVisible = !_customerPassVisible),
            demoEmail: 'customer@caltex.com',
            demoPass: 'customer123',
            onSubmit: () => _handleLogin('customer', _customerEmailCtrl.text, _customerPasswordCtrl.text),
          ),
          _buildForm(
            emailCtrl: _staffEmailCtrl,
            passwordCtrl: _staffPasswordCtrl,
            passwordVisible: _staffPassVisible,
            onTogglePassword: () => setState(() => _staffPassVisible = !_staffPassVisible),
            demoEmail: 'staff@caltex.com',
            demoPass: 'staff123',
            onSubmit: () => _handleLogin('staff', _staffEmailCtrl.text, _staffPasswordCtrl.text),
          ),
          _buildForm(
            emailCtrl: _adminEmailCtrl,
            passwordCtrl: _adminPasswordCtrl,
            passwordVisible: _adminPassVisible,
            onTogglePassword: () => setState(() => _adminPassVisible = !_adminPassVisible),
            demoEmail: 'admin@caltex.com',
            demoPass: 'admin123',
            buttonLabel: 'Login to Admin Panel',
            onSubmit: () => _handleLogin('admin', _adminEmailCtrl.text, _adminPasswordCtrl.text),
          ),
        ],
      ),
    );
  }

  Widget _buildForm({
    required TextEditingController emailCtrl,
    required TextEditingController passwordCtrl,
    required bool passwordVisible,
    required VoidCallback onTogglePassword,
    required String demoEmail,
    required String demoPass,
    required VoidCallback onSubmit,
    String buttonLabel = 'Sign In',
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputField(
            label: 'Email Address',
            controller: emailCtrl,
            hint: 'john.doe@email.com',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: 14),
          _buildInputField(
            label: 'Password',
            controller: passwordCtrl,
            hint: '••••••••••',
            obscure: !passwordVisible,
            prefixIcon: Icons.lock_outline,
            suffix: IconButton(
              icon: Icon(
                passwordVisible ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF718096),
              ),
              onPressed: onTogglePassword,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text('Forgot Password?',
                  style: TextStyle(color: Color(0xFF718096), fontSize: 12)),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 4,
              ),
              child: Text(buttonLabel,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Demo: $demoEmail  |  $demoPass',
              style: const TextStyle(fontSize: 11, color: Color(0xFF718096)),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    Widget? suffix,
    IconData? prefixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF4a5568))),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1a202c)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFa0aec0), fontSize: 14),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: const Color(0xFF718096), size: 20)
                : null,
            suffixIcon: suffix,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFe2e8f0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFe2e8f0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _red, width: 1.5),
            ),
            filled: true,
            fillColor: const Color(0xFFF7F8FA),
          ),
        ),
      ],
    );
  }
}
