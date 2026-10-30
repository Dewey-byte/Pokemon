import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'poke.dart';

/// Thrown when a lookup fails. [message] is safe to show to the user.
class PokemonLookupException implements Exception {
  final String message;

  const PokemonLookupException(this.message);

  @override
  String toString() => message;
}

/// Sends a GET request to https://pokeapi.co/api/v2/pokemon/{name}
/// and returns the decoded [Pokemon].
///
/// Throws [PokemonLookupException] for network errors, unsuccessful
/// HTTP responses, and response data that cannot be read.
Future<Pokemon> fetchPokemon(String name) async {
  final query = name.trim().toLowerCase();
  final url = Uri(
    scheme: 'https',
    host: 'pokeapi.co',
    pathSegments: ['api', 'v2', 'pokemon', query],
  );

  // 1. Network errors: no HTTP response at all.
  final http.Response response;
  try {
    response = await http.get(url).timeout(const Duration(seconds: 10));
  } on TimeoutException {
    throw const PokemonLookupException(
      'The request timed out. Check your connection and try again.',
    );
  } on http.ClientException {
    throw const PokemonLookupException(
      'Could not reach the Pokémon service. '
      'Check your internet connection and try again.',
    );
  }

  // 2. HTTP errors: the server answered, but not with success.
  if (response.statusCode == 404) {
    throw PokemonLookupException('No Pokémon named "$query" was found.');
  }
  if (response.statusCode != 200) {
    throw PokemonLookupException(
      'The server returned an error (${response.statusCode}). '
      'Please try again later.',
    );
  }

  // 3. Data errors: invalid JSON, or fields missing / of the wrong type.
  try {
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Pokemon.fromJson(data);
  } catch (_) {
    throw const PokemonLookupException(
      'The server sent data the app could not read.',
    );
  }
}
