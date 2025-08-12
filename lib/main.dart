import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:restaurant_survey_app/screens/user/menu_page.dart';
import 'package:restaurant_survey_app/screens/admin/admin_login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

late final SupabaseClient supabase;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://szvputxwnsmkuukkzhlk.supabase.co',
    anonKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN6dnB1dHh3bnNta3V1a2t6aGxrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ5MjM3MTUsImV4cCI6MjA3MDQ5OTcxNX0.1eQIk_a5YL4oyZxtxlsaB5TVzeijL9Hgr7hOo4p2QJ0',
  );

  supabase = Supabase.instance.client;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Restaurant Survey App',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('User'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MenuScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Admin'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminLoginPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
