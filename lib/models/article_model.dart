class ArticleModel {
  final String? id;
  final String title;
  final String? description;
  final String? content;
  final String? url;
  final String? urlToImage;
  final String publishedAt;
  final String? author;

  const ArticleModel({
    this.id,
    required this.title,
    this.description,
    this.content,
    this.url,
    this.urlToImage,
    required this.publishedAt,
    this.author,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    final source = json['source'];
    return ArticleModel(
      id: json['id'] as String?,
      author: source is Map ? source['name'] as String? : null,
      title: json['title'] as String? ?? 'Untitled Article',
      description: json['description'] as String?,
      url: json['url'] as String?,
      urlToImage: json['image'] as String?,
      publishedAt: json['publishedAt'] as String? ?? '',
      content: _rapikanContent(json['content'] as String?),
    );
  }

  /// Cleans truncated trailing characters tag added by GNews free tier (e.g. " [1200 chars]")
  static String? _rapikanContent(String? content) {
    if (content == null) return null;
    return content.replaceAll(RegExp(r'\s*\[\d+\s*chars\]$', caseSensitive: false), '...');
  }
}
