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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("welcome".tr),
        actions: [LanguageSwitcher(),
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => toggleTheme(!isDarkMode),
          ),],
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.restaurant_menu,
                size: 80,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 20),
              Text(
                'welcome_to_restaurant'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 22),
              ElevatedButton.icon(
                icon: const Icon(Icons.person),
                label: Text("customer".tr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MenuScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.admin_panel_settings),
                label: Text("admin".tr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminLoginPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              const LanguageToggleButton(),

            ],
          ),
        ),
      ),
    );
  }
}
