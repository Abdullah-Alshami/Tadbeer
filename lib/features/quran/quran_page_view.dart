import 'package:flutter/material.dart';

import '../../data/quran/quran_models.dart';
import '../../data/quran/quran_repository.dart';
import 'renderers/madinah_page_renderer.dart';

/// Renders a single authoritative Medina Mushaf page (1..604) using [MadinahPageRenderer].
class QuranPageView extends StatelessWidget {
  final int pageNumber;
  final Ayah? selectedAyah;
  final ValueChanged<Ayah>? onAyahTap;
  final ValueChanged<Ayah>? onAyahLongPress;

  const QuranPageView({
    super.key,
    required this.pageNumber,
    this.selectedAyah,
    this.onAyahTap,
    this.onAyahLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final repo = QuranRepository.instance;
    final pageLayout = repo.getMushafPage(pageNumber);

    return MadinahPageRenderer(
      pageLayout: pageLayout,
      selectedAyah: selectedAyah,
      onAyahTap: onAyahTap,
      onAyahLongPress: onAyahLongPress,
    );
  }
}
