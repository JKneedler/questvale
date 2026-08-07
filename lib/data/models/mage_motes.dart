import 'package:equatable/equatable.dart';
import 'package:questvale/helpers/constants.dart';
import 'package:questvale/helpers/shared_enums.dart';

// Mage's resource, per the vault's Mage skill tree Mote system design.
// Separate from Character for the same reason CharacterStats is — a
// class-specific resource shouldn't bloat the core RPG-identity model or
// its migrations, and other classes (Warrior's Rage, Rogue's Focus) will
// each get their own analogous table rather than sharing this one, since
// their shapes don't actually overlap (a flat pool vs. a capped bag of two
// typed counters).
class MageMotes extends Equatable {
  static const mageMotesTableName = 'MageMotes';

  static const characterIdColumnName = 'characterId';
  static const fireMotesColumnName = 'fireMotes';
  static const iceMotesColumnName = 'iceMotes';

  static const createTableSQL = '''
    CREATE TABLE $mageMotesTableName(
      $characterIdColumnName VARCHAR PRIMARY KEY,
      $fireMotesColumnName INTEGER NOT NULL DEFAULT 0,
      $iceMotesColumnName INTEGER NOT NULL DEFAULT 0
    );
  ''';

  final String characterId;
  final int fireMotes;
  final int iceMotes;

  const MageMotes({
    required this.characterId,
    this.fireMotes = 0,
    this.iceMotes = 0,
  });

  int get totalMotes => fireMotes + iceMotes;

  int countOf(MoteElement element) {
    switch (element) {
      case MoteElement.fire:
        return fireMotes;
      case MoteElement.ice:
        return iceMotes;
    }
  }

  // Generates 1 mote of [element], deterministic per the design (no RNG).
  // Past the shared cap this is a silent no-op — the mote fizzles rather
  // than erroring or auto-consuming something to make room.
  MageMotes generate(MoteElement element) {
    if (totalMotes >= MOTE_CAP) return this;
    switch (element) {
      case MoteElement.fire:
        return copyWith(fireMotes: fireMotes + 1);
      case MoteElement.ice:
        return copyWith(iceMotes: iceMotes + 1);
    }
  }

  // Spends every currently-banked mote of [element]. Returns the new state
  // plus how many were consumed, so the calling skill can scale its effect
  // by that count — 0 consumed (state unchanged) is a valid, normal result
  // when the bank is already empty for that element.
  MoteConsumptionResult consumeAll(MoteElement element) {
    final consumed = countOf(element);
    if (consumed == 0) return MoteConsumptionResult(motes: this, consumed: 0);
    switch (element) {
      case MoteElement.fire:
        return MoteConsumptionResult(
            motes: copyWith(fireMotes: 0), consumed: consumed);
      case MoteElement.ice:
        return MoteConsumptionResult(
            motes: copyWith(iceMotes: 0), consumed: consumed);
    }
  }

  Map<String, Object?> toMap() {
    return {
      characterIdColumnName: characterId,
      fireMotesColumnName: fireMotes,
      iceMotesColumnName: iceMotes,
    };
  }

  MageMotes copyWith({
    int? fireMotes,
    int? iceMotes,
  }) {
    return MageMotes(
      characterId: characterId,
      fireMotes: fireMotes ?? this.fireMotes,
      iceMotes: iceMotes ?? this.iceMotes,
    );
  }

  @override
  List<Object?> get props => [characterId, fireMotes, iceMotes];

  @override
  String toString() =>
      'MageMotes(characterId: $characterId, fireMotes: $fireMotes, iceMotes: $iceMotes)';
}

class MoteConsumptionResult {
  final MageMotes motes;
  final int consumed;

  const MoteConsumptionResult({required this.motes, required this.consumed});
}
