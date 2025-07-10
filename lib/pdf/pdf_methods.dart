
bool containsArabic(String text) {
  final arabicRegex = RegExp(r'[\u0600-\u06FF]');
  return arabicRegex.hasMatch(text);
}

String processText(String text) {
  if (containsArabic(text)) {
    // نعكس النص ليظهر بشكل RTL (بديل بدائي لـ bidi + reshaping)
    return text.split('').reversed.join();
  }
  return text;
}
