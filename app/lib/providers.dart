import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qwe1/data/sources/local/database.dart';
import 'package:qwe1/data/sources/local/secure_storage.dart';
import 'package:qwe1/data/repositories/server_repository_impl.dart';
import 'package:qwe1/data/repositories/docker_repository_impl.dart';
import 'package:qwe1/data/repositories/terminal_repository_impl.dart';
import 'package:qwe1/data/repositories/file_repository_impl.dart';
import 'package:qwe1/data/repositories/alert_repository_impl.dart';
import 'package:qwe1/state/servers/server_provider.dart';
import 'package:qwe1/state/docker/container_provider.dart';
import 'package:qwe1/state/terminal/terminal_provider.dart';
import 'package:qwe1/state/files/file_provider.dart';
import 'package:qwe1/state/alerts/alert_provider.dart';
import 'package:qwe1/state/settings/settings_provider.dart';

Future<List<Override>> createProviderOverrides() async {
  final database = AppDatabase();
  final secureStorage = SecureStorage();

  final serverRepo = ServerRepositoryImpl(
    database: database,
    secureStorage: secureStorage,
  );

  final dockerRepo = DockerRepositoryImpl(
    serverRepository: serverRepo,
  );

  final terminalRepo = TerminalRepositoryImpl(
    serverRepository: serverRepo,
  );

  final fileRepo = FileRepositoryImpl(
    serverRepository: serverRepo,
  );

  final alertRepo = AlertRepositoryImpl(
    serverRepository: serverRepo,
  );

  return [
    secureStorageProvider.overrideWithValue(secureStorage),
    serverRepositoryProvider.overrideWithValue(serverRepo),
    dockerRepositoryProvider.overrideWithValue(dockerRepo),
    terminalRepositoryProvider.overrideWithValue(terminalRepo),
    fileRepositoryProvider.overrideWithValue(fileRepo),
    alertRepositoryProvider.overrideWithValue(alertRepo),
  ];
}
