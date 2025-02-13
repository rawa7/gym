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
      'todayexercises': 'Today exercises',
      'avenueGym': 'AVENUE GYM',
      'userId': 'User ID',
      'enterPassword': 'Enter Your Password',
      'rememberMe': 'Remember Me',
      'loginButton': 'Login',
      'loginAsGuest': 'Login as Guest',
      'workouts': 'Workouts',
      'day': 'Day',
      'exercises': 'Exercises',
      'minutes': 'Minutes',
      'sets': 'Sets',
      'reps': 'Reps',
      'complete': 'COMPLETE',
      'completed_on': 'Completed on',
      'workout_summary': 'Workout Summary',
      'total_exercises': 'Total exercises',
      'estimated_time': 'Estimated time',
      'energy_burn': 'Energy you\'ll burn',
      'calories': 'calories',
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
      'todayexercises': 'تمارين اليوم',
      'avenueGym': 'أفينيو جيم',
      'userId': 'معرف المستخدم',
      'enterPassword': 'أدخل كلمة المرور',
      'rememberMe': 'تذكرني',
      'loginButton': 'تسجيل الدخول',
      'loginAsGuest': 'الدخول كضيف',
      'workouts': 'التمارين',
      'day': 'اليوم',
      'exercises': 'التمارين',
      'minutes': 'دقائق',
      'sets': 'مجموعات',
      'reps': 'تكرارات',
      'complete': 'إكمال',
      'completed_on': 'تم الإكمال في',
      'workout_summary': 'ملخص التمرين',
      'total_exercises': 'مجموع التمارين',
      'estimated_time': 'الوقت المقدر',
      'energy_burn': 'السعرات الحرارية المحروقة',
      'calories': 'سعرة حرارية',
    },
    'fa': {
      'hello': 'سڵاو',
      'weekly_stats': 'ستاتس',
      'kcal_burnt': 'کالری سوزانده شده',
      'total_time': 'كات',
      'total_crusts': 'پۆینت',
      'lets_try': 'با دەست پێ بكەین',
      'skip': 'لێرە بگەڕێ',
      'try_celebrity': 'برنامه‌های تمرینی سلبریتی‌ها را امتحان کنید!',
      'logout': 'چوونەدەرەوە',
      'logoutConfirmation': 'دڵنیابوونەوە؟',
      'cancel': 'پاشگەزبوونەوە',
      'yes': 'بەڵێ',
      'todayexercises': 'یاریەكانی ئەمڕۆ',
      'avenueGym': 'ئەڤینیو جیم',
      'userId': 'ناسنامەی بەکارهێنەر',
      'enterPassword': 'وشەی نهێنی بنووسە',
      'rememberMe': 'بمهێڵەوە',
      'loginButton': 'چوونەژوورەوە',
      'loginAsGuest': 'وەک میوان بچۆژوورەوە',
      'workouts': 'ڕاهێنانەکان',
      'day': 'ڕۆژ',
      'exercises': 'ڕاهێنانەکان',
      'minutes': 'خولەک',
      'sets': 'سێتەکان',
      'reps': 'دووبارەکردنەوەکان',
      'complete': 'تەواوکردن',
      'completed_on': 'تەواوکرا لە',
      'workout_summary': 'کورتەی ڕاهێنان',
      'total_exercises': 'کۆی ڕاهێنانەکان',
      'estimated_time': 'کاتی خەمڵێنراو',
      'energy_burn': 'وزەی سووتاو',
      'calories': 'کالۆری',
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
  String get todayexercises => _localizedValues[locale.languageCode]!['todayexercises']!;
  String get avenueGym => _localizedValues[locale.languageCode]!['avenueGym']!;
  String get userId => _localizedValues[locale.languageCode]!['userId']!;
  String get enterPassword => _localizedValues[locale.languageCode]!['enterPassword']!;
  String get rememberMe => _localizedValues[locale.languageCode]!['rememberMe']!;
  String get loginButton => _localizedValues[locale.languageCode]!['loginButton']!;
  String get loginAsGuest => _localizedValues[locale.languageCode]!['loginAsGuest']!;
  String get workouts => _localizedValues[locale.languageCode]!['workouts']!;
  String get day => _localizedValues[locale.languageCode]!['day']!;
  String get minutes => _localizedValues[locale.languageCode]!['minutes']!;
  String get sets => _localizedValues[locale.languageCode]!['sets']!;
  String get reps => _localizedValues[locale.languageCode]!['reps']!;
  String get complete => _localizedValues[locale.languageCode]!['complete']!;
  String get completedOn => _localizedValues[locale.languageCode]!['completed_on']!;
  String get workoutSummary => _localizedValues[locale.languageCode]!['workout_summary']!;
  String get totalExercises => _localizedValues[locale.languageCode]!['total_exercises']!;
  String get estimatedTime => _localizedValues[locale.languageCode]!['estimated_time']!;
  String get energyBurn => _localizedValues[locale.languageCode]!['energy_burn']!;
  String get calories => _localizedValues[locale.languageCode]!['calories']!;
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