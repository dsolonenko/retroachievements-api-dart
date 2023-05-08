import 'dart:convert';
import 'package:http/http.dart' as http;

import 'auth.dart';
import 'request.dart';

class GameEntity {
  final String title;
  final int id;
  final int consoleId;
  final String consoleName;
  final String imageIcon;
  final int numAchievements;
  final int numLeaderboards;
  final int points;
  final String? dateModified;
  final int? forumTopicId;
  final List<String>? hashes;

  GameEntity({
    required this.title,
    required this.id,
    required this.consoleId,
    required this.consoleName,
    required this.imageIcon,
    required this.numAchievements,
    required this.numLeaderboards,
    required this.points,
    required this.dateModified,
    required this.forumTopicId,
    this.hashes,
  });

  factory GameEntity.fromJson(Map<String, dynamic> json) {
    return GameEntity(
      title: json['Title'],
      id: json['ID'],
      consoleId: json['ConsoleID'],
      consoleName: json['ConsoleName'],
      imageIcon: json['ImageIcon'],
      numAchievements: json['NumAchievements'],
      numLeaderboards: json['NumLeaderboards'],
      points: json['Points'],
      dateModified: json['DateModified'],
      forumTopicId: json['ForumTopicId'],
      hashes:
          json['Hashes'] != null ? (json['Hashes'] as List<dynamic>).map((dynamic e) => e as String).toList() : null,
    );
  }

  @override
  String toString() {
    return 'GameEntity(title: $title, id: $id, consoleId: $consoleId, consoleName: $consoleName, imageIcon: $imageIcon, numAchievements: $numAchievements, numLeaderboards: $numLeaderboards, points: $points, dateModified: $dateModified, forumTopicId: $forumTopicId, hashes: $hashes)';
  }
}

typedef GameList = List<GameEntity>;

class ConsoleId {
  final int id;
  final String name;

  ConsoleId({
    required this.id,
    required this.name,
  });

  factory ConsoleId.fromJson(Map<String, dynamic> json) {
    return ConsoleId(
      id: json['ID'] as int,
      name: json['Name'] as String,
    );
  }

  @override
  String toString() => 'ConsoleId(id: $id, name: $name)';
}

/// A call to this function will retrieve the complete list
/// of console ID and name pairs on the RetroAchievements.org
/// platform.
///
/// @param authorization An object containing your userName and webApiKey.
/// This can be constructed with `buildAuthorization()`.
///
/// @example
/// ```
/// final consoleIds = await getConsoleIds(authorization);
/// ```
///
/// @returns A list containing a complete list of console ID
/// and name pairs for RetroAchievements.org.
/// ```
/// { id: 1, name: 'Mega Drive' }
/// ```
Future<List<ConsoleId>> getConsoleIds(AuthObject authorization) async {
  final url = buildRequestUrl(
    apiBaseUrl,
    '/API_GetConsoleIDs.php',
    authorization,
  );

  final response = await http.get(Uri.parse(url));
  final rawResponse = json.decode(response.body) as List<dynamic>;

  return rawResponse.map((console) => ConsoleId.fromJson(console)).toList();
}

/// A call to this function will retrieve the complete list
/// of games for a specified console on the RetroAchievements.org
/// platform.
///
/// @param authorization An object containing your userName and webApiKey.
/// This can be constructed with `buildAuthorization()`.
///
/// @param payload.consoleId The unique console ID to retrieve a list of
/// games from. The list of consoleIds can be retrieved using the `getConsoleIds()`
/// function provided by this library.
///
/// @param payload.shouldOnlyRetrieveGamesWithAchievements If truthy, will not
/// return games that do not have achievements.
///
/// @param payload.shouldRetrieveGameHashes If truthy, will return valid
/// hashes for game ROMs in an array attached to each game in the list.
///
/// @example
/// ```
/// final gameList = await getGameList(
///   authorization,
///   GetGameListPayload(consoleId: 1, shouldOnlyRetrieveGamesWithAchievements: true),
/// );
/// ```
///
/// @returns A list containing a list of games for a given consoleId.
/// ```
/// [
///   {
///     title: 'Elemental Master',
///     id: 4247,
///     consoleId: 1,
///     consoleName: 'Mega Drive',
///     imageIcon: '/Images/048245.png',
///     numAchievements: 44,
///     numLeaderboards: 0,
///     points: 500,
///     dateModified: '2021-12-09 17:05:39',
///     forumTopicId: 1972,
///     hashes: ['32e1a15161ef1f070b023738353bde51']
///   }
/// ]
/// ```
Future<GameList> getGameList(
  AuthObject authorization, {
  required int consoleId,
  bool shouldOnlyRetrieveGamesWithAchievements = true,
  bool shouldRetrieveGameHashes = true,
}) async {
  Map<String, dynamic> callPayload = {'i': consoleId};

  if (shouldOnlyRetrieveGamesWithAchievements) {
    callPayload.addAll({
      'f': shouldOnlyRetrieveGamesWithAchievements ? 1 : 0,
    });
  }

  if (shouldRetrieveGameHashes) {
    callPayload.addAll({
      'h': shouldRetrieveGameHashes ? 1 : 0,
    });
  }

  final url = buildRequestUrl(
    apiBaseUrl,
    '/API_GetGameList.php',
    authorization,
    args: callPayload,
  );

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final rawResponse = jsonDecode(response.body) as List<dynamic>;
    final gameList = rawResponse.map((game) => GameEntity.fromJson(game)).toList();
    return gameList;
  } else {
    throw Exception('Failed to load game list');
  }
}
