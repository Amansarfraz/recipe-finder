import 'constants.dart';

/// Routes external (Spoonacular) image URLs through our own backend proxy.
///
/// Flutter Web's rendering engine needs CORS-allowed responses to draw
/// images on canvas, and Spoonacular's CDN doesn't send CORS headers.
/// Our backend already has CORS enabled, so fetching the image through
/// /image-proxy makes it load correctly on web. On mobile this proxy
/// works fine too (just one extra hop), so it's safe to use everywhere.
String? proxiedImageUrl(String? originalUrl) {
  if (originalUrl == null || originalUrl.isEmpty) return null;
  final encoded = Uri.encodeComponent(originalUrl);
  return '${ApiConstants.baseUrl}/image-proxy?url=$encoded';
}
