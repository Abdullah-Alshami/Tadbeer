import 'package:flutter/material.dart';

import '../../app/localization.dart';
import '../../app/theme.dart';
import '../../core/storage/user_data_store.dart';
import '../ayah_links/ayah_links_screen.dart';
import '../backup/backup_screen.dart';
import '../bookmarks/bookmarks_screen.dart';
import '../highlights/highlights_screen.dart';
import '../notes/notes_screen.dart';
import '../quran/screens/quran_screen.dart';
import '../reminders/reminders_screen.dart';
import '../search/search_screen.dart';
import '../settings/settings_screen.dart';
import '../../shared/widgets/app_drawer.dart';

/// Serene, elegant Islamic dashboard for Tadbeer (تَدْبِير).
///
/// Features:
/// - Distinctive Brand Header with 'Amiri' calligraphy and subtle spiritual arch
/// - 4 Primary Cards:
///   1. المصحف (قراءة وتدبر)
///   2. الأدعية (أدعية من الكتاب والسنة)
///   3. الملاحظات (خواطرك وتدبراتك)
///   4. روابط الآيات (الآيات المرتبطة)
/// - Secondary Tools Section ("أدوات إضافية"):
///   المحفوظات، المميزة، البحث، التذكيرات، النسخ الاحتياطي، الإعدادات
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: context.currentLanguage.direction,
      child: Scaffold(
        drawer: const AppDrawer(),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 580),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top App Bar with Menu and Settings round buttons
                    _buildTopBar(context, l10n, isDark),
                    const SizedBox(height: 12),

                    // Serene Brand Header
                    _buildBrandHeader(context, l10n, isDark),
                    const SizedBox(height: 24),

                    // 4 Main Sections
                    // 1. المصحف
                    _PrimaryCard(
                      icon: Icons.menu_book_rounded,
                      title: l10n.quran,
                      subtitle: 'قراءة وتدبر',
                      accentColor: AppColors.primary(context),
                      badgeBackground: isDark
                          ? const Color(0xFF263A2F)
                          : const Color(0xFFE5EDE6),
                      onTap: () {
                        final pos = UserDataStore.instance.readingPosition;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuranScreen(initialPage: pos.page),
                          ),
                        );
                      },
                    ),

                    // 2. الأدعية
                    _PrimaryCard(
                      icon: Icons.front_hand_outlined,
                      title: 'الأدعية',
                      subtitle: 'أدعية من الكتاب والسنة',
                      accentColor: AppColors.accentGold(context),
                      badgeBackground: isDark
                          ? const Color(0xFF332D20)
                          : const Color(0xFFF7F1E2),
                      onTap: () {
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
                    _PrimaryCard(
                      icon: Icons.edit_note_rounded,
                      title: l10n.notes,
                      subtitle: 'خواطرك وتدبراتك',
                      accentColor: isDark
                          ? const Color(0xFF8BAA96)
                          : const Color(0xFF4A6B56),
                      badgeBackground: isDark
                          ? const Color(0xFF243028)
                          : const Color(0xFFE8EFEA),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotesScreen(),
                          ),
                        );
                      },
                    ),

                    // 4. روابط الآيات
                    _PrimaryCard(
                      icon: Icons.hub_outlined,
                      title: l10n.ayahLinks,
                      subtitle: 'الآيات المرتبطة',
                      accentColor: isDark
                          ? const Color(0xFFC0A66B)
                          : const Color(0xFF8B6B38),
                      badgeBackground: isDark
                          ? const Color(0xFF302B20)
                          : const Color(0xFFF6F0E4),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AyahLinksScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Secondary Tools Section Header ("أدوات إضافية")
                    _buildSectionHeader(context, isDark),
                    const SizedBox(height: 18),

                    // Secondary Tools (المحفوظات، المميزة، البحث، التذكيرات، النسخ الاحتياطي، الإعدادات)
                    _buildSecondaryToolsGrid(context, l10n, isDark),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, AppStrings l10n, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Drawer Menu Button
        Builder(
          builder: (ctx) => _TopBarIconButton(
            icon: Icons.menu_rounded,
            tooltip: 'القائمة الجانبية',
            onTap: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),

        // Settings Button
        _TopBarIconButton(
          icon: Icons.settings_outlined,
          tooltip: l10n.settings,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBrandHeader(BuildContext context, AppStrings l10n, bool isDark) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Soft atmospheric arch in the background
            CustomPaint(
              size: const Size(180, 70),
              painter: _ArchBackgroundPainter(
                color: (isDark ? AppColors.darkAccentGold : AppColors.olive)
                    .withValues(alpha: isDark ? 0.08 : 0.06),
              ),
            ),
            // Brand Title
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.appName,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightPrimary,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Icon(
                      Icons.eco_rounded,
                      size: 15,
                      color:
                          (isDark
                                  ? AppColors.darkPrimary
                                  : AppColors.lightPrimary)
                              .withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          l10n.appTagline,
          style: TextStyle(
            fontSize: 13.5,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, bool isDark) {
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Row(
      children: [
        Expanded(
          child: Divider(color: borderColor, thickness: 1, endIndent: 16),
        ),
        Text(
          'أدوات إضافية',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: textColor,
            letterSpacing: 0.3,
          ),
        ),
        Expanded(child: Divider(color: borderColor, thickness: 1, indent: 16)),
      ],
    );
  }

  Widget _buildSecondaryToolsGrid(
    BuildContext context,
    AppStrings l10n,
    bool isDark,
  ) {
    final tools = [
      _SecondaryToolItem(
        icon: Icons.bookmark_outline_rounded,
        label: l10n.bookmarks,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BookmarksScreen()),
        ),
      ),
      _SecondaryToolItem(
        icon: Icons.palette_outlined,
        label: l10n.highlights,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HighlightsScreen()),
        ),
      ),
      _SecondaryToolItem(
        icon: Icons.search_rounded,
        label: l10n.search,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchScreen()),
        ),
      ),
      _SecondaryToolItem(
        icon: Icons.notifications_none_rounded,
        label: l10n.reminders,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RemindersScreen()),
        ),
      ),
      _SecondaryToolItem(
        icon: Icons.cloud_upload_outlined,
        label: l10n.backup,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BackupScreen()),
        ),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 360) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: tools.map((t) => Expanded(child: t)).toList(),
          );
        }
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 14,
          children: tools.map((t) => SizedBox(width: 68, child: t)).toList(),
        );
      },
    );
  }
}

