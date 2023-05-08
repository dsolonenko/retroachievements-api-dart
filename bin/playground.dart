import 'dart:io';

import 'package:retroachievements/auth.dart';
import 'package:retroachievements/console.dart' as retroachievements;

void main(List<String> arguments) async {
  final userName = Platform.environment["RA_USERNAME"] ?? "";
  final webApiKey = Platform.environment["RA_APIKEY"] ?? "";

  final auth = AuthObject.buildAuthorization(userName: userName, webApiKey: webApiKey);
  final consoleIds = await retroachievements.getConsoleIds(auth);
  for (var id in consoleIds) {
    print(id);
  }

  final games = await retroachievements.getGameList(auth, consoleId: consoleIds[0].id);
  for (var game in games) {
    print(game);
  }
}
