import 'package:flutter/material.dart';

import '../core/storage/user_data_store.dart';
import '../features/home/home_screen.dart';
import '../features/tadabbur/tadbeer_intro_screen.dart';
import 'localization.dart';
import 'theme.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// Root application widget for Tadbeer.
///
/// EDUCATIONAL NOTE:
/// Listens to [UserDataStore] to reactively update themes, font scales,
/// or language settings without restarting the application.
class TadbeerApp extends StatefulWidget {
  const TadbeerApp({super.key});

  @override
  State<TadbeerApp> createState() => _TadbeerAppState();
}

class _TadbeerAppState extends State<TadbeerApp> {
  late AppLanguage _currentLanguage;
  late bool _initialHideIntro;

  @override
  void initState() {
    super.initState();
    final savedCode = UserDataStore.instance.settings.languageCode;
    _currentLanguage = AppLanguage.fromCode(savedCode);
    _initialHideIntro =
        UserDataStore.instance.settings.hideTadbeerIntroPermanently;
  }

  void _onLanguageChanged(AppLanguage newLang) {
    setState(() {
      _currentLanguage = newLang;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: UserDataStore.instance,
      builder: (context, _) {
        final settings = UserDataStore.instance.settings;

        return AppLocalizationScope(
          currentLanguage: _currentLanguage,
          strings: AppStrings(_currentLanguage),
          onLanguageChanged: _onLanguageChanged,
          child: MaterialApp(
            navigatorKey: appNavigatorKey,
            title: 'تَدْبِير · Tadbeer',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            home: _initialHideIntro
                ? const HomeScreen()
                : const TadbeerIntroScreen(),
          ),
        );
      },
    );
  }
}
