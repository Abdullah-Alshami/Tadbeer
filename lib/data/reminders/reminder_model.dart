import 'package:flutter/material.dart';

enum ReminderRepeatMode { once, daily, weekdays }

/// Represents a local Quran reading reminder scheduled by the user.
///
/// Fully offline: uses local device alarms and notification APIs.
class ReminderItem {
  final String id;
  final String title;
  final int hour;
  final int minute;
  final ReminderRepeatMode repeatMode;

  /// Specific days of the week: 1 = Monday .. 7 = Sunday
  final List<int> selectedDays;
  final bool isEnabled;
  final DateTime createdAt;

  const ReminderItem({
    required this.id,
    required this.title,
    required this.hour,
    required this.minute,
    required this.repeatMode,
    this.selectedDays = const [],
    this.isEnabled = true,
    required this.createdAt,
  });

  TimeOfDay get time => TimeOfDay(hour: hour, minute: minute);

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'hour': hour,
    'minute': minute,
    'repeatMode': repeatMode.name,
    'selectedDays': selectedDays,
    'isEnabled': isEnabled,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ReminderItem.fromJson(Map<String, dynamic> json) {
    ReminderRepeatMode mode;
    switch (json['repeatMode'] as String?) {
      case 'daily':
        mode = ReminderRepeatMode.daily;
        break;
      case 'weekdays':
        mode = ReminderRepeatMode.weekdays;
        break;
      default:
        mode = ReminderRepeatMode.once;
    }

    return ReminderItem(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'ورد القرآن',
      hour: json['hour'] as int,
      minute: json['minute'] as int,
      repeatMode: mode,
      selectedDays: (json['selectedDays'] as List?)?.cast<int>() ?? const [],
      isEnabled: json['isEnabled'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  ReminderItem copyWith({
    String? title,
    int? hour,
    int? minute,
    ReminderRepeatMode? repeatMode,
    List<int>? selectedDays,
    bool? isEnabled,
  }) {
    return ReminderItem(
      id: id,
      title: title ?? this.title,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      repeatMode: repeatMode ?? this.repeatMode,
      selectedDays: selectedDays ?? this.selectedDays,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt,
    );
  }
}
