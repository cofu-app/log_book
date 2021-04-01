class NotFoundException implements Exception {
  final message = 'Could not find the requested object';
}

extension FutureNotFoundExceptionExtension<T> on Future<T?> {
  Future<T> requireFound() =>
      // ignore: prefer_if_null_operators
      then((value) => value != null ? value : throw NotFoundException());
}
