import 'package:retroachievements/auth.dart';
import 'package:retroachievements/request.dart';
import 'package:test/test.dart';

void main() {
  group('Util: buildRequestUrl', () {
    test('is defined #sanity', () {
      expect(buildRequestUrl, isNotNull);
    });

    test('given a baseUrl, endpointUrl, and some arguments, returns a correctly-constructed URL', () {
      const baseUrl = 'https://retroachievements.org/API/';
      const endpointUrl = '/:baz/API_GetConsoleIDs.php';

      final args = {
        'baz': 'myBazValue',
        'limit': 10,
        'offset': 2,
        'notDefined': null,
      };

      final requestUrl = buildRequestUrl(
        baseUrl,
        endpointUrl,
        AuthObject(userName: 'TestUser', webApiKey: 'mockWebApiKey'),
        args: args,
      );

      expect(
        requestUrl,
        equals(
          'https://retroachievements.org/API/myBazValue/API_GetConsoleIDs.php?z=TestUser&y=mockWebApiKey&limit=10&offset=2',
        ),
      );
    });

    test('given no arguments, returns a correctly-constructed URL', () {
      const baseUrl = 'https://retroachievements.org/API/';
      const endpointUrl = '/:baz/API_GetConsoleIDs.php';

      final requestUrl = buildRequestUrl(
        baseUrl,
        endpointUrl,
        AuthObject(userName: 'TestUser', webApiKey: 'mockWebApiKey'),
      );

      expect(
        requestUrl,
        equals(
          'https://retroachievements.org/API/:baz/API_GetConsoleIDs.php?z=TestUser&y=mockWebApiKey',
        ),
      );
    });
  });
}
