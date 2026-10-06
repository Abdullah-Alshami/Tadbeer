import 'package:flutter/material.dart';

import '../../data/quran/quran_models.dart';
import '../../data/quran/quran_repository.dart';
import 'renderers/madinah_page_renderer.dart';

/// Renders a single authoritative Medina Mushaf page (1..604) using [MadinahPageRenderer]
/// based on the verified KFGQPC V4 (1441H) 15-line layout from QUL.
class QuranPageView extends StatelessWidget {
  final QuranPage? page;
  final int? pageNumber;
  final double fontSize;
  final Ayah? selectedAyah;
  final ValueChanged<Ayah>? onAyahTap;
  final ValueChanged<Ayah>? onAyahLongPress;

  const QuranPageView({
    super.key,
    this.page,
    this.pageNumber,
    this.fontSize = 20.0,
    this.selectedAyah,
    this.onAyahTap,
    this.onAyahLongPress,
  }) : assert(page != null || pageNumber != null, 'Either page or pageNumber must be provided');

  @override
  Widget build(BuildContext context) {
    final pNum = page?.pageNumber ?? pageNumber!;
    final repo = QuranRepository.instance;
    final pageLayout = repo.getMushafPage(pNum);

    return MadinahPageRenderer(
      pageLayout: pageLayout,
      selectedAyah: selectedAyah,
      onAyahTap: onAyahTap,
      onAyahLongPress: onAyahLongPress,
    );
  }
}

/// Backward compatibility alias for QuranPageView
typedef QuranPageWidget = QuranPageView;
