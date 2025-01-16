import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gym/l10n/app_localizations.dart';
import 'package:gym/days_screen.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'exercise_screen.dart';
import 'package:provider/provider.dart';
import 'package:gym/providers/locale_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        final isRTL = localeProvider.locale.languageCode == 'ar' || 
                     localeProvider.locale.languageCode == 'fa';
                     
        return MaterialApp(
          locale: localeProvider.locale,
          debugShowCheckedModeBanner: false,
          title: 'Navigation Example',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          initialRoute: '/login',
          routes: {
            '/login': (context) => LoginScreen(),
            '/home': (context) => HomeScreen(),
            '/days': (context) => DaysScreen(),
            '/exercises': (context) => ExerciseScreen(),
          },
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
            Locale('fa'),
          ],
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          builder: (context, child) {
            return Directionality(
              textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                ),
                child: child!,
              ),
            );
          },
        );
      },
    );
  }
}

class UnknownScreen extends StatelessWidget {
  final String? routeName;

  const UnknownScreen({Key? key, this.routeName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unknown Route')),
      body: Center(
        child: Text('No route defined for "$routeName"'),
      ),
    );
  }
}
