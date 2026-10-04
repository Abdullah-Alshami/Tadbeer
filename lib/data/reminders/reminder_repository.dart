import '../../core/storage/user_data_store.dart';
import 'reminder_model.dart';

/// Repository for persisting reading reminders.
///
/// Works in tandem with [LocalReminderService] to schedule OS-level notifications.
class ReminderRepository {
  final UserDataStore _store;

  ReminderRepository([UserDataStore? store])
    : _store = store ?? UserDataStore.instance;

  List<ReminderItem> get allReminders => _store.reminders;

  Future<void> saveReminder(ReminderItem reminder) async {
    await _store.putReminder(reminder);
  }

  Future<void> deleteReminder(String id) async {
    await _store.removeReminder(id);
  }
}
