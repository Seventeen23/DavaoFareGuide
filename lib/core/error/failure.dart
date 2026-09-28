enum AppFailure {
  notFound,
  network,
  database,
  parsing,
  validation,
  unknown,
}

class Failure {
  const Failure(this.code, this.message, {this.cause});

  final AppFailure code;
  final String message;
  final Object? cause;

  @override
  String toString() => 'Failure($code, $message)';
}

class AppException implements Exception {
  const AppException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'AppException: $message';
}
