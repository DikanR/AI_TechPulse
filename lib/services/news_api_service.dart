import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/env.dart';
import '../models/article_model.dart';
import '../models/news_response_model.dart';
import 'api_exception.dart';

/// Service class for fetching news from GNews API using Dio.
/// API URL and Key are managed through [Env] configurations.
class NewsApiService {
  final Dio _dio;

  NewsApiService({Dio? dio}) : _dio = dio ?? _createDio();

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: Env.baseUrl.isNotEmpty ? Env.baseUrl : 'https://gnews.io/api/v4',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        // Included in every request
        queryParameters: {
          if (Env.pakaiKeyLangsung) 'apikey': Env.apiKey,
          'lang': 'en',
          'max': 10,
        },
      ),
    );

    // Logging only in debug mode, masking API key
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          responseBody: true,
          logPrint: (obj) => debugPrint(Env.samarkan(obj.toString())),
        ),
      );
    }

    return dio;
  }

  /// Fetches top headlines for a given category (default: 'technology')
  Future<List<ArticleModel>> getTopHeadlines({String category = 'technology'}) {
    return _fetchArticles('/top-headlines', {'category': category});
  }

  /// Searches for articles matching a given keyword or search query
  Future<List<ArticleModel>> searchNews(String keyword) {
    if (keyword.trim().isEmpty) {
      return Future.error(
        ApiException('Search query cannot be empty. Please enter a valid keyword.', statusCode: 400),
      );
    }
    return _fetchArticles('/search', {
      'q': keyword.trim(),
      'sortby': 'publishedAt',
    });
  }

  /// Convenient category fetcher focused on worldwide AI & Technology topics
  Future<List<ArticleModel>> getNewsByCategory(String categoryKey) {
    const Map<String, String> aiQueryMap = {
      'all_ai': 'artificial intelligence OR AI',
      'chips': 'semiconductors OR "chip shortage" OR nvidia OR tsmc',
      'gen_ai': '"generative AI" OR "large language model" OR LLM',
      'robotics': '"AI robotics" OR "humanoid robot" OR automation',
      'algorithms': '"machine learning" OR "neural network" OR algorithm',
      'policy': '"AI safety" OR "AI regulation" OR "AI ethics"',
    };

    final query = aiQueryMap[categoryKey];
    if (query != null) {
      return searchNews(query);
    }
    return getTopHeadlines(category: categoryKey);
  }

  /// Single gateway for all GET requests to ensure centralized error transformation.
  Future<List<ArticleModel>> _fetchArticles(String path, Map<String, dynamic> query) async {
    if (!Env.lengkap) {
      throw ApiException(
        'Configuration is missing. Please provide GNEWS_BASE_URL and GNEWS_API_KEY '
        'via --dart-define-from-file=config/env.json.',
      );
    }

    try {
      final response = await _dio.get(path, queryParameters: query);
      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw ApiException('Unrecognized response format received from server.');
      }

      return NewsResponseModel.fromJson(data).articles;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    } on TypeError {
      throw ApiException('Server data structure does not match expected model.');
    }
  }
}
