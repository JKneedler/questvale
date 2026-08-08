import 'package:equatable/equatable.dart';
import 'package:questvale/helpers/shared_enums.dart';

// A status effect applied to a player or an enemy — see the vault's Status
// Effects note. "Single shared instance per (owner, effect)" per that
// note's Burn section (no parallel independent stacks), so (ownerId,
// effectType) is the natural primary key rather than a synthetic id: a
// second Firebolt landing while Burn is already active merges into this
// same row (see StatusEffectService.mergeBurnApplication) instead of
// creating a second one.
//
// Deliberately holds only "how much" (stacks, magnitude) — "how long"/
// "when it next does something" lives entirely on the ScheduledTimer that
// rides alongside it (kind: statusEffectTick for Burn, statusEffectExpiry
// for everything else so far), per the vault's Time-Based Scheduling
// Engine note. There's no durationMs/expiresAt column here on purpose.
class StatusEffectInstance extends Equatable {
  static const statusEffectInstanceTableName = 'StatusEffectInstances';

  static const ownerIdColumnName = 'ownerId';
  static const effectTypeColumnName = 'effectType';
  static const stacksColumnName = 'stacks';
  static const magnitudeColumnName = 'magnitude';

  static const createTableSQL = '''
    CREATE TABLE $statusEffectInstanceTableName (
      $ownerIdColumnName VARCHAR NOT NULL,
      $effectTypeColumnName INTEGER NOT NULL,
      $stacksColumnName INTEGER NOT NULL DEFAULT 0,
      $magnitudeColumnName REAL NOT NULL DEFAULT 0,
      PRIMARY KEY ($ownerIdColumnName, $effectTypeColumnName)
    );
  ''';

  final String ownerId;
  final StatusEffectType effectType;
  final int stacks;
  // Effect-specific meaning: for Burn, the flat damage dealt per stack per
  // tick, snapshotted from the caster's attack power at application time
  // (not re-evaluated against live stats at tick time — see
  // StatusEffectService.applyBurn). For Slow, the rate multiplier applied
  // to the target's timer (0.5) — informational/for future display and
  // future multi-modifier strength comparisons; the rate change itself is
  // applied directly to the affected timer when Slow is (un)applied, not
  // read back from here. For Shield, the remaining absorb amount in flat
  // HP — read back and decremented every time damage is absorbed (see
  // StatusEffectService.absorbDamage), unlike Slow/Burn's magnitude which
  // only ever changes on (re)application.
  final double magnitude;

  const StatusEffectInstance({
    required this.ownerId,
    required this.effectType,
    required this.stacks,
    required this.magnitude,
  });

  Map<String, Object?> toMap() {
    return {
      ownerIdColumnName: ownerId,
      effectTypeColumnName: effectType.index,
      stacksColumnName: stacks,
      magnitudeColumnName: magnitude,
    };
  }

  StatusEffectInstance copyWith({
    int? stacks,
    double? magnitude,
  }) {
    return StatusEffectInstance(
      ownerId: ownerId,
      effectType: effectType,
      stacks: stacks ?? this.stacks,
      magnitude: magnitude ?? this.magnitude,
    );
  }

  @override
  List<Object?> get props => [ownerId, effectType, stacks, magnitude];

  @override
  String toString() =>
      'StatusEffectInstance(ownerId: $ownerId, effectType: $effectType, stacks: $stacks, magnitude: $magnitude)';
}
