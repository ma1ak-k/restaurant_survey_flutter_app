import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LanguageService extends GetxService {
  // Observable for current language
  final _currentLanguage = 'en'.obs; // Default to Arabic
  String get currentLanguage => _currentLanguage.value;

  // Available languages
  final List<Language> languages = [
    Language('ar', 'العربية', 'assets/flags/ar.png'),
    Language('en', 'English', 'assets/flags/en.png'),
  ];

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
  }

  void _loadSavedLanguage() {
    changeLanguage('ar');
  }


  void changeLanguage(String code) {
    if (code == _currentLanguage.value) return;
    _currentLanguage.value = code;
    Get.updateLocale(Locale(code));
  }

  bool isRTL() {
    return currentLanguage == 'ar';
  }

  Language getCurrentLanguage() {
    return languages.firstWhere(
          (lang) => lang.code == currentLanguage,
      orElse: () => languages.first,
    );
  }

  Language getOtherLanguage() {
    return languages.firstWhere(
          (lang) => lang.code != currentLanguage,
      orElse: () => languages.last,
    );
  }
}

class Language {
  final String code;
  final String name;
  final String flag;

  Language(this.code, this.name, this.flag);
}
