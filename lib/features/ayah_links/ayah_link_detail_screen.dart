import 'package:flutter/material.dart';

import '../../app/localization.dart';
import '../../core/constants/app_colors.dart';
import '../../core/storage/user_data_store.dart';
import '../../data/ayah_links/ayah_link_model.dart';
import '../../data/ayah_links/ayah_link_repository.dart';
import 'views/ayah_link_cards_view.dart';
import 'views/ayah_link_network_view.dart';
import 'views/ayah_link_ordered_view.dart';
import 'widgets/add_verse_to_link_dialog.dart';
import 'widgets/create_link_dialog.dart';

/// Screen displaying an Ayah Link across the 3 views:
/// 1. 🌐 Network Canvas
/// 2. 📜 Ordered List
/// 3. 🗂️ Cards View
class AyahLinkDetailScreen extends StatefulWidget {
  final String linkId;

  const AyahLinkDetailScreen({super.key, required this.linkId});

  @override
  State<AyahLinkDetailScreen> createState() => _AyahLinkDetailScreenState();
}

class _AyahLinkDetailScreenState extends State<AyahLinkDetailScreen> {
  final AyahLinkRepository _repo = AyahLinkRepository();
  final GlobalKey<AyahLinkNetworkViewState> _networkKey =
      GlobalKey<AyahLinkNetworkViewState>();
  late String _activeViewMode;

  @override
  void initState() {
    super.initState();
    final link = _repo.getLink(widget.linkId);
    _activeViewMode = link?.lastViewMode ?? 'network';
  }

  void _switchViewMode(String mode) {
    setState(() => _activeViewMode = mode);
    _repo.updateViewState(widget.linkId, viewMode: mode);
  }

  Future<void> _openAddVerse(AyahLinkItem link) async {
    await AddVerseToLinkDialog.show(
      context,
      linkId: link.id,
      existingAyahIds: link.verses.map((v) => v.ayahId).toList(),
    );
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
        Navigator.pop(context);
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
      child: ListenableBuilder(
        listenable: UserDataStore.instance,
        builder: (context, _) {
          final link = _repo.getLink(widget.linkId);
          if (link == null) {
            return Scaffold(
              appBar: AppBar(),
              body: const Center(child: Text('الرابط غير موجود أو تم حذفه')),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(
                link.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              actions: [
                // Secondary actions popup menu
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  tooltip: l10n.more,
                  onSelected: (val) {
                    if (val == 'autolayout') {
                      _networkKey.currentState?.autoLayout();
                    } else if (val == 'edit') {
                      _editLink(link);
                    } else if (val == 'delete') {
                      _confirmDelete(link);
                    }
                  },
                  itemBuilder: (ctx) => [
                    if (_activeViewMode == 'network')
                      PopupMenuItem(
                        value: 'autolayout',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.auto_awesome_mosaic_outlined,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(l10n.autoLayout),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
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
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurface
                        : AppColors.comsilkLight,
                    border: Border(
                      bottom: BorderSide(
                        color: isDark
                            ? AppColors.darkSurfaceVariant
                            : AppColors.lightBorder,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ViewTabButton(
                        label: l10n.networkView,
                        icon: Icons.hub_outlined,
                        isActive: _activeViewMode == 'network',
                        onTap: () => _switchViewMode('network'),
                      ),
                      const SizedBox(width: 8),
                      _ViewTabButton(
                        label: l10n.orderedView,
                        icon: Icons.format_list_numbered_rtl_rounded,
                        isActive: _activeViewMode == 'ordered',
                        onTap: () => _switchViewMode('ordered'),
                      ),
                      const SizedBox(width: 8),
                      _ViewTabButton(
                        label: l10n.cardsView,
                        icon: Icons.view_agenda_outlined,
                        isActive: _activeViewMode == 'cards',
                        onTap: () => _switchViewMode('cards'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: IndexedStack(
              index: _activeViewMode == 'network'
                  ? 0
                  : (_activeViewMode == 'ordered' ? 1 : 2),
              children: [
                AyahLinkNetworkView(
                  key: _networkKey,
                  link: link,
                  onAddVerse: () => _openAddVerse(link),
                ),
                AyahLinkOrderedView(
                  link: link,
                  onAddVerse: () => _openAddVerse(link),
                ),
                AyahLinkCardsView(
                  link: link,
                  onAddVerse: () => _openAddVerse(link),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _openAddVerse(link),
              backgroundColor: AppColors.olive,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: Text(l10n.addVerse),
            ),
          );
        },
      ),
    );
  }
}

class _ViewTabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ViewTabButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.olive : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : AppColors.olive,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? Colors.white : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
