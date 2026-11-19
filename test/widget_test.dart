import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/models/article_model.dart';
import 'package:news_app/widgets/article_card.dart';
import 'package:news_app/widgets/empty_view.dart';
import 'package:news_app/widgets/error_view.dart';

void main() {
  testWidgets('ErrorView renders error message and triggers onRetry callback', (tester) async {
    bool retryTapped = false;
    const testErrorMessage = 'Daily request limit reached or account email is unverified.';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorView(
            message: testErrorMessage,
            onRetry: () {
              retryTapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Something Went Wrong'), findsOneWidget);
    expect(find.text(testErrorMessage), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);

    await tester.tap(find.text('Try Again'));
    await tester.pump();

    expect(retryTapped, isTrue);
  });

  testWidgets('EmptyView displays title and message properly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyView(
            title: 'No Articles Found',
            message: 'Try selecting a different AI subtopic.',
          ),
        ),
      ),
    );

    expect(find.text('No Articles Found'), findsOneWidget);
    expect(find.text('Try selecting a different AI subtopic.'), findsOneWidget);
  });

  testWidgets('ArticleCard renders title, author, and triggers onTap', (tester) async {
    bool tapped = false;
    const article = ArticleModel(
      title: 'DeepSeek Launches Open Weights Model',
      description: 'The new model matches frontier performance at low cost.',
      author: 'AI Insider',
      publishedAt: '2026-11-19T06:00:00Z',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ArticleCard(
            article: article,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('DeepSeek Launches Open Weights Model'), findsOneWidget);
    expect(find.text('AI Insider'), findsOneWidget);
    expect(find.text('Read Article'), findsOneWidget);

    await tester.tap(find.text('DeepSeek Launches Open Weights Model'));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
