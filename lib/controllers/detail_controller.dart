import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/article_model.dart';

class DetailController extends GetxController {
  late final ArticleModel article;
  final RxBool isBookmarked = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is ArticleModel) {
      article = args;
    } else {
      article = const ArticleModel(
        title: 'Article Not Found',
        publishedAt: '',
      );
    }
  }

  void toggleBookmark() {
    isBookmarked.value = !isBookmarked.value;
  }

  Future<void> openArticleUrl() async {
    final urlString = article.url;
    if (urlString == null || urlString.isEmpty) return;

    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
