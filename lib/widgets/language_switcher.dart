import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/language_service.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final LanguageService languageService = Get.find<LanguageService>();

    return Obx(
          () => PopupMenuButton<String>(
        icon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              languageService.getCurrentLanguage().code.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
        onSelected: (String languageCode) {
          languageService.changeLanguage(languageCode);
        },
        itemBuilder: (BuildContext context) {
          return languageService.languages.map((language) {
            return PopupMenuItem<String>(
              value: language.code,
              child: Row(
                children: [
                  Text(language.name),
                  if (language.code == languageService.currentLanguage)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.check, color: Colors.green),
                    ),
                ],
              ),
            );
          }).toList();
        },
      ),
    );
  }
}

class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final LanguageService languageService = Get.find<LanguageService>();

    return Obx(
          () => TextButton(
        onPressed: () {
          final otherLanguage = languageService.getOtherLanguage();
          languageService.changeLanguage(otherLanguage.code);
        },
        child: Text(
          languageService.getOtherLanguage().name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
