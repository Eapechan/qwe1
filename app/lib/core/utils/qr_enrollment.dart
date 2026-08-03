import 'dart:io';
import 'package:flutter/foundation.dart';

/// Parsed data from a qwe1:// QR code.
class QrEnrollmentData {
  final String agentUrl;
  final String tailscaleUrl;
  final String name;
  final String token;
  final String fingerprint;

  const QrEnrollmentData({
    required this.agentUrl,
    this.tailscaleUrl = '',
    required this.name,
    required this.token,
    this.fingerprint = '',
  });

  /// Parse a qwe1://enroll?... URI from a QR code scan.
  static QrEnrollmentData? parse(String raw) {
    try {
      final uri = Uri.parse(raw.trim());
      if (uri.scheme != 'qwe1' || uri.host != 'enroll') return null;

      final agentUrl = uri.queryParameters['agentUrl'] ?? '';
      final tailscaleUrl = uri.queryParameters['tsUrl'] ?? '';
      final name = uri.queryParameters['name'] ?? '';
      final token = uri.queryParameters['token'] ?? '';
      final fingerprint = uri.queryParameters['fp'] ?? '';

      if (agentUrl.isEmpty || token.isEmpty) return null;

      return QrEnrollmentData(
        agentUrl: agentUrl,
        tailscaleUrl: tailscaleUrl,
        name: name,
        token: token,
        fingerprint: fingerprint,
      );
    } catch (e) {
      debugPrint('[qr] failed to parse QR payload: $e');
      return null;
    }
  }

  /// Build the qwe1:// URI for encoding as a QR code.
  static String buildUri({
    required String agentUrl,
    String tailscaleUrl = '',
    required String name,
    required String token,
    String fingerprint = '',
  }) {
    final params = <String, String>{
      'agentUrl': agentUrl,
      'name': name,
      'token': token,
    };
    if (tailscaleUrl.isNotEmpty) params['tsUrl'] = tailscaleUrl;
    if (fingerprint.isNotEmpty) params['fp'] = fingerprint;

    return Uri(
      scheme: 'qwe1',
      host: 'enroll',
      queryParameters: params,
    ).toString();
  }
}
