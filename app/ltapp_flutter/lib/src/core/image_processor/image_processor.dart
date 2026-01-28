import 'package:flutter/services.dart';

class IconParams {
  final String iconId;
  final String imageUrl;

  const IconParams({required this.iconId, required this.imageUrl});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IconParams && other.iconId == iconId;
  }

  @override
  int get hashCode => iconId.hashCode;
}

class ImageProcessor {
  static const MethodChannel _channel = MethodChannel(
    "com.ltapp.image_processor",
  );

  static Future<Uint8List?> processIcon(Uint8List imageBytes) async {
    try {
      final dynamic result = await _channel.invokeListMethod('processIcon', {
        'imageData': imageBytes,
      });
      if (result == null) return null;
      if (result is Uint8List) {
        return result;
      } else if (result is List) {
        return Uint8List.fromList(result.cast<int>());
      }
      return null;
    } on PlatformException catch (e) {
      print("Failed to process image: '${e.message}'");
      return null;
    }
  }
}
