mixin ImageCacheKeyType {
  String cacheKey(String url) {
    try {
      final uri = Uri.parse(url);
      final lastPath = uri.pathSegments.last;
      final lastPaths = lastPath.split('.');
      return lastPaths.first;
    } catch (e) {
      return url;
    }
  }
}

class ImageCacheKey with ImageCacheKeyType {}
