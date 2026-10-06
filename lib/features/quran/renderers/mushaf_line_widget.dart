import 'package:flutter/material.dart';

import '../data/mushaf_layout_models.dart';
import '../data/quran_models.dart';
import '../data/quran_repository.dart';
import '../widgets/surah_header_banner.dart';
import 'mushaf_word_widget.dart';

/// Renders a single line of the Madinah Mushaf (Header, Bismillah, or Text line).
///
/// For text lines:
/// - Words are strictly laid out from the authentic [line.words] sequence.
/// - When [line.isCentered] is true: centered horizontally.
/// - When [line.isCentered] is false: fully justified edge-to-edge at the word level.
/// - Layout uses [CustomMultiChildLayout] to guarantee precise word positioning
///   without Flex overflow or artificial text wrapping.
class MushafLineWidget extends StatelessWidget {
  final MushafLine line;
  final Ayah? selectedAyah;
  final ValueChanged<Ayah>? onAyahTap;
  final ValueChanged<Ayah>? onAyahLongPress;

  const MushafLineWidget({
    super.key,
    required this.line,
    this.selectedAyah,
    this.onAyahTap,
    this.onAyahLongPress,
  });

  @override
  Widget build(BuildContext context) {
    switch (line.type) {
      case MushafLineType.header:
        final surahNumber = line.surahNumber ?? 1;
        final surah = QuranRepository.instance.getSurah(surahNumber);
        return Center(child: SurahHeaderBanner(surah: surah));

      case MushafLineType.bismillah:
        return const Center(child: BismillahBanner());

      case MushafLineType.text:
        return _buildTextLine(context);
    }
  }

  Widget _buildTextLine(BuildContext context) {
    final words = line.words;
    if (words.isEmpty) return const SizedBox.shrink();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: CustomMultiChildLayout(
        delegate: _MushafLineLayoutDelegate(
          wordCount: words.length,
          isCentered: line.isCentered,
        ),
        children: [
          for (int i = 0; i < words.length; i++)
            LayoutId(
              id: i,
              child: MushafWordWidget(
                word: words[i],
                selectedAyah: selectedAyah,
                onAyahTap: onAyahTap,
                onAyahLongPress: onAyahLongPress,
              ),
            ),
        ],
      ),
    );
  }
}

class _MushafLineLayoutDelegate extends MultiChildLayoutDelegate {
  final int wordCount;
  final bool isCentered;

  _MushafLineLayoutDelegate({
    required this.wordCount,
    required this.isCentered,
  });

  @override
  Size getSize(BoxConstraints constraints) {
    const defaultLineHeight = 30.0;
    final height = constraints.hasBoundedHeight
        ? constraints.maxHeight
        : defaultLineHeight;
    return Size(constraints.maxWidth, height);
  }

  @override
  void performLayout(Size size) {
    final wordSizes = <Size>[];
    double totalWordsWidth = 0.0;

    for (int i = 0; i < wordCount; i++) {
      if (hasChild(i)) {
        final childSize = layoutChild(i, BoxConstraints.loose(size));
        wordSizes.add(childSize);
        totalWordsWidth += childSize.width;
      } else {
        wordSizes.add(Size.zero);
      }
    }

    if (wordCount == 0) return;

    // Centered line layout
    if (isCentered || wordCount == 1) {
      const defaultSpacing = 5.0;
      final totalClusterWidth =
          totalWordsWidth +
          (wordCount > 1 ? (wordCount - 1) * defaultSpacing : 0.0);

      // In RTL, start layout from the right:
      // cluster right edge = (size.width + totalClusterWidth) / 2
      double currentRight = (size.width + totalClusterWidth) / 2;
      if (totalClusterWidth > size.width) {
        currentRight = size.width;
      }

      for (int i = 0; i < wordCount; i++) {
        if (!hasChild(i)) continue;
        final wSize = wordSizes[i];
        final x = currentRight - wSize.width;
        final y = (size.height - wSize.height) / 2;
        positionChild(i, Offset(x, y.clamp(0.0, size.height)));
        currentRight -= (wSize.width + defaultSpacing);
      }
      return;
    }

    // Fully Justified edge-to-edge layout at word level
    final availableGap = size.width - totalWordsWidth;
    final spacing = availableGap > 0 ? (availableGap / (wordCount - 1)) : 0.0;

    // In RTL, word 0 is anchored at the far right (x = size.width - word[0].width)
    // word N-1 is anchored at the far left (x = 0)
    double currentRight = size.width;
    for (int i = 0; i < wordCount; i++) {
      if (!hasChild(i)) continue;
      final wSize = wordSizes[i];
      double x = currentRight - wSize.width;
      if (i == wordCount - 1 && spacing > 0) {
        x = 0.0; // Strictly anchor final word to left boundary
      }
      final y = (size.height - wSize.height) / 2;
      positionChild(i, Offset(x, y.clamp(0.0, size.height)));
      currentRight -= (wSize.width + spacing);
    }
  }

  @override
  bool shouldRelayout(covariant _MushafLineLayoutDelegate oldDelegate) {
    return oldDelegate.wordCount != wordCount ||
        oldDelegate.isCentered != isCentered;
  }
}
