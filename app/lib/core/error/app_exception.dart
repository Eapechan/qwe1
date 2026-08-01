sealed class AppException implements Exception {
  const AppException(this.message, [this.stackTrace]);

  final String message;
  final StackTrace? stackTrace;

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkException extends AppException {
  const NetworkException(super.message, [super.stackTrace]);
}

class AuthException extends AppException {
  const AuthException(super.message, [super.stackTrace]);
}

class ServerNotFoundException extends AppException {
  const ServerNotFoundException(super.message, [super.stackTrace]);
}

class ContainerException extends AppException {
  const ContainerException(super.message, [super.stackTrace]);
}

class TerminalException extends AppException {
  const TerminalException(super.message, [super.stackTrace]);
}

class FileException extends AppException {
  const FileException(super.message, [super.stackTrace]);
}

class ValidationException extends AppException {
  const ValidationException(super.message, [super.stackTrace]);
}

class RateLimitException extends AppException {
  const RateLimitException(super.message, [super.stackTrace]);
}

class ServerUnavailableException extends AppException {
  const ServerUnavailableException(super.message, [super.stackTrace]);
}
