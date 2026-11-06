/// Standard domain failure object for typed service & viewmodel error handling
class AppFailure {
  const AppFailure({
    required this.code,
    required this.message,
    this.isRetryable = false,
    this.details,
  });

  final String code;
  final String message;
  final bool isRetryable;
  final dynamic details;

  @override
  String toString() =>
      'AppFailure(code: $code, message: $message, isRetryable: $isRetryable)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppFailure &&
        other.code == code &&
        other.message == message &&
        other.isRetryable == isRetryable;
  }

  @override
  int get hashCode => Object.hash(code, message, isRetryable);
}
