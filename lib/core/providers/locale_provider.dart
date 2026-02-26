import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../l10n/app_localizations.dart';

// Locale State Notifier
class LocaleNotifier extends StateNotifier<String> {
  LocaleNotifier() : super('id') {
    _loadLocale();
  }

  void _loadLocale() {
    final box = Hive.box('settings');
    final savedLocale = box.get('language', defaultValue: 'id');
    state = savedLocale;
  }

  void setLocale(String languageCode) {
    if (languageCode == 'id' || languageCode == 'en') {
      final box = Hive.box('settings');
      box.put('language', languageCode);
      state = languageCode;
    }
  }
}

// Provider for the Current Locale Code ('id' or 'en')
final localeProvider = StateNotifierProvider<LocaleNotifier, String>((ref) {
  return LocaleNotifier();
});

// Provider for the Translations themselves
final l10nProvider = Provider<AppLocalizations>((ref) {
  final locale = ref.watch(localeProvider);
  return AppLocalizations(locale);
});
