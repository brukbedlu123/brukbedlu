import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class S {
  S(this.locale);

  final Locale locale;

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  String get appTitle =>
      Intl.message('Acc Page', name: 'appTitle', locale: locale.toString());
  String get welcomeMessage => Intl.message('This is a themed container',
      name: 'welcomeMessage', locale: locale.toString());
  String get toggleLanguage => Intl.message('Switch to Amharic',
      name: 'toggleLanguage', locale: locale.toString());
  String get toggleTheme => Intl.message('Toggle Theme',
      name: 'toggleTheme', locale: locale.toString());
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'am'].contains(locale.languageCode);

  @override
  Future<S> load(Locale locale) => SynchronousFuture<S>(S(locale));

  @override
  bool shouldReload(_SDelegate old) => false;
}
