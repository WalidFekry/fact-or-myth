bool containsLink(String text) {
  final lowerText = text.toLowerCase();
  return lowerText.contains('http') ||
         lowerText.contains('www') ||
         lowerText.contains('.com') ||
         lowerText.contains('.net') ||
         lowerText.contains('.org');
}