class _TopBarIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _TopBarIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: CircleBorder(
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.2,
        ),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        splashColor: Theme.of(context).colorScheme.primary
            .withValues(alpha: 0.15),
        hoverColor: Theme.of(context).colorScheme.primary
            .withValues(alpha: 0.08),
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(
              icon,
              size: 20,
              color: isDark ? AppColors.darkTextPrimary : AppColors.oliveDark,
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final Color badgeBackground;
  final VoidCallback onTap;

  const _PrimaryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.badgeBackground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.035),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          hoverColor: Theme.of(context).colorScheme.primary
              .withValues(alpha: 0.06),
          splashColor: Theme.of(context).colorScheme.primary
              .withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Icon illustration badge
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: badgeBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Icon(icon, color: accentColor, size: 28),
                ),
                const SizedBox(width: 16),

                // Title and Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Navigation Chevron
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color:
                      (isDark
                              ? AppColors.darkAccentGold
                              : AppColors.lightAccentGold)
                          .withValues(alpha: 0.85),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryToolItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SecondaryToolItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1.2,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            splashColor: Theme.of(context).colorScheme.primary
                .withValues(alpha: 0.15),
            hoverColor: Theme.of(context).colorScheme.primary
                .withValues(alpha: 0.08),
            child: SizedBox(
              width: 50,
              height: 50,
              child: Icon(
                icon,
                size: 22,
                color: isDark
                    ? AppColors.darkAccentGold
                    : AppColors.lightPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }
}

class _ArchBackgroundPainter extends CustomPainter {
  final Color color;

  _ArchBackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    final w = size.width;
    final h = size.height;

    // Soft Islamic arch silhouette
    path.moveTo(w * 0.1, h);
    path.lineTo(w * 0.1, h * 0.55);
    path.cubicTo(w * 0.1, h * 0.15, w * 0.35, 0, w * 0.5, 0);
    path.cubicTo(w * 0.65, 0, w * 0.9, h * 0.15, w * 0.9, h * 0.55);
    path.lineTo(w * 0.9, h);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ArchBackgroundPainter oldDelegate) =>
      oldDelegate.color != color;
}
