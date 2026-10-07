import 'package:flutter/material.dart';

import '../../app/localization.dart';
import '../../app/theme.dart';
import '../../core/storage/user_data_store.dart';
import '../backup/backup_screen.dart';
import '../reminders/reminders_screen.dart';

/// Settings screen for managing appearance, Quran font scale, language, and data reset.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: context.currentLanguage.direction,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.settings,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        body: ListenableBuilder(
          listenable: UserDataStore.instance,
          builder: (context, _) {
            final settings = UserDataStore.instance.settings;

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // 1. المظهر (Appearance)
                _buildSectionHeader(context, l10n.appearance),
                _buildCard(
                  context: context,
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.brightness_medium_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(
                          l10n.themeMode,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          settings.themeMode == ThemeMode.light
                              ? l10n.light
                              : settings.themeMode == ThemeMode.dark
                              ? l10n.dark
                              : l10n.system,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.nightSubtitle
                                : AppColors.daySubtitle,
                          ),
                        ),
                        trailing: DropdownButton<ThemeMode>(
                          value: settings.themeMode,
                          underline: const SizedBox(),
                          onChanged: (mode) {
                            if (mode != null) {
                              UserDataStore.instance.updateSettings(
                                settings.copyWith(themeMode: mode),
                              );
                            }
                          },
                          items: [
                            DropdownMenuItem(
                              value: ThemeMode.light,
                              child: Text(l10n.light),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.dark,
                              child: Text(l10n.dark),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.system,
                              child: Text(l10n.system),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.remove_red_eye_outlined,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'راحة العين: الوضع الداكن والألوان الهادئة صُممت خصيصاً لتقليل إجهاد النظر أثناء التلاوة والتدبر الطويل.',
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.5,
                                  color: isDark
                                      ? AppColors.nightSubtitle
                                      : AppColors.daySubtitle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. القراءة ومصحف المدينة
                _buildSectionHeader(context, l10n.readingSettings),
                _buildCard(
                  context: context,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary
                                .withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.menu_book_rounded,
                            color: Theme.of(context).colorScheme.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'مصحف المدينة النبوية',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'تخطيط مجمع الملك فهد (١٤٢١هـ) — ٦٠٤ صفحات ثابتة',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.nightSubtitle
                                      : AppColors.oliveDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // حجم خط المصحف (Quran Font Size)
                _buildSectionHeader(
                  context,
                  context.currentLanguage == AppLanguage.arabic
                      ? 'حجم خط المصحف'
                      : 'Quran Font Size',
                ),
                _buildCard(
                  context: context,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.format_size_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  context.currentLanguage == AppLanguage.arabic
                                      ? 'حجم الخط'
                                      : 'Font Size',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${settings.quranFontSize.round()}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Theme.of(context)
                                .colorScheme
                                .primary,
                            thumbColor: Theme.of(context).colorScheme.primary,
                            overlayColor: Theme.of(context).colorScheme.primary
                                .withValues(alpha: 0.15),
                            valueIndicatorTextStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: Slider(
                            value: settings.quranFontSize.clamp(18.0, 28.0),
                            min: 18.0,
                            max: 28.0,
                            divisions: 10,
                            label: '${settings.quranFontSize.round()}',
                            onChanged: (newVal) {
                              UserDataStore.instance.setQuranFontSize(
                                newVal.roundToDouble(),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '18',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.nightSubtitle
                                      : AppColors.daySubtitle,
                                ),
                              ),
                              Text(
                                context.currentLanguage == AppLanguage.arabic
                                    ? '23 (افتراضي)'
                                    : '23 (Default)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? AppColors.nightSubtitle
                                      : AppColors.daySubtitle,
                                ),
                              ),
                              Text(
                                '28',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.nightSubtitle
                                      : AppColors.daySubtitle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 3. التطبيق (Application)
                _buildSectionHeader(
                  context,
                  context.currentLanguage == AppLanguage.arabic
                      ? 'التطبيق'
                      : 'Application',
                ),
                _buildCard(
                  context: context,
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.language_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(
                          l10n.languageTitle,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          settings.languageCode == 'ar'
                              ? 'العربية (افتراضي)'
                              : 'English',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.nightSubtitle
                                : AppColors.daySubtitle,
                          ),
                        ),
                        trailing: DropdownButton<String>(
                          value: settings.languageCode,
                          underline: const SizedBox(),
                          onChanged: (code) {
                            if (code != null) {
                              UserDataStore.instance.updateSettings(
                                settings.copyWith(languageCode: code),
                              );
                              AppLocalizationScope.of(
                                context,
                              ).onLanguageChanged(AppLanguage.fromCode(code));
                            }
                          },
                          items: const [
                            DropdownMenuItem(
                              value: 'ar',
                              child: Text('العربية'),
                            ),
                            DropdownMenuItem(
                              value: 'en',
                              child: Text('English'),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(
                          Icons.alarm_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(
                          l10n.reminders,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'تنبيهات الورد اليومي ومواعيد القراءة',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.nightSubtitle
                                : AppColors.daySubtitle,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RemindersScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 4. البيانات (Data)
                _buildSectionHeader(
                  context,
                  context.currentLanguage == AppLanguage.arabic
                      ? 'البيانات'
                      : 'Data',
                ),
                _buildCard(
                  context: context,
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.security_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(
                          l10n.backup,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'تصدير واستعادة ملفات مشفرة بدون اتصال',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.nightSubtitle
                                : AppColors.daySubtitle,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BackupScreen(),
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(
                          Icons.delete_sweep_outlined,
                          color: Colors.redAccent,
                        ),
                        title: const Text(
                          'إعادة تعيين البيانات',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.redAccent,
                          ),
                        ),
                        subtitle: Text(
                          'حذف الملاحظات والمحفوظات والتمييزات واستعادة الإعدادات الأصلية',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.nightSubtitle
                                : AppColors.daySubtitle,
                          ),
                        ),
                        onTap: () => _confirmResetData(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 5. حول (About)
                _buildSectionHeader(context, l10n.about),
                _buildCard(
                  context: context,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary
                                    .withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.menu_book_rounded,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.appName,
                                  style: TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightPrimaryDark,
                                  ),
                                ),
                                Text(
                                  'الإصدار ١.٠.٠ · مجاني وبدون إعلانات أو إنترنت',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.nightSubtitle
                                        : AppColors.daySubtitle,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          l10n.aboutContent,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.6,
                            color: isDark
                                ? AppColors.nightSubtitle
                                : AppColors.daySubtitle,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Divider(height: 1),
                        const SizedBox(height: 10),
                        Text(
                          'المصادر والتراخيص المفتوحة:\n• النص القرآني المعتمد: Tanzil Project (CC-BY 3.0)\n• خط المصحف الشريف: Amiri Quran (SIL Open Font License)\n• خط العناوين والواجهة: Amiri Font (SIL Open Font License)\n• تشفير النسخ الاحتياطية: AES-256 محلي بالكامل',
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.6,
                            color: isDark
                                ? AppColors.nightSubtitle
                                : AppColors.daySubtitle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmResetData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('إعادة تعيين البيانات'),
        content: const Text(
          'هل أنت متأكد من رغبتك في حذف جميع الملاحظات والمحفوظات والتمييزات واستعادة الإعدادات الأصلية للتطبيق؟\n\nلا يمكن التراجع عن هذا الإجراء إلا إذا كانت لديك نسخة احتياطية سابقة.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('تأكيد إعادة التعيين'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await UserDataStore.instance.resetAllUserData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تمت إعادة تعيين البيانات بنجاح'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 4, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child, required BuildContext context}) {
    return Material(
      color: AppColors.surface(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.border(context)),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
