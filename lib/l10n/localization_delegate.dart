import 'package:flutter/material.dart';
import 'localization_strings.dart';

/// Localization Delegate
class LocalizationDelegate extends LocalizationsDelegate<LocalizationStrings> {
  const LocalizationDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar', 'en'].contains(locale.languageCode);
  }

  @override
  Future<LocalizationStrings> load(Locale locale) async {
    return LocalizationStrings();
  }

  @override
  bool shouldReload(LocalizationDelegate old) => false;
}

/// Extension for easy access
extension LocalizationExtension on BuildContext {
  String t(String key, {String locale = 'ar'}) {
    return LocalizationStrings.t(key, locale: locale);
  }
}
