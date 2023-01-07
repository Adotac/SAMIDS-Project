extension StringExtension on String {
    String capitalize() {
      return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
    }
}

extension HexString on String {
  int getHexValue() => int.parse(replaceAll('#', '0xff'));
}