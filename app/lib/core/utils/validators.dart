class Validators {
  Validators._();

  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL is required';
    }

    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return 'Invalid URL format';
    }

    if (uri.scheme != 'https' && uri.scheme != 'http') {
      return 'URL must use https or http';
    }

    return null;
  }

  static String? validateEnrollmentToken(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enrollment token is required';
    }

    if (!value.startsWith('qwe1-')) {
      return 'Invalid token format';
    }

    if (value.length < 20) {
      return 'Token is too short';
    }

    return null;
  }

  static String? validateServerName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Server name is required';
    }

    if (value.length < 2) {
      return 'Server name must be at least 2 characters';
    }

    if (value.length > 50) {
      return 'Server name must be less than 50 characters';
    }

    return null;
  }

  static String? validateFilePath(String? value) {
    if (value == null || value.isEmpty) {
      return 'Path is required';
    }

    if (!value.startsWith('/')) {
      return 'Path must be absolute';
    }

    return null;
  }

  static String? validateNotEmpty(String? value, [String fieldName = 'Field']) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }
}
