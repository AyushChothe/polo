/// Helps to build a `Polo` compatible Type
abstract class PoloType {
  Map<String, dynamic> toMap() {
    throw UnimplementedError();
  }

  factory PoloType.fromMap(Map<String, dynamic> map) {
    throw UnimplementedError();
  }
}

/// Registers a Object or `PoloType` as a Type
class PoloTypeAdapter<T> {
  PoloTypeAdapter({required this.toMap, required this.fromMap});

  final Map<String, dynamic> Function(T type) toMap;

  final T Function(Map<String, dynamic> map) fromMap;
}
