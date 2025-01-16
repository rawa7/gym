import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'hello': 'Hello,',
      'weekly_stats': 'Weekly stats',
      'kcal_burnt': 'kcal burnt',
      'total_time': 'total time',
      'total_crusts': 'total crusts',
      'lets_try': "Let's try",
      'skip': 'Skip',
      'try_celebrity': 'Try celebrity training programs!',
      'logout': 'Logout',
      'logoutConfirmation': 'Are you sure you want to logout?',
      'cancel': 'Cancel',
      'yes': 'Yes',
    },
    'ar': {
      'hello': 'مرحباً،',
      'weekly_stats': 'إحصائيات الأسبوع',
      'kcal_burnt': 'سعرات حرارية محروقة',
      'total_time': 'الوقت الإجمالي',
      'total_crusts': 'مجموع النقاط',
      'lets_try': 'هيا نجرب',
      'skip': 'تخطي',
      'try_celebrity': 'جرب برامج تدريب المشاهير!',
      'logout': 'تسجيل خروج',
      'logoutConfirmation': 'هل أنت متأكد أنك تريد تسجيل الخروج؟',
      'cancel': 'إلغاء',
      'yes': 'نعم',
    },
    'fa': {
      'hello': 'سلام،',
      'weekly_stats': 'آمار هفتگی',
      'kcal_burnt': 'کالری سوزانده شده',
      'total_time': 'زمان کل',
      'total_crusts': 'مجموع امتیازات',
      'lets_try': 'بیا امتحان کنیم',
      'skip': 'رد کردن',
      'try_celebrity': 'برنامه‌های تمرینی سلبریتی‌ها را امتحان کنید!',
      'logout': 'خروج',
      'logoutConfirmation': 'آیا مطمئن هستید که می‌خواهید خارج شوید؟',
      'cancel': 'لغو',
      'yes': 'بله',
    },
  };

  String get hello => _localizedValues[locale.languageCode]!['hello']!;
  String get weeklyStats => _localizedValues[locale.languageCode]!['weekly_stats']!;
  String get kcalBurnt => _localizedValues[locale.languageCode]!['kcal_burnt']!;
  String get totalTime => _localizedValues[locale.languageCode]!['total_time']!;
  String get totalCrusts => _localizedValues[locale.languageCode]!['total_crusts']!;
  String get letsTry => _localizedValues[locale.languageCode]!['lets_try']!;
  String get skip => _localizedValues[locale.languageCode]!['skip']!;
  String get tryCelebrity => _localizedValues[locale.languageCode]!['try_celebrity']!;
  String get exercises => 'Exercises';
  String get daysThisMonth => 'Days this month';
  String get logout => _localizedValues[locale.languageCode]!['logout']!;
  String get logoutConfirmation => _localizedValues[locale.languageCode]!['logoutConfirmation']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get yes => _localizedValues[locale.languageCode]!['yes']!;
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar', 'fa'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
} 