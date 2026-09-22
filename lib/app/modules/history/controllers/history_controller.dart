import 'package:get/get.dart';

import '../../../data/models/watch_history_model.dart';
import '../../../data/repositories/history_repository.dart';
import '../../../data/services/storage_service.dart';
import '../../player/bindings/player_binding.dart';
import '../../player/views/player_view.dart';

class HistoryController extends GetxController {
  final HistoryRepository repository;

  HistoryController(this.repository);

  // ============================================================
  // HISTORY
  // ============================================================

  final histories = <WatchHistoryModel>[].obs;
  final isLoading = false.obs;

  // ============================================================
  // TAB
  // ============================================================
  final selectedTab = 0.obs;

  void changeTab(int index) {
    selectedTab.value = index;
  }

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final token = await StorageService.readToken();

    if (token == null || token.isEmpty) {
      histories.clear();
      isLoading.value = false;
      return;
    }

    try {
      isLoading.value = true;

      final data = await repository.continueWatching();

      histories.assignAll(data);
    } catch (_) {
      histories.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshHistory() async {
    await loadHistory();
  }

  // ============================================================
  // PLAY
  // ============================================================

  Future<void> playHistory(WatchHistoryModel item) async {
    Get.to(
      () => const PlayerView(),
      binding: PlayerBinding(),
      arguments: {
        "episode": item,
        "title": item.movieTitle,
        "resumeSeconds": item.watchedSeconds,
      },
    );

    // Setelah kembali dari player,
    // refresh progress history.
    await loadHistory();
  }
}
