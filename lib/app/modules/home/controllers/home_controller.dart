import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/category_model.dart';
import '../../../data/models/home_model.dart';
import '../../../data/models/movie_model.dart';
import '../../../data/repositories/home_repository.dart';

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final HomeRepository repository;

  HomeController(this.repository);

  // ==========================================================
  // HOME DATA
  // ==========================================================

  final home = Rxn<HomeModel>();

  final loading = true.obs;
  final refreshing = false.obs;

  // ==========================================================
  // TAB
  // ==========================================================

  TabController? tabController;

  final selectedCategory = 0.obs;

  int _lastTabIndex = -1;

  List<CategoryModel> get categories {
    return home.value?.genres ?? [];
  }

  // ==========================================================
  // CATEGORY CACHE
  //
  // key   = category.id
  // value = daftar movie
  // ==========================================================

  final Map<int, List<MovieModel>> categoryCache = {};

  // Category yang sedang request
  final Set<int> loadingCategories = {};

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void onInit() {
    super.onInit();

    loadHome();
  }

  // ==========================================================
  // LOAD HOME
  // ==========================================================

  Future<void> loadHome({bool isRefresh = false}) async {
    if (isRefresh) {
      refreshing.value = true;
    } else {
      loading.value = true;
    }

    try {
      final data = await repository.home();

      home.value = data;

      // ========================================================
      // TAB CONTROLLER
      // ========================================================

      final currentIndex = selectedCategory.value;

      if (tabController == null ||
          tabController!.length != data.genres.length) {
        _setupTabController(
          data.genres.length,
          initialIndex: currentIndex,
        );
      }

      // ========================================================
      // VALIDATE INDEX
      // ========================================================

      final safeIndex = data.genres.isEmpty
          ? 0
          : currentIndex.clamp(0, data.genres.length - 1);

      selectedCategory.value = safeIndex;
      _lastTabIndex = safeIndex;

      // ========================================================
      // REFRESH
      // ========================================================

      if (isRefresh) {
        categoryCache.clear();
      }

      // ========================================================
      // PRELOAD CATEGORY AKTIF + BERIKUTNYA
      // ========================================================

      preloadAround(safeIndex);
    } catch (e) {
      debugPrint('[HOME] LOAD ERROR: $e');
    } finally {
      if (isRefresh) {
        refreshing.value = false;
      } else {
        loading.value = false;
      }
    }
  }

  // ==========================================================
  // SETUP TAB CONTROLLER
  // ==========================================================

  void _setupTabController(
    int length, {
    int initialIndex = 0,
  }) {
    tabController?.removeListener(_onTabChanged);
    tabController?.dispose();

    if (length <= 0) {
      tabController = null;
      return;
    }

    final safeIndex = initialIndex.clamp(0, length - 1);

    _lastTabIndex = safeIndex;

    tabController = TabController(
      length: length,
      vsync: this,
      initialIndex: safeIndex,
    );

    tabController!.addListener(_onTabChanged);
  }

  // ==========================================================
  // TAB CHANGED
  // ==========================================================

  void _onTabChanged() {
    final controller = tabController;

    if (controller == null) {
      return;
    }

    final index = controller.index;

    if (index == _lastTabIndex) {
      return;
    }

    _lastTabIndex = index;

    onCategoryChanged(index);
  }

  // ==========================================================
  // CATEGORY CHANGED
  // ==========================================================

  void onCategoryChanged(int index) {
    if (index < 0 || index >= categories.length) {
      return;
    }

    selectedCategory.value = index;

    // ========================================================
    // LANGSUNG PRELOAD CATEGORY AKTIF
    // ========================================================

    loadCategoryIfNeeded(index);

    // ========================================================
    // PRELOAD 2 CATEGORY BERIKUTNYA
    // ========================================================

    preloadAround(index);
  }

  // ==========================================================
  // PRELOAD AROUND
  // ==========================================================

  void preloadAround(int index) {
    // Category aktif
    loadCategoryIfNeeded(index);

    // Berikutnya
    loadCategoryIfNeeded(index + 1);

    // Dua langkah berikutnya
    loadCategoryIfNeeded(index + 2);
  }

  // ==========================================================
  // LOAD CATEGORY
  // ==========================================================

  Future<void> loadCategoryIfNeeded(int index) async {
    // ========================================================
    // INDEX 0 = ALL
    //
    // Data sudah berasal dari home.latest
    // ========================================================

    if (index <= 0) {
      return;
    }

    if (index >= categories.length) {
      return;
    }

    final categoryId = categories[index].id;

    // ========================================================
    // SUDAH CACHE
    // ========================================================

    if (categoryCache.containsKey(categoryId)) {
      return;
    }

    // ========================================================
    // SEDANG REQUEST
    // ========================================================

    if (loadingCategories.contains(categoryId)) {
      return;
    }

    loadingCategories.add(categoryId);

    try {
      final movies = await repository.category(categoryId);

      categoryCache[categoryId] = movies;

      debugPrint(
        '[HOME] CATEGORY READY '
        'index=$index '
        'category=$categoryId '
        'movies=${movies.length}',
      );
    } catch (e) {
      debugPrint(
        '[HOME] CATEGORY ERROR '
        'index=$index '
        'category=$categoryId '
        'error=$e',
      );
    } finally {
      loadingCategories.remove(categoryId);
    }
  }

  // ==========================================================
  // GET MOVIES
  // ==========================================================

  List<MovieModel> getMoviesForCategory(int index) {
    // ========================================================
    // ALL
    // ========================================================

    if (index == 0) {
      return home.value?.latest ?? [];
    }

    // ========================================================
    // INVALID
    // ========================================================

    if (index < 0 || index >= categories.length) {
      return [];
    }

    // ========================================================
    // CATEGORY
    // ========================================================

    final categoryId = categories[index].id;

    return categoryCache[categoryId] ?? [];
  }

  // ==========================================================
  // CLOSE
  // ==========================================================

  @override
  void onClose() {
    tabController?.removeListener(_onTabChanged);
    tabController?.dispose();

    super.onClose();
  }
}