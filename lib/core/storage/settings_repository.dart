import 'user_data_store.dart';
import 'user_settings_model.dart';

/// Repository for managing application settings and user preferences.
class SettingsRepository {
  final UserDataStore _store;

  SettingsRepository([UserDataStore? store])
    : _store = store ?? UserDataStore.instance;

  UserSettings get currentSettings => _store.settings;

  Future<void> updateSettings(UserSettings settings) async {
    await _store.putSettings(settings);
  }
}
