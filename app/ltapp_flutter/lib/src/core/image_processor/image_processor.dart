import 'package:flutter/services.dart';

class ImageProcessor {
  static const MethodChannel _channel = MethodChannel(
    "com.ltapp.image_processor",
  );

  static Future<Uint8List?> processIcon(Uint8List imageBytes) async {
    try {
      final dynamic result = await _channel.invokeListMethod('processIcon', {
        'imageData': imageBytes,
      });
      return result as Uint8List?;
    } on PlatformException catch (e) {
      print("Failed to process image: '${e.message}'");
      return null;
    }
  }
}
