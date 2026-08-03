import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qwe1/app.dart';
import 'package:qwe1/state/settings/settings_provider.dart';
import 'package:qwe1/state/servers/server_provider.dart';
import 'package:qwe1/state/docker/container_provider.dart';
import 'package:qwe1/state/terminal/terminal_provider.dart';
import 'package:qwe1/state/files/file_provider.dart';
import 'package:qwe1/state/alerts/alert_provider.dart';

import 'test_overrides.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureStorageProvider.overrideWithValue(FakeSecureStorage()),
          serverRepositoryProvider.overrideWithValue(FakeServerRepository()),
          dockerRepositoryProvider.overrideWithValue(FakeDockerRepository()),
          terminalRepositoryProvider.overrideWithValue(FakeTerminalRepository()),
          fileRepositoryProvider.overrideWithValue(FakeFileRepository()),
          alertRepositoryProvider.overrideWithValue(FakeAlertRepository()),
        ],
        child: const Qwe1App(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Servers'), findsOneWidget);
  });
}
