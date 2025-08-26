import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant_survey_app/screens/admin/admin_menu_page.dart';
import 'package:restaurant_survey_app/widgets/language_switcher.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final String _adminUsername = 'admin';
  final String _adminPassword = 'admin123';

  void _login() {
    if (_usernameController.text == _adminUsername &&
        _passwordController.text == _adminPassword) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminMenuPage()),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('invalid_credentials'.tr)));
    }
  }

  // palette
  static const _cream = Color(0xFFFFF7ED);
  static const _terracotta = Color(0xFFCC6B49);
  static const _ink = Color(0xFF232222);

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    required bool isDark,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: isDark ? Colors.white70 : Colors.black54),
      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
      filled: true,
      fillColor: isDark ? const Color(0x1AFFFFFF) : const Color(0x0DCC6B49),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? const Color(0x26FFFFFF) : const Color(0x33CC6B49),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? Colors.white70 : _terracotta,
          width: 1.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'admin_login'.tr,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: const [LanguageSwitcher()],
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? const [Color(0xFF2A1E1A), Color(0xFF3A2A25)]
                  : const [Color(0xFFFFE4C7), Color(0xFFF8C9A8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
      ),

      body: Stack(
        children: [
          // background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? const [Color(0xFF161414), Color(0xFF1E1B1B)]
                    : const [_cream, Color(0xFFFFEFE0)],
              ),
            ),
          ),
          Positioned(
            top: -50,
            right: -40,
            child: _blurCircle(isDark ? const Color(0x33FFFFFF) : const Color(0x33CC6B49), 150),
          ),
          Positioned(
            bottom: -70,
            left: -50,
            child: _blurCircle(isDark ? const Color(0x334CAF50) : const Color(0x337A8F55), 190),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  elevation: 0,
                  color: isDark ? const Color(0xFF232021) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDark ? const Color(0x26FFFFFF) : const Color(0x14000000),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // little badge/icon
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0x22FFFFFF) : const Color(0x22CC6B49),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? const Color(0x22FFFFFF) : const Color(0x33CC6B49),
                            ),
                          ),
                          child: Icon(Icons.admin_panel_settings,
                              size: 36, color: isDark ? Colors.white : _terracotta),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'admin_login'.tr,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : _ink,
                          ),
                        ),
                        const SizedBox(height: 20),

                        TextField(
                          controller: _usernameController,
                          decoration: _inputDecoration(
                            label: 'username'.tr,
                            icon: Icons.person,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: _inputDecoration(
                            label: 'password'.tr,
                            icon: Icons.lock,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(height: 20),

                        SizedBox(
                          width: 220,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _terracotta,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                              elevation: 0,
                            ),
                            child: Text('login'.tr,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, letterSpacing: .2)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _blurCircle(Color color, double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      boxShadow: [BoxShadow(color: color, blurRadius: 60, spreadRadius: 10)],
    ),
  );
}
