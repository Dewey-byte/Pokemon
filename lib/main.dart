import 'package:flutter/material.dart';

import 'poke.dart';
import 'pokemon_service.dart';

void main() {
  runApp(const PokemonApp());
}

class PokemonApp extends StatelessWidget {
  const PokemonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokedex',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const PokemonSearchPage(),
    );
  }
}

/// Lets the user type a Pokémon name and looks it up on the Pokémon API.
class PokemonSearchPage extends StatefulWidget {
  const PokemonSearchPage({super.key});

  @override
  State<PokemonSearchPage> createState() => _PokemonSearchPageState();
}

class _PokemonSearchPageState extends State<PokemonSearchPage> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    // Ignore new submissions while a request is still running.
    if (_loading) return;

    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Enter a Pokémon name.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final pokemon = await fetchPokemon(name);
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PokemonDetailPage(pokemon: pokemon)),
      );
    } on PokemonLookupException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pokedex')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              decoration: const InputDecoration(
                labelText: 'Pokémon name',
                hintText: 'e.g. pikachu',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _loading ? null : _search,
              child: const Text('Search'),
            ),
            const SizedBox(height: 24),
            if (_loading) const Center(child: CircularProgressIndicator()),
            if (_error != null)
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
      ),
    );
  }
}

String titleCase(String s) => s
    .split('-')
    .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
    .join(' ');

Color typeColor(String type) {
  switch (type) {
    case 'electric':
      return Colors.orange;
    case 'bug':
      return Colors.lightGreen;
    case 'fire':
      return Colors.deepOrange;
    case 'water':
      return Colors.blue;
    case 'grass':
      return Colors.green;
    case 'poison':
      return Colors.purple;
    case 'normal':
      return Colors.grey;
    default:
      return Colors.blueGrey;
  }
}

class PokemonDetailPage extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonDetailPage({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const heading = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Text(
              'Pokedex Entry: #${pokemon.id.toString().padLeft(4, '0')}',
              style: heading,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Image.network(
              pokemon.spriteUrl,
              height: 180,
              width: 180,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 100),
            ),
          ),
          const SizedBox(height: 16),
          Center(child: Text(titleCase(pokemon.name))),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: pokemon.types
                .map((t) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: typeColor(t),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(titleCase(t),
                            style: const TextStyle(color: Colors.white)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text('Base experience: ${pokemon.baseExperience}',
                style: heading),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(children: [
                const Text('Height (m)', style: heading),
                const SizedBox(height: 4),
                Text('${pokemon.height / 10}'), // API sends decimetres
              ]),
              Column(children: [
                const Text('Weight (kg)', style: heading),
                const SizedBox(height: 4),
                Text('${pokemon.weight / 10}'), // API sends hectograms
              ]),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Abilities', style: heading),
          const SizedBox(height: 4),
          Wrap(
            spacing: 12,
            children: pokemon.abilities
                .map((a) => Text(a.isHidden
                    ? '${titleCase(a.name)} (Hidden)'
                    : titleCase(a.name)))
                .toList(),
          ),
          const SizedBox(height: 24),
          const Text('Held Items', style: heading),
          const SizedBox(height: 4),
          pokemon.heldItems.isEmpty
              ? const Text('None')
              : Wrap(
                  spacing: 12,
                  children:
                      pokemon.heldItems.map((i) => Text(titleCase(i))).toList(),
                ),
          const SizedBox(height: 24),
          const Text('Moves', style: heading),
          const SizedBox(height: 8),
          ...pokemon.moves.asMap().entries.map((e) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                color: scheme.primary.withOpacity(0.25),
                child: Row(
                  children: [
                    Text('#${e.key + 1}', style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 24),
                    Text(titleCase(e.value.name)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
