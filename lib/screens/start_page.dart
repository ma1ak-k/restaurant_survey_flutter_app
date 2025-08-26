import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant_survey_app/screens/user/menu_page.dart';
import 'package:restaurant_survey_app/screens/admin/admin_login_page.dart';
import 'package:restaurant_survey_app/widgets/language_switcher.dart';

class StartPage extends StatelessWidget {
  final Function(bool) toggleTheme;
  final bool isDarkMode;

  const StartPage({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  // Base palette
  static const _cream = Color(0xFFFFF7ED);
  static const _terracotta = Color(0xFFCC6B49);
  static const _plum = Color(0xFF5B3A3A);
  static const _olive = Color(0xFF7A8F55);
  static const _ink = Color(0xFF232222);

  @override
  Widget build(BuildContext context) {
    // AppBar gradient
    final appBarGrad = isDarkMode
        ? const [Color(0xFF2A1E1A), Color(0xFF3A2A25)]
        : const [Color(0xFFFFE4C7), Color(0xFFF8C9A8)];

    // Background gradient
    final bgGrad = isDarkMode
        ? const [Color(0xFF161414), Color(0xFF1E1B1B)]
        : const [_cream, Color(0xFFFFEFE0)];

    // Text colors
    final titleColor = isDarkMode ? Colors.white : _ink;
    final subColor = isDarkMode ? Colors.white70 : Colors.black54;

    // Decorative glow circles
    final glowTR = isDarkMode
        ? const Color(0x33FFFFFF)
        : const Color(0x33CC6B49);
    final glowBL = isDarkMode
        ? const Color(0x334CAF50)
        : const Color(0x337A8F55);

    // Icon badge container
    final badgeFill = isDarkMode ? const Color(0x22FFFFFF) : const Color(0x22CC6B49);
    final badgeBorder = isDarkMode ? const Color(0x22FFFFFF) : const Color(0x33CC6B49);
    final badgeIcon = _terracotta; // works on both themes

    // Card for language toggle
    final cardBg = isDarkMode ? const Color(0xFF232021) : Colors.white;
    final cardBorder = isDarkMode ? const Color(0x26FFFFFF) : const Color(0x14000000);
    final cardShadow = isDarkMode
        ? const <BoxShadow>[]
        : const [
      BoxShadow(
        color: Color(0x0F000000),
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ];

    // AppBar foreground for icons/title
    final appBarFg = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "welcome".tr,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: .2,
            color: appBarFg,
          ),
        ),
        centerTitle: true,
        actions: [
          const LanguageSwitcher(),
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode, color: appBarFg),
            onPressed: () => toggleTheme(!isDarkMode),
            tooltip: isDarkMode ? "Light" : "Dark",
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: appBarFg),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: appBarGrad,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: bgGrad,
              ),
            ),
          ),
          // subtle decorative glows
          Positioned(top: -40, right: -30, child: _blurCircle(glowTR, 140)),
          Positioned(bottom: -60, left: -40, child: _blurCircle(glowBL, 180)),

          // Content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon badge
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: badgeFill,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: badgeBorder),
                      ),
                      child: Icon(Icons.restaurant_menu, size: 66, color: badgeIcon),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      'welcome_to_restaurant'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'welcome_msg'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: subColor, height: 1.3),
                    ),
                    const SizedBox(height: 24),

                    // Buttons (logic unchanged)
                    _primaryButton(
                      icon: Icons.person,
                      label: "customer".tr,
                      background: _terracotta,
                      foreground: Colors.white,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MenuScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    _primaryButton(
                      icon: Icons.admin_panel_settings,
                      label: "admin".tr,
                      background: _plum,
                      foreground: Colors.white,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AdminLoginPage()),
                        );
                      },
                    ),

                    const SizedBox(height: 22),

                    // Language toggle
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: cardBorder),
                        boxShadow: cardShadow,
                      ),
                      child: const LanguageToggleButton(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // helpers
  static Widget _blurCircle(Color color, double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(color: color, blurRadius: 60, spreadRadius: 10),
      ],
    ),
  );

  static Widget _primaryButton({
    required IconData icon,
    required String label,
    required Color background,
    required Color foreground,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 240,
      height: 52,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 22),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: .2),
        ),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          shadowColor: Colors.black.withOpacity(.2),
        ).merge(
          ButtonStyle(
            overlayColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.pressed)
                  ? Colors.white.withOpacity(.06)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
