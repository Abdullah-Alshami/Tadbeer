import 'package:flutter/material.dart';

import '../../app/localization.dart';
import '../../core/constants/app_colors.dart';
import '../../core/storage/user_data_store.dart';
import '../../core/utils/arabic_search_normalizer.dart';
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
                _buildSectionHeader(l10n.appearance),
                _buildCard(
                  isDark: isDark,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.brightness_medium_outlined,
                          color: AppColors.olive,
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
                              color: isDark
                                  ? AppColors.oliveSoft
                                  : AppColors.olive,
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

                // 2. القراءة (Reading Settings)
                _buildSectionHeader(l10n.readingSettings),
                _buildCard(
                  isDark: isDark,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.fontSize,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              ArabicSearchNormalizer.toArabicDigits(
                                settings.quranFontSize.round(),
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.olive,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: settings.quranFontSize,
                          min: 18.0,
                          max: 34.0,
                          divisions: 8,
                          activeColor: AppColors.olive,
                          onChanged: (val) {
                            UserDataStore.instance.updateSettings(
                              settings.copyWith(quranFontSize: val),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkBackground
                                : AppColors.comsilkLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '﴿ بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ ﴾',
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontFamily: 'AmiriQuran',
                              fontSize: settings.quranFontSize,
                              color: isDark
                                  ? AppColors.nightQuranText
                                  : AppColors.dayQuranText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 3. التطبيق (Application)
                _buildSectionHeader(
                  context.currentLanguage == AppLanguage.arabic
                      ? 'التطبيق'
                      : 'Application',
                ),
                _buildCard(
                  isDark: isDark,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.language_outlined,
                          color: AppColors.olive,
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
                        leading: const Icon(
                          Icons.alarm_outlined,
                          color: AppColors.olive,
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
                  context.currentLanguage == AppLanguage.arabic
                      ? 'البيانات'
                      : 'Data',
                ),
                _buildCard(
                  isDark: isDark,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.security_outlined,
                          color: AppColors.olive,
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
                _buildSectionHeader(l10n.about),
                _buildCard(
                  isDark: isDark,
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
                                color: AppColors.olive.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.menu_book_rounded,
                                color: AppColors.olive,
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
                                        ? AppColors.comsilk
                                        : AppColors.oliveDark,
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
          const SnackBar(
            content: Text('تمت إعادة تعيين البيانات بنجاح'),
            backgroundColor: AppColors.olive,
          ),
        );
      }
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 4, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.olive,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child, required bool isDark}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.comsilk,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightBorder,
        ),
      ),
      child: child,
    );
  }
}
