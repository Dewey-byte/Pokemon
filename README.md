# Pokemon

A Flutter Pokédex that looks up Pokémon from the public [Pokémon API](https://pokeapi.co/).
Type a name (for example `pikachu`) and the app shows its name, ID, height, weight,
abilities, types, and sprite.

## How it works

- `lib/pokemon_service.dart`: `fetchPokemon(name)` sends a `GET` request to
  `https://pokeapi.co/api/v2/pokemon/{name}` with the `http` package and decodes the
  response with `dart:convert`.
- `lib/poke.dart`: the `Pokemon` data model from the previous lesson. It turns the
  decoded JSON map into a Dart object.
- `lib/main.dart`: the search screen and the detail screen.

## Handling the result of a request

**Successful request (200 OK).** The response body is decoded with `jsonDecode()` and
converted into a `Pokemon` with `Pokemon.fromJson()`. The app then opens the detail screen.

**Unsuccessful response.** The app checks the status code before reading the body.
- `404 Not Found` shows: *No Pokémon named "…" was found.*
- Any other non-200 code shows a server error message with the code.

The body is never treated as Pokémon data in these cases.

**Invalid data.** If the body is not valid JSON, or a required field is missing or has
the wrong type, the app shows: *The server sent data the app could not read.*

**Network failure.** If the device is offline or the server can't be reached (no HTTP
response at all), or the request takes more than 10 seconds, the app tells the user to
check their connection and try again. Pressing **Search** again retries the request.

**While waiting.** A loading indicator is shown and the Search button is disabled, so the
user can't send several requests at once and get confusing results.

## Offline strategy (proposed, not implemented)

Pokémon data rarely changes, so it is a good fit for a local cache:

1. After every successful lookup, save the raw JSON locally (for example with
   `shared_preferences` or a small SQLite database), keyed by Pokémon name, together with
   the time it was saved.
2. When a lookup fails because of a **network error**, check the cache. If the Pokémon is
   there, show it with a note like *"Offline: showing data saved on 30 Oct 2026"* and a
   retry button.
3. When the connection is back, the next successful request replaces the cached copy.
4. A **404** is not a network problem, so the app should not fall back to the cache for it.
   It should keep showing "not found".

Sprites could be cached the same way (for example with `cached_network_image`) so the
image also appears offline.
