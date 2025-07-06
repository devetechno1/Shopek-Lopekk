extension NumEx on num? {
  String? padLeft(int width, [String padding = '0']) {
    return this?.toString().padLeft(width, padding);
  }

  String? get fromSeconds {
    if (this == null) return null;
    final String seconds = (this! % 60).round().padLeft(2)!;
    final String minutes = (this! / 60).floor().padLeft(2)!;
    return '$minutes:$seconds';
  }
}
