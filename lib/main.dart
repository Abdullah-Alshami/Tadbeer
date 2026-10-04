import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/notifications/local_reminder_service.dart';
import 'core/storage/user_data_store.dart';
import 'data/quran/quran_repository.dart';
import 'features/quran/quran_screen.dart';

/// Entrypoint for the Tadbeer application.
///
/// EDUCATIONAL NOTE:
/// Tadbeer is 100% offline-first. Initialization sequence:
/// 1. Initialize local persistent JSON user storage ([UserDataStore]).
/// 2. Initialize authentic, verified Uthmani Quran dataset ([QuranRepository]).
/// 3. Initialize local offline reminders ([LocalReminderService]) with deep link payload routing.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize local persistent storage
  await UserDataStore.instance.init();

  // 2. Initialize verified Quran dataset
  await QuranRepository.instance.init();

  // 3. Initialize local reading reminders
  await LocalReminderService.instance.init(
    onTapped: (payload) {
      if (payload == 'quran_resume') {
        appNavigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const QuranScreen()),
        );
      }
    },
  );

  runApp(const TadbeerApp());
}
