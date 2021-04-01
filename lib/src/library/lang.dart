extension AnyExtension<T> on T {
  R let<R>(R Function(T) fn) => fn(this);

  T also(void Function(T) fn) {
    fn(this);
    return this;
  }
}

extension MapExtension<K, V> on Map<K, V> {
  Map<TK, TV> map<TK, TV>(MapEntry<TK, TV> Function(K, V) f) => entries
      .map((entry) => f(entry.key, entry.value))
      .let((it) => Map.fromEntries(it));

  Map<T, V> mapKeys<T>(T Function(K) f) =>
      map((key, value) => MapEntry(f(key), value));

  Map<K, T> mapValues<T>(T Function(V) f) =>
      map((key, value) => MapEntry(key, f(value)));

  Map<K, V> where(bool Function(K key, V value) test) => entries
      .where((entry) => test(entry.key, entry.value))
      .let((it) => Map.fromEntries(it));

  Map<K, V> whereKeys(bool Function(K key) test) =>
      where((key, value) => test(key));

  Map<K, V> whereValues(bool Function(V value) test) =>
      where((key, value) => test(value));
}

extension IterableExtension<T> on Iterable<T> {
  Iterable<MapEntry<int, T>> indexed() => toList().asMap().entries;

  Iterable<R> whereType<R>() sync* {
    for (final value in this) {
      if (value is R) yield value;
    }
  }
}

extension StringExtension on String {
  bool get isBlank => trim().isEmpty;

  bool get isNotBlank => !isBlank;
}

extension MapJsonExtension on Map {
  Map<String, dynamic> asJsonObject() => cast<String, dynamic>();

  Map<String, dynamic> asJsonObjectDeep() =>
      _castMapsToJsonObjectDeep(this) as Map<String, dynamic>;
}

dynamic _castMapsToJsonObjectDeep(dynamic value) {
  if (value is Iterable) {
    return value.map<dynamic>(_castMapsToJsonObjectDeep).toList();
  } else if (value is Map) {
    return value
        .cast<String, dynamic>()
        .mapValues<dynamic>(_castMapsToJsonObjectDeep);
  }

  return value;
}

extension ObjectJsonExtension on Object {
  Map<String, dynamic> asJsonObject() => (this as Map).asJsonObject();

  Map<String, dynamic> asJsonObjectDeep() => (this as Map).asJsonObjectDeep();
}

extension JsonObjectExtension on Map<String, dynamic> {
  String? getString(String key) => this[key] as String?;

  bool? getBool(String key) => this[key] as bool?;

  int? getInt(String key) => this[key] as int?;

  double? getDouble(String key) => this[key] as double?;

  num? getNum(String key) => this[key] as num?;

  List<T>? getArray<T>(String key) => this[key] as List<T>?;

  Map<String, dynamic> getJsonObject(String key) =>
      (this[key] as Object).asJsonObject();
}
