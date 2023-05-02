class EnumValues<T> {
  late Map<int, T> map;
  late Map<T, int> reverseMap;

  EnumValues(this.map) {
    reverseMap = map.map((k, v) => MapEntry(v, k));
  }

  Map<T, int> get reverse {
    return reverseMap;
  }
}