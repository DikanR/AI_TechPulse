import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/article_model.dart';
import '../routes/app_routes.dart';
import '../services/news_api_service.dart';
import '../utils/app_colors.dart';
import '../widgets/article_card.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final NewsApiService _service = NewsApiService();

  /// Curated worldwide AI & Technology categories
  static const Map<String, String> _categories = {
    'all_ai': 'All AI Tech',
    'chips': 'Chips & Hardware',
    'gen_ai': 'Generative AI & LLMs',
    'robotics': 'AI Robotics',
    'algorithms': 'Machine Learning',
    'policy': 'AI Policy & Ethics',
  };

  String _selectedCategory = 'all_ai';

  /// In-memory cache to save quota: `Map<CategoryKey, Future<List<ArticleModel>>>`
  /// Prevents redundant network calls when returning to previously loaded category chips.
  final Map<String, Future<List<ArticleModel>>> _categoryCache = {};

  /// Current Future displayed by FutureBuilder (stored in State, NEVER created in build())
  late Future<List<ArticleModel>> _currentFuture;

  @override
  void initState() {
    super.initState();
    _currentFuture = _getOrCreateCategoryFuture(_selectedCategory);
  }

  /// Retrieves cached Future if present, otherwise makes an API request and caches it.
  Future<List<ArticleModel>> _getOrCreateCategoryFuture(String category) {
    if (!_categoryCache.containsKey(category)) {
      _categoryCache[category] = _service.getNewsByCategory(category);
    }
    return _categoryCache[category]!;
  }

  /// Switches category chip and reuses cached future if already retrieved.
  void _switchCategory(String category) {
    if (category == _selectedCategory) return;
    setState(() {
      _selectedCategory = category;
      _currentFuture = _getOrCreateCategoryFuture(category);
    });
  }

  /// Forces re-fetching for the current category, refreshing the cache entry.
  void _reloadCurrentCategory() {
    setState(() {
      _categoryCache[_selectedCategory] = _service.getNewsByCategory(_selectedCategory);
      _currentFuture = _categoryCache[_selectedCategory]!;
    });
  }

  /// Used by RefreshIndicator to await completion.
  Future<void> _onRefresh() async {
    _reloadCurrentCategory();
    try {
      await _currentFuture;
    } catch (_) {
      // Handled and displayed by FutureBuilder snapshot.hasError
    }
  }

  /// Shows search dialog as required by the assignment.
  void _showSearchDialog() {
    final searchController = TextEditingController();
    final quickTopics = ['Nvidia GPU', 'OpenAI', 'Humanoid Robot', 'Quantum AI', 'TSMC'];

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Search AI News',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Search for global AI trends, chip shortages, or algorithms:',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: searchController,
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'e.g. semiconductor shortage, LLM...',
                  hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
                onSubmitted: (query) {
                  final keyword = query.trim();
                  if (keyword.isNotEmpty) {
                    Navigator.of(dialogCtx).pop();
                    Get.toNamed(AppRoutes.search, arguments: keyword);
                  }
                },
              ),
              const SizedBox(height: 14),
              const Text(
                'Quick Topics:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: quickTopics.map((topic) {
                  return ActionChip(
                    label: Text(topic, style: const TextStyle(fontSize: 11)),
                    backgroundColor: AppColors.surfaceVariant,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    onPressed: () {
                      Navigator.of(dialogCtx).pop();
                      Get.toNamed(AppRoutes.search, arguments: topic);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            FilledButton.icon(
              onPressed: () {
                final keyword = searchController.text.trim();
                if (keyword.isNotEmpty) {
                  Navigator.of(dialogCtx).pop();
                  Get.toNamed(AppRoutes.search, arguments: keyword);
                }
              },
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: const Text('Search'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI TechPulse',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Worldwide AI & DeepTech News',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            color: AppColors.textPrimary,
            tooltip: 'Search News',
            onPressed: _showSearchDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Quota Saver status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            color: AppColors.surface,
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Quota Saver: Cached in Map<String, Future>',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_categoryCache.length} cached',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Horizontal Category ChoiceChips
          _buildCategoryChips(),

          // Main News Feed rendered using FutureBuilder
          Expanded(
            child: FutureBuilder<List<ArticleModel>>(
              future: _currentFuture,
              builder: (context, snapshot) {
                // 1. Loading State
                if (snapshot.connectionState != ConnectionState.done) {
                  return const LoadingView();
                }

                // 2. Error State
                if (snapshot.hasError) {
                  return ErrorView(
                    message: snapshot.error.toString(),
                    onRetry: _reloadCurrentCategory,
                  );
                }

                final articles = snapshot.data ?? [];

                // 3. Empty State
                if (articles.isEmpty) {
                  return EmptyView(
                    title: 'No News Available',
                    message: 'No articles found for ${_categories[_selectedCategory]}.\nTry refreshing or picking another category.',
                    onRefresh: _reloadCurrentCategory,
                  );
                }

                // 4. Data State with Pull-To-Refresh
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      final article = articles[index];
                      return ArticleCard(
                        article: article,
                        onTap: () => Get.toNamed(
                          AppRoutes.detail,
                          arguments: article,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: _categories.entries.map((entry) {
            final isSelected = entry.key == _selectedCategory;
            final isCached = _categoryCache.containsKey(entry.key);

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                showCheckmark: false,
                avatar: isCached && !isSelected
                    ? const Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.primary)
                    : null,
                label: Text(
                  entry.value,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                selected: isSelected,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surfaceVariant,
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                onSelected: (_) => _switchCategory(entry.key),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
