import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lt_uicomponent/uicomponent.dart';
import 'package:lt_reflection_service/reflection_service.dart';

class ProcessedIconView extends ConsumerWidget with ImageCacheKeyType {
  final String imageUrl;
  final double? width;
  final double? height;
  final Widget placeholder;
  final String herTag;
  final VoidCallback? onImageLoaded;

  const ProcessedIconView({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    required this.placeholder,
    required this.herTag,
    this.onImageLoaded,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iconParams = IconParams(
      iconId: cacheKey(imageUrl),
      imageUrl: imageUrl,
    );
    final asyncImage = ref.watch(processedIconProvider(iconParams));
    return asyncImage.when(
      data: (bytes) {
        if (bytes == null) return placeholder;
        if (onImageLoaded != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onImageLoaded!();
          });
        }
        return Hero(
          tag: herTag,
          child: Image.memory(
            bytes,
            width: width,
            height: height,
            fit: BoxFit.contain,
          ),
        );
      },
      error: (err, stack) => _buildPlaceholder(),
      loading: () => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return SizedBox(width: width, height: height ?? 100.0, child: placeholder);
  }
}
