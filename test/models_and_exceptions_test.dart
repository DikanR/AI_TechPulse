import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/models/article_model.dart';
import 'package:news_app/models/news_response_model.dart';
import 'package:news_app/services/api_exception.dart';

void main() {
  group('ArticleModel Tests', () {
    test('parses JSON correctly and strips [123 chars] from content', () {
      final json = {
        'id': 'abc12345',
        'title': 'Nvidia Announces Next-Gen AI Chip',
        'description': 'A breakthrough in semiconductor technology.',
        'content': 'Nvidia unveiled its newest GPU architecture today. [940 chars]',
        'url': 'https://example.com/nvidia-chip',
        'image': 'https://example.com/chip.jpg',
        'publishedAt': '2026-11-19T08:00:00Z',
        'source': {'id': 'tech-daily', 'name': 'TechDaily'},
      };

      final article = ArticleModel.fromJson(json);

      expect(article.id, 'abc12345');
      expect(article.title, 'Nvidia Announces Next-Gen AI Chip');
      expect(article.author, 'TechDaily');
      expect(article.content, 'Nvidia unveiled its newest GPU architecture today....');
      expect(article.urlToImage, 'https://example.com/chip.jpg');
    });

    test('parses NewsResponseModel correctly', () {
      final json = {
        'totalArticles': 1,
        'articles': [
          {
            'title': 'AI Breakthrough',
            'publishedAt': '2026-11-19T10:00:00Z',
          }
        ]
      };

      final response = NewsResponseModel.fromJson(json);
      expect(response.totalArticles, 1);
      expect(response.articles.length, 1);
      expect(response.articles.first.title, 'AI Breakthrough');
    });
  });

  group('ApiException Scenarios (Minimum 4 Scenarios Required)', () {
    test('Scenario 1: Connection timeout', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/top-headlines'),
        type: DioExceptionType.connectionTimeout,
      );
      final apiException = ApiException.fromDio(dioException);
      expect(apiException.message, contains('Connection timed out'));
    });

    test('Scenario 2: No internet connection', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/top-headlines'),
        type: DioExceptionType.connectionError,
      );
      final apiException = ApiException.fromDio(dioException);
      expect(apiException.message, contains('No internet connection'));
    });

    test('Scenario 3: Bad response - 401 Invalid API key', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/top-headlines'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/top-headlines'),
          statusCode: 401,
        ),
      );
      final apiException = ApiException.fromDio(dioException);
      expect(apiException.statusCode, 401);
      expect(apiException.message, contains('API key is invalid'));
    });

    test('Scenario 4: Bad response - 403 Quota exceeded or unverified email', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/top-headlines'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/top-headlines'),
          statusCode: 403,
        ),
      );
      final apiException = ApiException.fromDio(dioException);
      expect(apiException.statusCode, 403);
      expect(apiException.message, contains('Daily request limit reached'));
    });

    test('Scenario 5: Bad response - 429 Rate limiting', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/top-headlines'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/top-headlines'),
          statusCode: 429,
        ),
      );
      final apiException = ApiException.fromDio(dioException);
      expect(apiException.statusCode, 429);
      expect(apiException.message, contains('Too many requests'));
    });

    test('Scenario 6: Bad response - 500 Server error', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/top-headlines'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/top-headlines'),
          statusCode: 502,
        ),
      );
      final apiException = ApiException.fromDio(dioException);
      expect(apiException.statusCode, 502);
      expect(apiException.message, contains('GNews server is temporarily unavailable'));
    });
  });
}
