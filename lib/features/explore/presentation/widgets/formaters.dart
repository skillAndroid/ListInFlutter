String formatPrice(String value) {
  if (value.isEmpty) return '';

  // Convert to number and back to string to remove any non-numeric characters
  final number = double.tryParse(value.replaceAll(' ', ''));
  if (number == null) return value;

  // Convert to int to remove decimal places and format with spaces
  final parts = number.toInt().toString().split('').reversed.toList();

  String formatted = '';
  for (var i = 0; i < parts.length; i++) {
    if (i > 0 && i % 3 == 0) {
      formatted = ' $formatted';
    }
    formatted = parts[i] + formatted;
  }

  return formatted;
}
