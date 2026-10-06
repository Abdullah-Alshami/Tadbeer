import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/storage/user_data_store.dart';
import '../../../core/utils/arabic_search_normalizer.dart';
import '../../../data/ayah_links/ayah_link_model.dart';
import '../../../data/ayah_links/ayah_link_repository.dart';
import '../../../data/quran/quran_repository.dart';
import '../../quran/quran_screen.dart';

/// Flagship interactive Network Canvas View for an Ayah Link.
///
/// Features:
/// - Virtual canvas with central theme node and surrounding verse nodes.
/// - Deterministic radial auto-layout preventing node collisions.
/// - Drag-and-drop manual positioning with state persistence.
/// - Pan & pinch-to-zoom navigation via [InteractiveViewer].
/// - Floating directional pad (↑, ↓, ←, →, ⌾ center, +, -).
/// - Smooth animated camera focus when tapping an ayah.
/// - Detailed verse inspector bottom sheet.
class AyahLinkNetworkView extends StatefulWidget {
  final AyahLinkItem link;
  final VoidCallback onAddVerse;

  const AyahLinkNetworkView({
    super.key,
    required this.link,
    required this.onAddVerse,
  });

  @override
  State<AyahLinkNetworkView> createState() => AyahLinkNetworkViewState();
}

class AyahLinkNetworkViewState extends State<AyahLinkNetworkView>
    with SingleTickerProviderStateMixin {
  static const double _canvasSize = 3000.0;
  static const double _centerCoord = _canvasSize / 2; // 1500.0

  late TransformationController _transformController;
  late AnimationController _animController;
  Animation<Matrix4>? _matrixAnimation;

  // Local mutable positions for real-time drag responsiveness
  final Map<String, Offset> _positions = {};

  final AyahLinkRepository _repo = AyahLinkRepository();

  @override
  void initState() {
    super.initState();
    _transformController = TransformationController();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _syncPositionsFromLink();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initOrRestoreViewport();
    });
  }

  @override
  void didUpdateWidget(covariant AyahLinkNetworkView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.link.verses.length != widget.link.verses.length ||
        oldWidget.link.isManualLayout != widget.link.isManualLayout ||
        oldWidget.link.positions != widget.link.positions) {
      _syncPositionsFromLink();
    }
  }

  @override
  void dispose() {
    _transformController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _syncPositionsFromLink() {
    final existing = widget.link.positions;
    final verses = widget.link.verses;

    if (!widget.link.isManualLayout || existing.isEmpty) {
      // Compute radial auto layout
      _computeAutoLayoutPositions(verses);
    } else {
      _positions.clear();
      for (final v in verses) {
        final pos = existing[v.ayahKey];
        if (pos != null) {
          _positions[v.ayahKey] = Offset(pos.dx, pos.dy);
        }
      }
      // For any newly added verses without saved position, assign auto-slot
      _assignMissingVersePositions(verses);
    }
  }

  void _computeAutoLayoutPositions(List<AyahLinkVerse> verses) {
    _positions.clear();
    final count = verses.length;
    if (count == 0) return;

    final fontSize = UserDataStore.instance.settings.ayahLinkFontSize;
    final scaleRatio = (fontSize / 18.0).clamp(0.85, 1.45);

    if (count <= 8) {
      final radius = 320.0 * scaleRatio;
      for (int i = 0; i < count; i++) {
        final angle = (2 * math.pi * i / count) - (math.pi / 2);
        final x = _centerCoord + radius * math.cos(angle);
        final y = _centerCoord + radius * math.sin(angle);
        _positions[verses[i].ayahKey] = Offset(x, y);
      }
    } else if (count <= 18) {
      final innerCount = math.min(6, (count / 2).ceil());
      final outerCount = count - innerCount;

      final r1 = 280.0 * scaleRatio;
      for (int i = 0; i < innerCount; i++) {
        final angle = (2 * math.pi * i / innerCount) - (math.pi / 2);
        final x = _centerCoord + r1 * math.cos(angle);
        final y = _centerCoord + r1 * math.sin(angle);
        _positions[verses[i].ayahKey] = Offset(x, y);
      }

      final r2 = 490.0 * scaleRatio;
      for (int i = 0; i < outerCount; i++) {
        final angle = (2 * math.pi * i / outerCount) - (math.pi / 3);
        final x = _centerCoord + r2 * math.cos(angle);
        final y = _centerCoord + r2 * math.sin(angle);
        _positions[verses[innerCount + i].ayahKey] = Offset(x, y);
      }
    } else {
      // Concentric rings with minimum angular distance
      int assigned = 0;
      int ringIndex = 0;

      while (assigned < count) {
        final radius = (280.0 + (ringIndex * 210.0)) * scaleRatio;
        // Estimate how many nodes fit comfortably on this circumference
        final circumference = 2 * math.pi * radius;
        final capacity = math.max(
          6,
          (circumference / (240.0 * scaleRatio)).floor(),
        );
        final inThisRing = math.min(capacity, count - assigned);

        for (int i = 0; i < inThisRing; i++) {
          final angle =
              (2 * math.pi * i / inThisRing) + (ringIndex * (math.pi / 5));
          final x = _centerCoord + radius * math.cos(angle);
          final y = _centerCoord + radius * math.sin(angle);
          _positions[verses[assigned + i].ayahKey] = Offset(x, y);
        }

        assigned += inThisRing;
        ringIndex++;
      }
    }
  }

  void _assignMissingVersePositions(List<AyahLinkVerse> verses) {
    for (int i = 0; i < verses.length; i++) {
      final key = verses[i].ayahKey;
      if (!_positions.containsKey(key)) {
        final angle = (2 * math.pi * i / math.max(1, verses.length));
        final radius = 340.0;
        _positions[key] = Offset(
          _centerCoord + radius * math.cos(angle),
          _centerCoord + radius * math.sin(angle),
        );
      }
    }
  }

  void _initOrRestoreViewport() {
    if (!mounted) return;
    final size = MediaQuery.of(context).size;

    if (widget.link.panX != null &&
        widget.link.panY != null &&
        widget.link.zoomScale != null) {
      final matrix = Matrix4.identity()
        ..translate2D(widget.link.panX!, widget.link.panY!)
        ..scale2D(widget.link.zoomScale!);
      _transformController.value = matrix;
    } else {
      // Center on (_centerCoord, _centerCoord)
      _centerViewport(size, animate: false);
    }
  }

  void _centerViewport(Size viewportSize, {bool animate = true}) {
    const scale = 0.95;
    final targetX = (viewportSize.width / 2) - (_centerCoord * scale);
    final targetY = (viewportSize.height / 2) - (_centerCoord * scale);

    final targetMatrix = Matrix4.identity()
      ..translate2D(targetX, targetY)
      ..scale2D(scale);

    if (animate) {
      _animateToMatrix(targetMatrix);
    } else {
      _transformController.value = targetMatrix;
    }
  }

  void _animateToMatrix(Matrix4 target) {
    _matrixAnimation?.removeListener(_onMatrixAnim);
    _animController.reset();

    _matrixAnimation =
        Matrix4Tween(begin: _transformController.value, end: target).animate(
          CurvedAnimation(
            parent: _animController,
            curve: Curves.easeInOutCubic,
          ),
        );

    _matrixAnimation!.addListener(_onMatrixAnim);
    _animController.forward();
  }

  void _onMatrixAnim() {
    if (_matrixAnimation != null) {
      _transformController.value = _matrixAnimation!.value;
    }
  }

  /// Public action called to trigger automatic re-layout
  Future<void> autoLayout() async {
    setState(() {
      _computeAutoLayoutPositions(widget.link.verses);
    });

    final map = <String, LinkNodePosition>{};
    for (final entry in _positions.entries) {
      map[entry.key] = LinkNodePosition(dx: entry.value.dx, dy: entry.value.dy);
    }
    await _repo.updatePositions(widget.link.id, map, false);
    if (mounted) {
      _centerViewport(MediaQuery.of(context).size);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تمت إعادة الترتيب تلقائيًا'),
          backgroundColor: AppColors.olive,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Smoothly zooms and centers on a selected Ayah node, then opens inspector
  void _focusAyahNode(AyahLinkVerse verse) {
    final pos = _positions[verse.ayahKey];
    if (pos == null) return;

    final viewportSize = MediaQuery.of(context).size;
    const focusScale = 1.15;

    // We offset the target center slightly above viewport center so the bottom sheet has room
    final targetCenterY = viewportSize.height * 0.42;

    final targetX = (viewportSize.width / 2) - (pos.dx * focusScale);
    final targetY = targetCenterY - (pos.dy * focusScale);

    final targetMatrix = Matrix4.identity()
      ..translate2D(targetX, targetY)
      ..scale2D(focusScale);

    _animateToMatrix(targetMatrix);

    // Open verse inspector sheet
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        _showVerseInspectorSheet(verse);
      }
    });
  }

  void _showVerseInspectorSheet(AyahLinkVerse verse) {
    final surah = QuranRepository.instance.getSurah(verse.surahNumber);
    final ayah = QuranRepository.instance.getAyah(
      verse.surahNumber,
      verse.ayahNumber,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetCtx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.comsilkLight,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              border: Border.all(
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.lightBorder,
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'سورة ${surah.name} · الآية ${ArabicSearchNormalizer.toArabicDigits(verse.ayahNumber)}',
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.olive,
                        ),
                      ),
                      Text(
                        'ص ${ArabicSearchNormalizer.toArabicDigits(verse.page)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.olive,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Full Verse Text
                  if (ayah != null)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkBackground
                            : AppColors.comsilk,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '﴿ ${ayah.text} ﴾',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'AmiriQuran',
                          fontSize: 18,
                          height: 1.8,
                          color: isDark
                              ? AppColors.nightQuranText
                              : AppColors.dayQuranText,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),

                  // Reflection note (if any, from link, note or tadbeer)
                  () {
                    final effectiveNote = verse.getEffectiveNote();
                    if (effectiveNote != null && effectiveNote.isNotEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.olive.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.olive.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.sticky_note_2_outlined,
                                    size: 16,
                                    color: AppColors.olive,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'ملاحظة التدبر:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.olive,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                effectiveNote,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                  color: isDark
                                      ? AppColors.nightSubtitle
                                      : AppColors.daySubtitle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }(),

                  // Action Buttons Row
                  Row(
                    children: [
                      // Open in Mushaf
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(bottomSheetCtx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => QuranScreen(
                                  initialPage: verse.page,
                                  targetSurahNumber: verse.surahNumber,
                                  targetAyahNumber: verse.ayahNumber,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.olive,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.menu_book_rounded, size: 18),
                          label: const Text(
                            'فتح في المصحف',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Edit note button
                      IconButton.filledTonal(
                        icon: const Icon(Icons.edit_note_rounded, size: 20),
                        tooltip: 'ملاحظة التدبر',
                        onPressed: () {
                          Navigator.pop(bottomSheetCtx);
                          _showEditNoteDialog(verse);
                        },
                      ),
                      const SizedBox(width: 6),

                      // Remove verse from link button
                      IconButton.filledTonal(
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: Colors.redAccent,
                        ),
                        tooltip: 'إزالة من الرابط',
                        onPressed: () {
                          Navigator.pop(bottomSheetCtx);
                          _confirmRemoveVerse(verse);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showEditNoteDialog(AyahLinkVerse verse) async {
    final controller = TextEditingController(text: verse.note ?? '');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final updatedNote = await showDialog<String>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.comsilkLight,
        title: const Text('ملاحظة التدبر على الآية'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'اكتب تدبرك أو الرابط الذي لاحظته...',
            filled: true,
            fillColor: isDark ? AppColors.darkSurface : AppColors.comsilk,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.olive,
              foregroundColor: Colors.white,
            ),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (updatedNote != null) {
      await _repo.updateVerseNote(
        widget.link.id,
        verse.surahNumber,
        verse.ayahNumber,
        updatedNote.isEmpty ? null : updatedNote,
      );
    }
  }

  Future<void> _confirmRemoveVerse(AyahLinkVerse verse) async {
    final surah = QuranRepository.instance.getSurah(verse.surahNumber);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('إزالة الآية من الرابط'),
        content: Text(
          'هل تريد إزالة الآية ${verse.ayahNumber} من سورة ${surah.name} من هذا الرابط؟',
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
            child: const Text('إزالة'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _repo.removeVerseFromLink(
        widget.link.id,
        verse.surahNumber,
        verse.ayahNumber,
      );
    }
  }

  // Directional Pan & Zoom Actions
  void _panBy(double dx, double dy) {
    final current = _transformController.value;
    final updated = Matrix4.copy(current)..translate2D(dx, dy);
    _animateToMatrix(updated);
  }

  void _zoomBy(double factor) {
    final current = _transformController.value;
    final size = MediaQuery.of(context).size;
    final focalPoint = Offset(size.width / 2, size.height / 2);

    final updated = Matrix4.copy(current)
      ..translate2D(focalPoint.dx, focalPoint.dy)
      ..scale2D(factor)
      ..translate2D(-focalPoint.dx, -focalPoint.dy);

    _animateToMatrix(updated);
  }

  void _persistManualPositions() {
    final map = <String, LinkNodePosition>{};
    for (final entry in _positions.entries) {
      map[entry.key] = LinkNodePosition(dx: entry.value.dx, dy: entry.value.dy);
    }
    _repo.updatePositions(widget.link.id, map, true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final verses = widget.link.verses;
    final fontSize = UserDataStore.instance.settings.ayahLinkFontSize;
    final nodeWidth = (fontSize * 11.5).clamp(195.0, 280.0);

    return Stack(
      children: [
        // Interactive Canvas
        InteractiveViewer(
          transformationController: _transformController,
          constrained: false,
          minScale: 0.25,
          maxScale: 2.5,
          boundaryMargin: const EdgeInsets.all(500),
          onInteractionEnd: (details) {
            // Save pan / zoom view state
            final translation = _transformController.value.getTranslation();
            final scale = _transformController.value.getMaxScaleOnAxis();
            _repo.updateViewState(
              widget.link.id,
              panX: translation.x,
              panY: translation.y,
              zoomScale: scale,
            );
          },
          child: SizedBox(
            width: _canvasSize,
            height: _canvasSize,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Custom Connections Painter
                CustomPaint(
                  size: const Size(_canvasSize, _canvasSize),
                  painter: _NetworkConnectionsPainter(
                    center: const Offset(_centerCoord, _centerCoord),
                    positions: _positions,
                    isDark: isDark,
                  ),
                ),

                // Center Theme Node
                Positioned(
                  left: _centerCoord - 100,
                  top: _centerCoord - 50,
                  child: _CenterThemeNode(
                    title: widget.link.title,
                    description: widget.link.description,
                    versesCount: verses.length,
                    isDark: isDark,
                  ),
                ),

                // Verse Nodes
                for (final verse in verses)
                  if (_positions.containsKey(verse.ayahKey))
                    Positioned(
                      left: _positions[verse.ayahKey]!.dx - (nodeWidth / 2),
                      top: _positions[verse.ayahKey]!.dy - 60,
                      child: _VerseCanvasNode(
                        verse: verse,
                        isDark: isDark,
                        onTap: () => _focusAyahNode(verse),
                        onPanUpdate: (delta) {
                          setState(() {
                            final current = _positions[verse.ayahKey]!;
                            _positions[verse.ayahKey] = current + delta;
                          });
                        },
                        onPanEnd: () => _persistManualPositions(),
                      ),
                    ),
              ],
            ),
          ),
        ),

        // Empty state overlay if no verses yet
        if (verses.isEmpty)
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.comsilkLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? AppColors.darkSurfaceVariant
                      : AppColors.lightBorder,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.hub_outlined,
                    size: 48,
                    color: AppColors.olive,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'لم تتم إضافة أي آيات لهذا الرابط بعد',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'أضف الآيات التي لاحظت ارتباطها لبناء خريطتك التدبرية',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.nightSubtitle
                          : AppColors.daySubtitle,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: widget.onAddVerse,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.olive,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('إضافة آية الآن'),
                  ),
                ],
              ),
            ),
          ),

        // Floating D-pad Navigation Controls (bottom-left / start)
        Positioned(
          left: 16,
          bottom: 24,
          child: _FloatingNavigationPad(
            isDark: isDark,
            onPanUp: () => _panBy(0, 120),
            onPanDown: () => _panBy(0, -120),
            onPanLeft: () => _panBy(120, 0),
            onPanRight: () => _panBy(-120, 0),
            onCenter: () => _centerViewport(MediaQuery.of(context).size),
            onZoomIn: () => _zoomBy(1.2),
            onZoomOut: () => _zoomBy(0.8),
          ),
        ),
      ],
    );
  }
}

/// Custom painter for connecting center node to all member verse nodes.
class _NetworkConnectionsPainter extends CustomPainter {
  final Offset center;
  final Map<String, Offset> positions;
  final bool isDark;

  const _NetworkConnectionsPainter({
    required this.center,
    required this.positions,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = (isDark ? AppColors.oliveSoft : AppColors.olive).withValues(
        alpha: 0.45,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final dotPaint = Paint()
      ..color = (isDark ? AppColors.oliveSoft : AppColors.olive).withValues(
        alpha: 0.8,
      )
      ..style = PaintingStyle.fill;

    for (final pos in positions.values) {
      // Subtle smooth curve toward center
      final path = Path();
      path.moveTo(center.dx, center.dy);

      final controlX = (center.dx + pos.dx) / 2;
      final controlY = (center.dy + pos.dy) / 2;

      path.quadraticBezierTo(controlX, controlY, pos.dx, pos.dy);
      canvas.drawPath(path, linePaint);

      // Decorative mini junction dot
      canvas.drawCircle(pos, 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _NetworkConnectionsPainter oldDelegate) {
    return oldDelegate.positions != positions || oldDelegate.isDark != isDark;
  }
}

/// Central Node representing the overall Ayah Link theme/title.
class _CenterThemeNode extends StatelessWidget {
  final String title;
  final String? description;
  final int versesCount;
  final bool isDark;

  const _CenterThemeNode({
    required this.title,
    this.description,
    required this.versesCount,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.comsilk,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.olive, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.olive.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.hub_rounded, color: AppColors.olive, size: 20),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.comsilk : AppColors.oliveDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.olive.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$versesCount آيات مرتبطة',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.olive,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Interactive Verse Node on the Canvas with draggable gestures.
class _VerseCanvasNode extends StatelessWidget {
  final AyahLinkVerse verse;
  final bool isDark;
  final VoidCallback onTap;
  final ValueChanged<Offset> onPanUpdate;
  final VoidCallback onPanEnd;

  const _VerseCanvasNode({
    required this.verse,
    required this.isDark,
    required this.onTap,
    required this.onPanUpdate,
    required this.onPanEnd,
  });

  @override
  Widget build(BuildContext context) {
    final surah = QuranRepository.instance.getSurah(verse.surahNumber);
    final ayah = QuranRepository.instance.getAyah(
      verse.surahNumber,
      verse.ayahNumber,
    );
    final effectiveNote = verse.getEffectiveNote();
    final hasNote = effectiveNote != null && effectiveNote.isNotEmpty;
    final fontSize = UserDataStore.instance.settings.ayahLinkFontSize;
    final nodeWidth = (fontSize * 11.5).clamp(195.0, 280.0);

    return GestureDetector(
      onTap: onTap,
      onPanUpdate: (details) => onPanUpdate(details.delta),
      onPanEnd: (_) => onPanEnd(),
      child: Container(
        width: nodeWidth,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.comsilkLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasNote
                ? AppColors.olive
                : (isDark
                      ? AppColors.darkSurfaceVariant
                      : AppColors.lightBorder),
            width: hasNote ? 1.5 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Node Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${surah.name} · ${ArabicSearchNormalizer.toArabicDigits(verse.ayahNumber)}',
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.olive,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hasNote)
                  const Icon(
                    Icons.sticky_note_2_outlined,
                    size: 14,
                    color: AppColors.olive,
                  ),
              ],
            ),
            const SizedBox(height: 6),

            // Verse snippet
            if (ayah != null)
              Text(
                '﴿ ${ayah.text} ﴾',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'AmiriQuran',
                  fontSize: fontSize * 0.78,
                  height: 1.6,
                  color: isDark
                      ? AppColors.nightQuranText
                      : AppColors.dayQuranText,
                ),
              ),

            // Note snippet under verse (if present, compact otherwise)
            if (hasNote) ...[
              const SizedBox(height: 8),
              Divider(
                height: 1,
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : const Color(0xFFDDD7C8),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.edit_note,
                    size: 13,
                    color: isDark ? AppColors.oliveSoft : AppColors.olive,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'ملاحظتي',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.oliveSoft : AppColors.olive,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                effectiveNote,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.4,
                  color: isDark
                      ? AppColors.nightSubtitle
                      : AppColors.daySubtitle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Floating Navigation D-Pad for Pan and Zoom.
class _FloatingNavigationPad extends StatelessWidget {
  final bool isDark;
  final VoidCallback onPanUp;
  final VoidCallback onPanDown;
  final VoidCallback onPanLeft;
  final VoidCallback onPanRight;
  final VoidCallback onCenter;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const _FloatingNavigationPad({
    required this.isDark,
    required this.onPanUp,
    required this.onPanDown,
    required this.onPanLeft,
    required this.onPanRight,
    required this.onCenter,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark
        ? AppColors.darkSurface.withValues(alpha: 0.92)
        : AppColors.comsilkLight.withValues(alpha: 0.92);
    final borderColor = isDark
        ? AppColors.darkSurfaceVariant
        : AppColors.lightBorder;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Zoom In / Out row
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PadButton(icon: Icons.add, tooltip: 'تكبير', onTap: onZoomIn),
              const SizedBox(width: 4),
              _PadButton(
                icon: Icons.remove,
                tooltip: 'تصغير',
                onTap: onZoomOut,
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Divider(height: 1),
          const SizedBox(height: 6),

          // D-Pad Arrows with Center
          _PadButton(
            icon: Icons.keyboard_arrow_up,
            tooltip: 'أعلى',
            onTap: onPanUp,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PadButton(
                icon: Icons.keyboard_arrow_right,
                tooltip: 'يمين',
                onTap: onPanRight,
              ),
              _PadButton(
                icon: Icons.filter_center_focus,
                tooltip: 'إعادة التمركز',
                iconColor: AppColors.olive,
                onTap: onCenter,
              ),
              _PadButton(
                icon: Icons.keyboard_arrow_left,
                tooltip: 'يسار',
                onTap: onPanLeft,
              ),
            ],
          ),
          _PadButton(
            icon: Icons.keyboard_arrow_down,
            tooltip: 'أسفل',
            onTap: onPanDown,
          ),
        ],
      ),
    );
  }
}

class _PadButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? iconColor;

  const _PadButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        icon: Icon(icon, size: 18, color: iconColor),
        padding: EdgeInsets.zero,
        tooltip: tooltip,
        onPressed: onTap,
      ),
    );
  }
}

extension on Matrix4 {
  void translate2D(double x, double y) {
    translateByDouble(x, y, 0.0, 1.0);
  }

  void scale2D(double s) {
    scaleByDouble(s, s, 1.0, 1.0);
  }
}
