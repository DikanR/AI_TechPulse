import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class NewsImage extends StatelessWidget {
  final String url;
  final double height;
  final BoxFit fit;

  const NewsImage({
    super.key,
    required this.url,
    this.height = 200,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      height: height,
      width: double.infinity,
      color: AppColors.surfaceVariant,
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );

    final error = Container(
      height: height,
      width: double.infinity,
      color: AppColors.surfaceVariant,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_not_supported_outlined, size: 40, color: AppColors.textMuted),
            const SizedBox(height: 6),
            const Text(
              'No Preview Image',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );

    if (kIsWeb) {
      return Image.network(
        url,
        height: height,
        width: double.infinity,
        fit: fit,
        webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : placeholder,
        errorBuilder: (context, e, st) => error,
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      height: height,
      width: double.infinity,
      fit: fit,
      placeholder: (context, url) => placeholder,
      errorWidget: (context, url, e) => error,
    );
  }
}
