import 'package:uuid/uuid.dart';

import '../../core/storage/user_data_store.dart';
import '../quran/data/quran_models.dart';
import 'highlight_model.dart';

/// مستودع إدارة تظليلات الآيات في التطبيق.
///
/// يوفر واجهة لإضافة وتحديث وحذف تظليل الآية مع دعم التفاعل اللحظي عبر [UserDataStore].
class HighlightRepository {
  final UserDataStore _store;

  /// ينشئ مستودع التظليلات مع إمكانية تمرير مخزن بيانات مخصص.
  HighlightRepository([UserDataStore? store])
    : _store = store ?? UserDataStore.instance;

  /// قائمة بجميع التظليلات المحفوظة للمستخدم.
  List<HighlightItem> get allHighlights => _store.highlights;

  /// يسترجع تظليل الآية المحددة برقم السورة ورقم الآية إن وجد.
  HighlightItem? getHighlight(int surahNumber, int ayahNumber) {
    return _store.findHighlight(surahNumber, ayahNumber);
  }

  /// تعيين أو تحديث لون التظليل للآية المحددة.
  Future<void> setHighlight(Ayah ayah, int colorIndex) async {
    final existing = getHighlight(ayah.surahNumber, ayah.ayahNumber);
    final item = HighlightItem(
      id: existing?.id ?? const Uuid().v4(),
      ayahId: ayah.id,
      surahNumber: ayah.surahNumber,
      ayahNumber: ayah.ayahNumber,
      page: ayah.page,
      colorIndex: colorIndex,
      createdAt: DateTime.now(),
    );
    await _store.putHighlight(item);
  }

  /// إزالة التظليل عن الآية.
  Future<void> removeHighlight(int surahNumber, int ayahNumber) async {
    await _store.removeHighlight(surahNumber, ayahNumber);
  }
}
