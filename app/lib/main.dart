import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qwe1/app.dart';
import 'package:qwe1/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final overrides = await createProviderOverrides();

  runApp(
    ProviderScope(
      overrides: overrides,
      child: const Qwe1App(),
    ),
  );
}
