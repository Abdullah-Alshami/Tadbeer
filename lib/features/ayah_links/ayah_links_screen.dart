import 'package:flutter/material.dart';

import '../../app/localization.dart';
import '../../core/constants/app_colors.dart';
import '../../core/storage/user_data_store.dart';
import '../../core/utils/arabic_search_normalizer.dart';
import '../../data/ayah_links/ayah_link_model.dart';
import '../../data/ayah_links/ayah_link_repository.dart';
import '../../data/quran/quran_repository.dart';
import 'ayah_link_detail_screen.dart';
import 'widgets/create_link_dialog.dart';

/// Main screen managing the user's personal Ayah Links (روابط الآيات).
class AyahLinksScreen extends StatefulWidget {
  const AyahLinksScreen({super.key});

  @override
  State<AyahLinksScreen> createState() => _AyahLinksScreenState();
}

class _AyahLinksScreenState extends State<AyahLinksScreen> {
  final AyahLinkRepository _repo = AyahLinkRepository();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _createLink() async {
    final created = await CreateLinkDialog.show(context);
    if (created != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AyahLinkDetailScreen(linkId: created.id),
        ),
      );
    }
  }

  Future<void> _editLink(AyahLinkItem link) async {
    await CreateLinkDialog.show(context, existingLink: link);
  }

  Future<void> _confirmDelete(AyahLinkItem link) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('حذف رابط الآيات'),
        content: Text('هل أنت متأكد من رغبتك في حذف رابط «${link.title}»؟'),
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
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _repo.deleteLink(link.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حذف رابط «${link.title}»'),
            backgroundColor: AppColors.olive,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
            l10n.ayahLinks,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        body: ListenableBuilder(
          listenable: UserDataStore.instance,
          builder: (context, _) {
            final links = _searchQuery.isEmpty
                ? _repo.allLinks
                : _repo.searchLinks(_searchQuery);

            return Column(
              children: [
                // Search Input
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'ابحث في روابط الآيات أو السور...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.olive,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkSurface
                          : AppColors.comsilkLight,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? AppColors.darkSurfaceVariant
                              : AppColors.lightBorder,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? AppColors.darkSurfaceVariant
                              : AppColors.lightBorder,
                        ),
                      ),
                    ),
                  ),
                ),

                // Content
                Expanded(
                  child: links.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: AppColors.olive.withValues(
                                      alpha: 0.15,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.hub_outlined,
                                    size: 36,
                                    color: AppColors.olive,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'لا توجد نتائج مطابقة لبحثك'
                                      : l10n.noAyahLinksYet,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'جرّب البحث بكلمة أخرى أو اسم سورة'
                                      : l10n.ayahLinksSubtitle,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? AppColors.nightSubtitle
                                        : AppColors.daySubtitle,
                                  ),
                                ),
                                if (_searchQuery.isEmpty) ...[
                                  const SizedBox(height: 20),
                                  ElevatedButton.icon(
                                    onPressed: _createLink,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.olive,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    icon: const Icon(Icons.add, size: 20),
                                    label: Text(
                                      l10n.newAyahLink,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: links.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final link = links[index];
                            final uniqueSurahs = <int>{};
                            for (final v in link.verses) {
                              uniqueSurahs.add(v.surahNumber);
                            }

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        AyahLinkDetailScreen(linkId: link.id),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkSurface
                                      : AppColors.comsilkLight,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.darkSurfaceVariant
                                        : AppColors.lightBorder,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: isDark ? 0.2 : 0.04,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title & Options
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: AppColors.olive.withValues(
                                              alpha: 0.15,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.hub_outlined,
                                            size: 18,
                                            color: AppColors.olive,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                link.title,
                                                style: TextStyle(
                                                  fontFamily: 'Amiri',
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDark
                                                      ? AppColors.comsilk
                                                      : AppColors.oliveDark,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${ArabicSearchNormalizer.toArabicDigits(link.verses.length)} آيات مرتبطة',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.olive,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          icon: const Icon(
                                            Icons.more_vert,
                                            size: 20,
                                          ),
                                          onSelected: (val) {
                                            if (val == 'edit') {
                                              _editLink(link);
                                            } else if (val == 'delete') {
                                              _confirmDelete(link);
                                            }
                                          },
                                          itemBuilder: (ctx) => [
                                            const PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.edit_outlined,
                                                    size: 18,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text('تعديل العنوان والوصف'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.delete_outline,
                                                    color: Colors.redAccent,
                                                    size: 18,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    'حذف الرابط',
                                                    style: TextStyle(
                                                      color: Colors.redAccent,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    // Description snippet (if any)
                                    if (link.description != null &&
                                        link.description!.isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      Text(
                                        link.description!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          height: 1.5,
                                          color: isDark
                                              ? AppColors.nightSubtitle
                                              : AppColors.daySubtitle,
                                        ),
                                      ),
                                    ],

                                    // Surahs Chips (if any)
                                    if (uniqueSurahs.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: uniqueSurahs.take(4).map((
                                          sNum,
                                        ) {
                                          final s = QuranRepository.instance
                                              .getSurah(sNum);
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.olive.withValues(
                                                alpha: 0.12,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              s.name,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: AppColors.olive,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _createLink,
          backgroundColor: AppColors.olive,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: Text(l10n.newAyahLink),
        ),
      ),
    );
  }
}
