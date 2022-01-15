extension SanitizeString on String {
  String get sanitize => replaceAll(r'&', '&amp;')
      .replaceAll(r'<', '&lt;')
      .replaceAll(r'>', '&gt;');
}
