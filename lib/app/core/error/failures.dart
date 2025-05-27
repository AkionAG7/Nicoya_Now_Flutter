/// Base failure class for domain layer failures
abstract class Failure {
  const Failure([this.message = '']);
  
  final String message;
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

/// Failure for server-side errors
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

/// Failure for network connectivity issues
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error occurred']);
}

/// Failure for cache-related errors
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

/// Failure for validation errors
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation error occurred']);
}

/// Failure for authentication errors
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication error occurred']);
}

/// Failure for not found errors
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found']);
}
