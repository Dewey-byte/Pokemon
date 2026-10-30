class Ability {
  final String name;
  final int slot;
  final bool isHidden;

  Ability({required this.name, required this.slot, required this.isHidden});

  factory Ability.fromJson(Map<String, dynamic> json) {
    return Ability(
      name: json['ability']['name'] as String,
      slot: json['slot'] as int,
      isHidden: json['is_hidden'] as bool,
    );
  }
}

class Move {
  final String name;

  Move({required this.name});

  factory Move.fromJson(Map<String, dynamic> json) {
    return Move(name: json['move']['name'] as String);
  }
}

class Stat {
  final String name;
  final int baseStat;
  final int effort;

  Stat({required this.name, required this.baseStat, required this.effort});

  factory Stat.fromJson(Map<String, dynamic> json) {
    return Stat(
      name: json['stat']['name'] as String,
      baseStat: json['base_stat'] as int,
      effort: json['effort'] as int,
    );
  }
}

class Pokemon {
  final int id;
  final String name;
  final List<String> types;
  final int baseExperience;
  final int height;
  final int weight;
  final List<Ability> abilities;
  final List<String> heldItems;
  final List<Move> moves;
  final List<Stat> stats;
  final String spriteUrl;
  final String? cryUrl;

  Pokemon({
    required this.id,
    required this.name,
    required this.types,
    required this.baseExperience,
    required this.height,
    required this.weight,
    required this.abilities,
    required this.heldItems,
    required this.moves,
    required this.stats,
    required this.spriteUrl,
    this.cryUrl,
  });

  /// Primary (first) type, kept for convenience.
  String get type => types.isNotEmpty ? types.first : 'unknown';

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final sprites = json['sprites'] as Map<String, dynamic>? ?? {};
    final artwork = sprites['other']?['official-artwork']?['front_default'];

    return Pokemon(
      id: json['id'] as int,
      name: json['name'] as String,
      types: (json['types'] as List? ?? [])
          .map((t) => t['type']['name'] as String)
          .toList(),
      baseExperience: json['base_experience'] as int? ?? 0,
      height: json['height'] as int,
      weight: json['weight'] as int,
      abilities: (json['abilities'] as List? ?? [])
          .map((a) => Ability.fromJson(a as Map<String, dynamic>))
          .toList(),
      heldItems: (json['held_items'] as List? ?? [])
          .map((h) => h['item']['name'] as String)
          .toList(),
      moves: (json['moves'] as List? ?? [])
          .map((m) => Move.fromJson(m as Map<String, dynamic>))
          .toList(),
      stats: (json['stats'] as List? ?? [])
          .map((s) => Stat.fromJson(s as Map<String, dynamic>))
          .toList(),
      spriteUrl: (artwork ?? sprites['front_default'] ?? '') as String,
      cryUrl: json['cries']?['latest'] as String?,
    );
  }
}
