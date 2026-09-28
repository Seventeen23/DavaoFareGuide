import '../error/failure.dart';

sealed class Result<T> {
  const Result();

  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(Failure failure) = FailureResult<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is FailureResult<T>;

  T? get dataOrNull => switch (this) {
    Success<T>(:final data) => data,
    FailureResult<T>() => null,
  };

  Failure? get failureOrNull => switch (this) {
    Success<T>() => null,
    FailureResult<T>(:final failure) => failure,
  };

  R fold<R>(R Function(T data) onSuccess, R Function(Failure f) onFailure) {
    return switch (this) {
      Success<T>(:final data) => onSuccess(data),
      FailureResult<T>(:final failure) => onFailure(failure),
    };
  }
}

final class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;

  @override
  String toString() => 'Success($data)';
}

final class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);

  final Failure failure;

  @override
  String toString() => 'FailureResult($failure)';
}
