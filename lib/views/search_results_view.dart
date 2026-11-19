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

class SearchResultsView extends StatefulWidget {
  const SearchResultsView({super.key});

  @override
  State<SearchResultsView> createState() => _SearchResultsViewState();
}

class _SearchResultsViewState extends State<SearchResultsView> {
  final NewsApiService _service = NewsApiService();
  late String _keyword;

  /// Future is stored in State, NEVER initialized directly in build()
  late Future<List<ArticleModel>> _futureSearch;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    _keyword = (args is String && args.trim().isNotEmpty) ? args.trim() : 'AI';
    _futureSearch = _service.searchNews(_keyword);
  }

  void _retrySearch() {
    setState(() {
      _futureSearch = _service.searchNews(_keyword);
    });
  }

  Future<void> _onRefresh() async {
    _retrySearch();
    try {
      await _futureSearch;
    } catch (_) {
      // FutureBuilder will render the error state
    }
  }

  void _showNewSearchDialog() {
    final textController = TextEditingController(text: _keyword);

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
              SizedBox(width: 8),
              Text(
                'Search News',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: TextField(
            controller: textController,
            autofocus: true,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'e.g. OpenAI, Nvidia, humanoid robot',
              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
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
            onSubmitted: (val) {
              final query = val.trim();
              if (query.isNotEmpty) {
                Navigator.of(dialogCtx).pop();
                setState(() {
                  _keyword = query;
                  _futureSearch = _service.searchNews(_keyword);
                });
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            FilledButton(
              onPressed: () {
                final query = textController.text.trim();
                if (query.isNotEmpty) {
                  Navigator.of(dialogCtx).pop();
                  setState(() {
                    _keyword = query;
                    _futureSearch = _service.searchNews(_keyword);
                  });
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Search'),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AppColors.textPrimary,
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Search Results',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '"$_keyword"',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            color: AppColors.primary,
            tooltip: 'Search Again',
            onPressed: _showNewSearchDialog,
          ),
        ],
      ),
      body: FutureBuilder<List<ArticleModel>>(
        future: _futureSearch,
        builder: (context, snapshot) {
          // State 1: Loading
          if (snapshot.connectionState != ConnectionState.done) {
            return LoadingView(message: 'Searching for "$_keyword"...');
          }

          // State 2: Error
          if (snapshot.hasError) {
            return ErrorView(
              message: snapshot.error.toString(),
              onRetry: _retrySearch,
            );
          }

          final articles = snapshot.data ?? [];

          // State 3: Empty
          if (articles.isEmpty) {
            return EmptyView(
              title: 'No Matching Articles',
              message: 'We could not find any articles matching "$_keyword".\nTry broader or different tech terms.',
              onRefresh: _retrySearch,
            );
          }

          // State 4: Data loaded
          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return ArticleCard(
                  article: article,
                  onTap: () => Get.toNamed(AppRoutes.detail, arguments: article),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
