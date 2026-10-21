import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.imageUrl,
    this.size = 40,
    this.borderRadius = 8,
  });

  final String? imageUrl;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = imageUrl?.trim() ?? '';
    final placeholder = Icon(
      Icons.image_outlined,
      size: size * 0.55,
      color: theme.colorScheme.onSurfaceVariant,
    );
    final box = SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: url.isEmpty
            ? ColoredBox(color: theme.colorScheme.surfaceContainerHighest, child: placeholder)
            : Image.network(
                url,
                fit: BoxFit.cover,
                width: size,
                height: size,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return ColoredBox(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Center(
                      child: SizedBox(
                        width: size * 0.4,
                        height: size * 0.4,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => ColoredBox(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: size * 0.55,
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
      ),
    );
    return box;
  }
}
