import 'package:get/get.dart';

class MealTranslationService extends GetxService {
  // Arabic translations for meal names
  static const Map<String, String> _mealNames = {
    'Koshari': 'كشري',
    'Ful Medames': 'فول مدمس',
    'Molokhia': 'ملوخية',
    'Hawawshi': 'حواوشي',
    'Mahshi': 'محشي',
    'Fatta': 'فتة',
    'Taameya (Falafel)': 'طعمية (فلافل)',
    'Shawerma': 'شاورما',
    'Kofta': 'كفتة',
    'Feseekh': 'فسيخ',
    'Umm Ali': 'أم علي',
    'Basbousa': 'بسبوسة',
    'Konafa': 'كنافة',
    'Qatayef': 'قطايف',
    'Mahalabia': 'مهلبية',
  };

  // Arabic translations for meal descriptions
  static const Map<String, String> _mealDescriptions = {
    'Koshari':
    'الطبق الشعبي المصري المكون من الأرز والعدس والمكرونة والحمص مع الصلصة الحارة والبصل المحمر.',
    'Ful Medames':
    'الفول المسلوق ببطء مع الثوم والليمون وزيت الزيتون، يُقدم مع الخبز.',
    'Molokhia':
    'شوربة أوراق الملوخية مع الثوم والكزبرة، تُقدم مع الأرز أو الخبز.',
    'Hawawshi':
    'اللحم المفروم المتبل محشو في الخبز البلدي، مخبوز حتى يصبح مقرمش.',
    'Mahshi': 'خضروات محشوة بالأرز المتبل، مطبوخة في صلصة الطماطم.',
    'Fatta': 'طبقات من الأرز والخبز ومرق اللحم بالثوم وقطع الضان.',
    'Taameya (Falafel)':
    'أقراص الفول المدمس مع الأعشاب، مقلية، تُقدم مع الطحينة.',
    'Shawerma':
    'لحم البقر/الدجاج المتبل مشوي على السيخ، يُقدم في الخبز مع صلصة الثوم.',
    'Kofta': 'كرات اللحم المتبلة مشوية، تُقدم مع الأرز والسلطة.',
    'Feseekh': 'سمك البوري المخمر، يُؤكل تقليدياً في عيد شم النسيم.',
    'Umm Ali':
    'بودينغ الخبز المصري بالحليب والمكسرات والزبيب وجوز الهند، مخبوز حتى يصبح ذهبي.',
    'Basbousa': 'كيك السميد المنقوع بالشيرة مع جوز الهند.',
    'Konafa': 'عجينة الكنافة المحشوة بالجبن أو المكسرات، مغموسة في الشيرة.',
    'Qatayef':
    'فطائر محشوة بالجبن أو المكسرات، مقلية أو مشوية، تُقدم مع الشيرة.',
    'Mahalabia':
    'حلوى الأرز بالحليب مع ماء الورد، تُقدم باردة ومزينة بالمكسرات.',
  };

  // Get translated meal name
  static String getMealName(String englishName, String currentLanguage) {
    if (currentLanguage == 'ar' && _mealNames.containsKey(englishName)) {
      return _mealNames[englishName]!;
    }
    return englishName;
  }

  // Get translated meal description
  static String getMealDescription(
      String englishName,
      String originalDescription,
      String currentLanguage,
      ) {
    if (currentLanguage == 'ar' && _mealDescriptions.containsKey(englishName)) {
      return _mealDescriptions[englishName]!;
    }
    return originalDescription;
  }

  // Get all available meal translations (for debugging/admin purposes)
  static Map<String, String> getAllMealNames() => _mealNames;
  static Map<String, String> getAllMealDescriptions() => _mealDescriptions;
}
