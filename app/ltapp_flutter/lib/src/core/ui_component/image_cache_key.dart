mixin ImageCacheKeyType {
  String cacheKey(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.pathSegments.last;
    } catch (e) {
      return url;
    }
  }
}

class ImageCacheKey with ImageCacheKeyType {}
