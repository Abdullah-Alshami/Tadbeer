import 'package:flutter/material.dart';

import '../../app/localization.dart';
import '../../app/theme.dart';
import '../../core/storage/user_data_store.dart';
import '../../features/ayah_links/ayah_links_screen.dart';
import '../../features/backup/backup_screen.dart';
import '../../features/bookmarks/bookmarks_screen.dart';
import '../../features/highlights/highlights_screen.dart';
import '../../features/notes/notes_screen.dart';
import '../../features/quran/screens/quran_screen.dart';
import '../../features/reminders/reminders_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/settings/settings_screen.dart';

/// Unified Side Drawer navigation menu.
///
/// Organized to match the primary and secondary application hierarchy:
/// - Header: Close button, App Title, and Tagline
/// - 4 Main Sections:
///   1. المصحف
///   2. الأدعية
///   3. الملاحظات
///   4. روابط الآيات
/// - Section Divider & Title: "أدوات إضافية"
/// - 6 Secondary Sections:
///   المحفوظات، المميزة، البحث، التذكيرات، النسخ الاحتياطي، الإعدادات
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _navigate(BuildContext context, Widget screen) {
    Navigator.of(context).pop(); // close drawer
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _openAboutDialog(BuildContext context) {
    Navigator.of(context).pop(); // close drawer
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showAboutDialog(
      context: context,
      applicationName: 'تَدْبِير (Tadbeer)',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.menu_book_rounded,
          color: Theme.of(context).colorScheme.primary,
          size: 26,
        ),
      ),
      children: [
        Text(
          'تطبيق قرآني وتدبري هادئ بدون إنترنت، بدون إعلانات، وبدون تتبع. بياناتك وتدبراتك محفوظة محليًا على جهازك فقط.',
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: context.currentLanguage.direction,
      child: Drawer(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        child: SafeArea(
          child: Column(
            children: [
              // Drawer Header with Close button and Brand
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    // Close 'X' Button
                    Material(
                      color: isDark
                          ? AppColors.darkSurface
                          : AppColors.lightSurface,
                      shape: CircleBorder(
                        side: BorderSide(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                          width: 1,
                        ),
                      ),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.of(context).pop(),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.close_rounded, size: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // App Title & Tagline
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                l10n.appName,
                                style: TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightPrimary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.eco_rounded,
                                size: 13,
                                color: isDark
                                    ? AppColors.darkPrimary
                                    : AppColors.lightPrimary,
                              ),
                            ],
                          ),
                          Text(
                            l10n.appTagline,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Divider(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                height: 1,
                thickness: 1,
              ),

              // Navigation Items List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  children: [
                    // 1. المصحف
                    _DrawerNavTile(
                      icon: Icons.menu_book_rounded,
                      title: l10n.quran,
                      onTap: () {
                        final pos = UserDataStore.instance.readingPosition;
                        _navigate(context, QuranScreen(initialPage: pos.page));
                      },
                    ),

                    // 2. الأدعية
                    _DrawerNavTile(
                      icon: Icons.front_hand_outlined,
                      title: 'الأدعية',
                      onTap: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: isDark
                                ? AppColors.darkSurface
                                : AppColors.lightSurface,
                            content: Text(
                              'قسم الأدعية قيد التطوير قريبًا بإذن الله',
                              style: TextStyle(
                                color: AppColors.textPrimary(context),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: AppColors.border(context),
                              ),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),

                    // 3. الملاحظات
                    _DrawerNavTile(
                      icon: Icons.edit_note_rounded,
                      title: l10n.notes,
                      onTap: () => _navigate(context, const NotesScreen()),
                    ),

                    // 4. روابط الآيات
                    _DrawerNavTile(
                      icon: Icons.hub_outlined,
                      title: l10n.ayahLinks,
                      onTap: () => _navigate(context, const AyahLinksScreen()),
                    ),

                    // Section Divider & Label: "أدوات إضافية"
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 14,
                        bottom: 6,
                        right: 12,
                        left: 12,
                      ),
                      child: Text(
                        'أدوات إضافية',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),

                    // Secondary Tools
                    // 5. المحفوظات
                    _DrawerNavTile(
                      icon: Icons.bookmark_outline_rounded,
                      title: l10n.bookmarks,
                      isSecondary: true,
                      onTap: () => _navigate(context, const BookmarksScreen()),
                    ),

                    // 6. المميزة
                    _DrawerNavTile(
                      icon: Icons.palette_outlined,
                      title: l10n.highlights,
                      isSecondary: true,
                      onTap: () => _navigate(context, const HighlightsScreen()),
                    ),

                    // 7. البحث
                    _DrawerNavTile(
                      icon: Icons.search_rounded,
                      title: l10n.search,
                      isSecondary: true,
                      onTap: () => _navigate(context, const SearchScreen()),
                    ),

                    // 8. التذكيرات
                    _DrawerNavTile(
                      icon: Icons.notifications_none_rounded,
                      title: l10n.reminders,
                      isSecondary: true,
                      onTap: () => _navigate(context, const RemindersScreen()),
                    ),

                    // 9. النسخ الاحتياطي
                    _DrawerNavTile(
                      icon: Icons.cloud_upload_outlined,
                      title: l10n.backup,
                      isSecondary: true,
                      onTap: () => _navigate(context, const BackupScreen()),
                    ),

                    // 10. الإعدادات
                    _DrawerNavTile(
                      icon: Icons.settings_outlined,
                      title: l10n.settings,
                      isSecondary: true,
                      onTap: () => _navigate(context, const SettingsScreen()),
                    ),

                    const SizedBox(height: 6),
                    Divider(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                      height: 1,
                    ),
                    const SizedBox(height: 6),

                    // About
                    _DrawerNavTile(
                      icon: Icons.info_outline_rounded,
                      title: l10n.about,
                      isSecondary: true,
                      onTap: () => _openAboutDialog(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerNavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSecondary;
  final VoidCallback onTap;

  const _DrawerNavTile({
    required this.icon,
    required this.title,
    this.isSecondary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        dense: isSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(
          icon,
          color: isSecondary
              ? (isDark ? AppColors.darkAccentGold : AppColors.lightAccentGold)
              : (isDark ? AppColors.darkPrimary : AppColors.lightPrimary),
          size: isSecondary ? 20 : 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: isSecondary ? 13.5 : 14.5,
            fontWeight: isSecondary ? FontWeight.w500 : FontWeight.w600,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 13,
          color:
              (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary)
                  .withValues(alpha: 0.6),
        ),
        onTap: onTap,
        hoverColor: Theme.of(context).colorScheme.primary
            .withValues(alpha: 0.08),
        splashColor: Theme.of(context).colorScheme.primary
            .withValues(alpha: 0.12),
      ),
    );
  }
}
