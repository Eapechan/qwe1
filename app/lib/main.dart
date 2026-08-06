import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qwe1/app.dart';
import 'package:qwe1/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  List<Override> overrides = [];
  try {
    overrides = await createProviderOverrides();
  } catch (e) {
    debugPrint('[main] Provider initialization failed: $e');
    // App will still launch but providers will throw if accessed
  }

  runApp(
    ProviderScope(
      overrides: overrides,
      child: const Qwe1App(),
    ),
  );
}
