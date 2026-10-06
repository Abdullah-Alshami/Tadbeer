import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../app/localization.dart';
import '../../app/theme.dart';
import '../../core/notifications/local_reminder_service.dart';
import '../../core/storage/user_data_store.dart';
import '../../core/utils/arabic_search_normalizer.dart';
import '../../features/reminders/reminder_model.dart';

/// Reminders management screen for scheduling local Quran recitation alerts.
///
/// EDUCATIONAL NOTE:
/// Reminder Architecture:
/// 1. 100% offline via [LocalReminderService] (OS AlarmManager / Linux D-Bus / APNS local).
/// 2. Reminders persist in [UserDataStore] and synchronize state with the OS scheduler.
/// 3. Supports Once, Daily, and specific Weekday repeat configurations.
class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  @override
  void initState() {
    super.initState();
    LocalReminderService.instance.requestPermissions();
  }

  void _openReminderDialog([ReminderItem? existing]) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    TimeOfDay selectedTime =
        existing?.time ?? const TimeOfDay(hour: 6, minute: 0);
    ReminderRepeatMode repeatMode =
        existing?.repeatMode ?? ReminderRepeatMode.daily;
    List<int> selectedDays = List.from(
      existing?.selectedDays ?? [1, 2, 3, 4, 5, 6, 7],
    );
    final titleController = TextEditingController(
      text: existing?.title ?? l10n.defaultReminderTitle,
    );

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            backgroundColor: isDark
                ? AppColors.darkBackground
                : AppColors.comsilkLight,
            title: Text(
              existing == null ? l10n.addReminder : l10n.editReminder,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title Input
                  TextField(
                    controller: titleController,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(fontFamily: 'Amiri'),
                    decoration: InputDecoration(
                      labelText: l10n.reminderTitle,
                      labelStyle: const TextStyle(fontFamily: 'Amiri'),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkSurface
                          : AppColors.comsilk,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Time Picker Button
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: AppColors.border(context)),
                    ),
                    tileColor: isDark
                        ? AppColors.darkSurface
                        : AppColors.comsilk,
                    leading: const Icon(
                      Icons.access_time,
                      color: AppColors.olive,
                    ),
                    title: Text(
                      l10n.reminderTime,
                      style: const TextStyle(fontFamily: 'Amiri', fontSize: 14),
                    ),
                    trailing: Text(
                      '${ArabicSearchNormalizer.formatDigits(selectedTime.hour, minDigits: 2)}:${ArabicSearchNormalizer.formatDigits(selectedTime.minute, minDigits: 2)}',
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.olive,
                      ),
                    ),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (picked != null) {
                        setDialogState(() => selectedTime = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Repeat Mode Radio
                  Text(
                    'نوع التكرار:',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.comsilk : AppColors.oliveDark,
                    ),
                  ),
                  RadioGroup<ReminderRepeatMode>(
                    groupValue: repeatMode,
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => repeatMode = val);
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RadioListTile<ReminderRepeatMode>(
                          value: ReminderRepeatMode.daily,
                          activeColor: AppColors.olive,
                          title: Text(
                            l10n.repeatDaily,
                            style: const TextStyle(fontFamily: 'Amiri'),
                          ),
                        ),
                        RadioListTile<ReminderRepeatMode>(
                          value: ReminderRepeatMode.once,
                          activeColor: AppColors.olive,
                          title: Text(
                            l10n.repeatOnce,
                            style: const TextStyle(fontFamily: 'Amiri'),
                          ),
                        ),
                        RadioListTile<ReminderRepeatMode>(
                          value: ReminderRepeatMode.weekdays,
                          activeColor: AppColors.olive,
                          title: Text(
                            l10n.selectDays,
                            style: const TextStyle(fontFamily: 'Amiri'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Days Selector if weekdays
                  if (repeatMode == ReminderRepeatMode.weekdays) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      children: [
                        _DayChip(
                          day: 6,
                          label: 'سبت',
                          selected: selectedDays.contains(6),
                          onToggle: () =>
                              _toggleDay(setDialogState, selectedDays, 6),
                        ),
                        _DayChip(
                          day: 7,
                          label: 'أحد',
                          selected: selectedDays.contains(7),
                          onToggle: () =>
                              _toggleDay(setDialogState, selectedDays, 7),
                        ),
                        _DayChip(
                          day: 1,
                          label: 'إثنين',
                          selected: selectedDays.contains(1),
                          onToggle: () =>
                              _toggleDay(setDialogState, selectedDays, 1),
                        ),
                        _DayChip(
                          day: 2,
                          label: 'ثلاثاء',
                          selected: selectedDays.contains(2),
                          onToggle: () =>
                              _toggleDay(setDialogState, selectedDays, 2),
                        ),
                        _DayChip(
                          day: 3,
                          label: 'أربعاء',
                          selected: selectedDays.contains(3),
                          onToggle: () =>
                              _toggleDay(setDialogState, selectedDays, 3),
                        ),
                        _DayChip(
                          day: 4,
                          label: 'خميس',
                          selected: selectedDays.contains(4),
                          onToggle: () =>
                              _toggleDay(setDialogState, selectedDays, 4),
                        ),
                        _DayChip(
                          day: 5,
                          label: 'جمعة',
                          selected: selectedDays.contains(5),
                          onToggle: () =>
                              _toggleDay(setDialogState, selectedDays, 5),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: Text(
                  l10n.cancel,
                  style: const TextStyle(fontFamily: 'Amiri'),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final reminder = ReminderItem(
                    id: existing?.id ?? const Uuid().v4(),
                    title: titleController.text.trim().isNotEmpty
                        ? titleController.text.trim()
                        : l10n.defaultReminderTitle,
                    hour: selectedTime.hour,
                    minute: selectedTime.minute,
                    repeatMode: repeatMode,
                    selectedDays: selectedDays,
                    isEnabled: existing?.isEnabled ?? true,
                    createdAt: existing?.createdAt ?? DateTime.now(),
                  );

                  await UserDataStore.instance.putReminder(reminder);
                  await LocalReminderService.instance.scheduleReminder(
                    reminder,
                  );
                  if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.olive,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  l10n.save,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _toggleDay(StateSetter setDialogState, List<int> days, int day) {
    setDialogState(() {
      if (days.contains(day)) {
        if (days.length > 1) days.remove(day);
      } else {
        days.add(day);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.reminders,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openReminderDialog(),
          backgroundColor: AppColors.olive,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.alarm_add),
          label: Text(
            l10n.addReminder,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: ListenableBuilder(
          listenable: UserDataStore.instance,
          builder: (context, _) {
            final reminders = UserDataStore.instance.reminders;

            if (reminders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.alarm,
                      size: 64,
                      color: AppColors.border(context),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.noRemindersYet,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 16,
                        color: isDark
                            ? AppColors.nightSubtitle
                            : AppColors.daySubtitle,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: reminders.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final reminder = reminders[index];
                return _ReminderCard(
                  reminder: reminder,
                  onEdit: () => _openReminderDialog(reminder),
                  onToggle: (bool val) async {
                    final updated = reminder.copyWith(isEnabled: val);
                    await UserDataStore.instance.putReminder(updated);
                    await LocalReminderService.instance.scheduleReminder(
                      updated,
                    );
                  },
                  onDelete: () async {
                    await LocalReminderService.instance.cancelReminder(
                      reminder,
                    );
                    await UserDataStore.instance.removeReminder(reminder.id);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final int day;
  final String label;
  final bool selected;
  final VoidCallback onToggle;

  const _DayChip({
    required this.day,
    required this.label,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        label,
        style: const TextStyle(fontFamily: 'Amiri', fontSize: 12),
      ),
      selected: selected,
      selectedColor: AppColors.olive.withValues(alpha: 0.25),
      checkmarkColor: AppColors.oliveDark,
      onSelected: (_) => onToggle(),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final ReminderItem reminder;
  final VoidCallback onEdit;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const _ReminderCard({
    required this.reminder,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String repeatSubtitle;
    switch (reminder.repeatMode) {
      case ReminderRepeatMode.daily:
        repeatSubtitle = 'يوميًا';
        break;
      case ReminderRepeatMode.weekdays:
        repeatSubtitle = 'أيام محددة';
        break;
      case ReminderRepeatMode.once:
        repeatSubtitle = 'مرة واحدة';
        break;
    }

    final hourStr = ArabicSearchNormalizer.formatDigits(
      reminder.hour,
      minDigits: 2,
    );
    final minStr = ArabicSearchNormalizer.formatDigits(
      reminder.minute,
      minDigits: 2,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.comsilk,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          // Time display
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$hourStr:$minStr',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: reminder.isEnabled
                      ? (isDark ? AppColors.comsilk : AppColors.oliveDark)
                      : Colors.grey,
                ),
              ),
              Text(
                repeatSubtitle,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 12,
                  color: isDark
                      ? AppColors.nightSubtitle
                      : AppColors.daySubtitle,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.nightQuranText
                        : AppColors.dayQuranText,
                  ),
                ),
              ],
            ),
          ),

          // Toggle Switch
          Switch(
            value: reminder.isEnabled,
            activeThumbColor: AppColors.olive,
            onChanged: onToggle,
          ),

          // Secondary Actions (⋮)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20),
            onSelected: (val) {
              if (val == 'edit') onEdit();
              if (val == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('تعديل'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Colors.redAccent,
                    ),
                    SizedBox(width: 8),
                    Text('حذف', style: TextStyle(color: Colors.redAccent)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
