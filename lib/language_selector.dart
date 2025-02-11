import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym/providers/locale_provider.dart';

class LanguageSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Locale>(
      icon: Icon(Icons.language),
      onSelected: (Locale locale) {
        Provider.of<LocaleProvider>(context, listen: false).setLocale(locale);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
        PopupMenuItem<Locale>(
          value: Locale('en'),
          child: Text('English'),
        ),
        PopupMenuItem<Locale>(
          value: Locale('ar'),
          child: Text('العربية'),
        ),
        PopupMenuItem<Locale>(
          value: Locale('fa'),
          child: Text('كوردی'),
        ),
      ],
    );
  }
} 