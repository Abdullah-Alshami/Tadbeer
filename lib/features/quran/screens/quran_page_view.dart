import 'package:flutter/material.dart';

import '../data/quran_models.dart';
import '../data/quran_repository.dart';
import '../renderers/mushaf_canvas.dart';

/// Renders a single authoritative Medina Mushaf page (1..604) using [MushafCanvas]
/// based on the verified 15-line layout architecture from QUL / KFGQPC Hafs.
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
    this.fontSize = 18.0,
    this.selectedAyah,
    this.onAyahTap,
    this.onAyahLongPress,
  }) : assert(
         page != null || pageNumber != null,
         'Either page or pageNumber must be provided',
       );

  @override
  Widget build(BuildContext context) {
    final pNum = page?.pageNumber ?? pageNumber!;
    final repo = QuranRepository.instance;
    final pageLayout = repo.getMushafPage(pNum);

    return MushafCanvas(
      pageLayout: pageLayout,
      selectedAyah: selectedAyah,
      onAyahTap: onAyahTap,
      onAyahLongPress: onAyahLongPress,
    );
  }
}

/// Backward compatibility alias for QuranPageView
typedef QuranPageWidget = QuranPageView;
