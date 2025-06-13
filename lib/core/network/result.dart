class Result<T> {
  final T? data;
  final ApiError? error;

  Result.success(this.data) : error = null;

  Result.failure(this.error) : data = null;

  bool get isSuccess => data != null;
}

class ApiError {
  final int statusCode;
  final String message;

  ApiError({required this.statusCode, required this.message});

  @override
  String toString() => 'Error: $message';
}
