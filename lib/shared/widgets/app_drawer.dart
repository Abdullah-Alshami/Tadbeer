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
/// Follows the structured navigation layout:
/// - Main Sections: Quran, Notes, Bookmarks, Highlights, Search
/// - Divider
/// - Secondary Sections: Reminders, Backup, Settings, About Tadbeer
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
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Drawer(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                border: Border(
                  bottom: BorderSide(color: AppColors.border(context)),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      color: primaryColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.appName,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightPrimaryDark,
                        ),
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
                ],
              ),
            ),

            // Navigation Items List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                children: [
                  // Main Sections
                  _DrawerTile(
                    icon: Icons.menu_book_rounded,
                    title: l10n.quran,
                    onTap: () {
                      final pos = UserDataStore.instance.readingPosition;
                      _navigate(context, QuranScreen(initialPage: pos.page));
                    },
                  ),
                  _DrawerTile(
                    icon: Icons.edit_note_rounded,
                    title: l10n.notes,
                    onTap: () => _navigate(context, const NotesScreen()),
                  ),
                  _DrawerTile(
                    icon: Icons.bookmark_rounded,
                    title: l10n.bookmarks,
                    onTap: () => _navigate(context, const BookmarksScreen()),
                  ),
                  _DrawerTile(
                    icon: Icons.palette_outlined,
                    title: l10n.highlights,
                    onTap: () => _navigate(context, const HighlightsScreen()),
                  ),
                  _DrawerTile(
                    icon: Icons.hub_outlined,
                    title: l10n.ayahLinks,
                    onTap: () => _navigate(context, const AyahLinksScreen()),
                  ),
                  _DrawerTile(
                    icon: Icons.search_rounded,
                    title: l10n.search,
                    onTap: () => _navigate(context, const SearchScreen()),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(height: 1),
                  ),

                  // Secondary Sections
                  _DrawerTile(
                    icon: Icons.alarm_rounded,
                    title: l10n.reminders,
                    onTap: () => _navigate(context, const RemindersScreen()),
                  ),
                  _DrawerTile(
                    icon: Icons.shield_outlined,
                    title: l10n.backup,
                    onTap: () => _navigate(context, const BackupScreen()),
                  ),
                  _DrawerTile(
                    icon: Icons.settings_outlined,
                    title: l10n.settings,
                    onTap: () => _navigate(context, const SettingsScreen()),
                  ),
                  _DrawerTile(
                    icon: Icons.info_outline_rounded,
                    title: l10n.about,
                    onTap: () => _openAboutDialog(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        leading: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.nightQuranText : AppColors.dayQuranText,
          ),
        ),
        onTap: onTap,
        hoverColor: Theme.of(context).colorScheme.primary
            .withValues(alpha: 0.1),
      ),
    );
  }
}
