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

  final allMovies = <MovieModel>[].obs;
  final loadingAllMovies = false.obs;
  final loadingMoreAllMovies = false.obs;
  final allMoviesHasMore = true.obs;

  int allMoviesPage = 1;
  static const int allMoviesPageSize = 20;

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
      final tabCount = data.genres.length + 1;

      if (tabController == null || tabController!.length != tabCount) {
        _setupTabController(tabCount, initialIndex: currentIndex);
      }

      // ========================================================
      // VALIDATE INDEX
      // ========================================================
      final safeIndex = currentIndex.clamp(0, tabCount - 1);

      selectedCategory.value = safeIndex;
      _lastTabIndex = safeIndex;

      // ========================================================
      // REFRESH CACHE
      // ========================================================
      if (isRefresh) {
        categoryCache.clear();
      }

      // ========================================================
      // LOAD ALL MOVIES
      // ========================================================
      await loadAllMovies(forceRefresh: isRefresh);

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
  // LOAD ALL MOVIES
  // ==========================================================

  int _allMoviesRequestId = 0;

  Future<void> loadAllMovies({bool forceRefresh = false}) async {
    if (loadingAllMovies.value && !forceRefresh) return;

    if (!forceRefresh && (allMovies.isNotEmpty || !allMoviesHasMore.value)) {
      return;
    }

    final requestId = ++_allMoviesRequestId;

    loadingAllMovies.value = true;

    if (forceRefresh) {
      allMovies.clear();
      allMoviesPage = 1;
      allMoviesHasMore.value = true;
    }

    try {
      final result = await repository.allMovies(
        page: 1,
        limit: allMoviesPageSize,
      );

      // Abaikan hasil request lama jika sudah ada refresh baru.
      if (requestId != _allMoviesRequestId) return;

      final movies = result['items'] as List<MovieModel>;

      allMovies.assignAll(movies);
      allMoviesPage = result['page'] as int;
      allMoviesHasMore.value = result['has_more'] as bool;

      debugPrint(
        '[HOME] ALL MOVIES PAGE=$allMoviesPage '
        'COUNT=${movies.length} '
        'HAS_MORE=${allMoviesHasMore.value}',
      );
    } catch (e) {
      if (requestId == _allMoviesRequestId) {
        debugPrint('[HOME] ALL MOVIES ERROR: $e');
      }
    } finally {
      if (requestId == _allMoviesRequestId) {
        loadingAllMovies.value = false;
      }
    }
  }

  // ==========================================================
  // LOAD MORE ALL MOVIES
  // ==========================================================
  Future<void> loadMoreAllMovies() async {
    if (loadingAllMovies.value ||
        loadingMoreAllMovies.value ||
        !allMoviesHasMore.value) {
      return;
    }

    loadingMoreAllMovies.value = true;

    try {
      final nextPage = allMoviesPage + 1;

      final result = await repository.allMovies(
        page: nextPage,
        limit: allMoviesPageSize,
      );

      final movies = result['items'] as List<MovieModel>;

      // Hindari memasukkan film yang sama dua kali.
      final existingIds = allMovies.map((movie) => movie.id).toSet();
      final newMovies =
          movies.where((movie) => !existingIds.contains(movie.id)).toList();

      allMovies.addAll(newMovies);
      allMoviesPage = result['page'] as int;
      allMoviesHasMore.value = result['has_more'] as bool;

      debugPrint(
        '[HOME] ALL MOVIES PAGE=$allMoviesPage '
        'ADDED=${newMovies.length} '
        'HAS_MORE=${allMoviesHasMore.value}',
      );
    } catch (e) {
      debugPrint('[HOME] LOAD MORE ERROR: $e');
    } finally {
      loadingMoreAllMovies.value = false;
    }
  }

  // ==========================================================
  // SETUP TAB CONTROLLER
  // ==========================================================

  void _setupTabController(int length, {int initialIndex = 0}) {
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
    if (index <= 0 || index > categories.length) {
      return;
    }

    final categoryIndex = index - 1;
    final categoryId = categories[categoryIndex].id;

    if (categoryCache.containsKey(categoryId)) {
      return;
    }

    if (loadingCategories.contains(categoryId)) {
      return;
    }

    loadingCategories.add(categoryId);
    update();

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
      update();
    }
  }

  // ==========================================================
  // GET MOVIES
  // ==========================================================

  List<MovieModel> getMoviesForCategory(int index) {
    // Tab pertama: semua film.
    if (index == 0) {
      return allMovies.toList();
    }

    // Index UI 1 menjadi kategori backend index 0.
    final categoryIndex = index - 1;

    if (categoryIndex < 0 || categoryIndex >= categories.length) {
      return [];
    }

    final categoryId = categories[categoryIndex].id;

    return categoryCache[categoryId] ?? [];
  }

  // ==========================================================
  // CATEGORY LOADING STATE
  // ==========================================================

  bool isCategoryLoading(int index) {
    if (index == 0) {
      return loadingAllMovies.value;
    }

    final categoryIndex = index - 1;

    if (categoryIndex < 0 || categoryIndex >= categories.length) {
      return false;
    }

    final categoryId = categories[categoryIndex].id;

    return !categoryCache.containsKey(categoryId) &&
        loadingCategories.contains(categoryId);
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
