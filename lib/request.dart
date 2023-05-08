import 'auth.dart';

const String apiBaseUrl = 'https://retroachievements.org/API';

String buildRequestUrl(
  String baseUrl,
  String endpointUrl,
  AuthObject authObject, {
  Map<String, dynamic> args = const {},
}) {
  final concatenated = '$baseUrl/$endpointUrl';
  final withoutDoubleSlashes = replaceDoubleSlashes(concatenated);

  String withArgs = withoutDoubleSlashes;

  // `z` and `y` are expected query params from the RA API.
  // Authentication is handled purely by query params.
  final queryParamValues = {
    'z': authObject.userName,
    'y': authObject.webApiKey,
  };

  for (final entry in args.entries) {
    final argKey = entry.key;
    final argValue = entry.value;

    // "abc.com/some-route/:foo/some-path" & {"foo": 4} --> "abc.com/some-route/4/some-path"
    if (withArgs.contains(':$argKey')) {
      withArgs = withArgs.replaceFirst(':$argKey', argValue.toString());
    } else if (argValue != null) {
      queryParamValues[argKey] = argValue.toString();
    }
  }

  final queryString = MapToQueryString(queryParamValues).toString();
  return '$withArgs?$queryString';
}

String replaceDoubleSlashes(String input) {
  List<String> parts = input.split('://');
  String scheme = parts[0];
  String rest = parts[1].replaceAll(RegExp(r'/+'), '/');
  return '$scheme://$rest';
}

class MapToQueryString {
  final Map<String, String> map;
  MapToQueryString(this.map);

  @override
  String toString() {
    final pairs = map.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}');
    return pairs.join('&');
  }
}
