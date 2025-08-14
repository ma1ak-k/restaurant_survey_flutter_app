import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant_survey_app/screens/translations/messages.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:restaurant_survey_app/screens/start_page.dart';
import 'package:restaurant_survey_app/services/language_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

late final SupabaseClient supabase;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://szvputxwnsmkuukkzhlk.supabase.co',
    anonKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN6dnB1dHh3bnNta3V1a2t6aGxrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ5MjM3MTUsImV4cCI6MjA3MDQ5OTcxNX0.1eQIk_a5YL4oyZxtxlsaB5TVzeijL9Hgr7hOo4p2QJ0',
  );

  supabase = Supabase.instance.client;
  Get.put(LanguageService());

  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;

  runApp(MyApp(isDarkMode: isDarkMode));
}

class MyApp extends StatefulWidget {
  final bool isDarkMode;
  const MyApp({super.key, required this.isDarkMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
  }

  void _toggleTheme(bool isDark) async {
    setState(() {
      _isDarkMode = isDark;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Restaurant Survey App',
      theme: _isDarkMode ? _darkTheme : _lightTheme,
      translations: Messages(),

      // Default to English
      locale: const Locale('en'),
      fallbackLocale: const Locale('en'),

      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Switch direction based on current locale (LTR for en, RTL for ar)
      builder: (context, child) {
        return Directionality(
          textDirection: Get.locale?.languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: child!,
        );
      },


      home: StartPage(
        toggleTheme: _toggleTheme,
        isDarkMode: _isDarkMode,
      ),
    );
  }

  final ThemeData _lightTheme = ThemeData(
    primarySwatch: Colors.deepPurple,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
    ),
  );

  final ThemeData _darkTheme = ThemeData(
    primarySwatch: Colors.deepPurple,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[800],
      foregroundColor: Colors.white,
    ),
    // cardTheme: CardTheme(
    //   color: Colors.grey[800],
    // ),
  );
}
