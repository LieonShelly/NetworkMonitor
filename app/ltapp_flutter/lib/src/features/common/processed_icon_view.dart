import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltapp_flutter/src/service/providers/providers.dart';

class ProcessedIconView extends ConsumerWidget {
  final String imageUrl;
  final double width;
  final double height;
  final Widget placeholder;
  final String herTag;

  const ProcessedIconView({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    required this.placeholder,
    required this.herTag,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncImage = ref.watch(processedIconProvider(imageUrl));
    return SizedBox(
      width: width,
      height: height,
      child: asyncImage.when(
        data: (bytes) {
          if (bytes == null) return placeholder;
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
        error: (err, stack) => placeholder,
        loading: () => placeholder,
      ),
    );
  }
}
