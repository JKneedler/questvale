import 'package:flutter_test/flutter_test.dart';
import 'package:questvale/data/models/mage_motes.dart';
import 'package:questvale/helpers/constants.dart';
import 'package:questvale/helpers/shared_enums.dart';

void main() {
  const characterId = 'character-1';

  group('generate', () {
    test('adds 1 mote of the given element', () {
      const motes = MageMotes(characterId: characterId);
      final result = motes.generate(MoteElement.fire);
      expect(result.fireMotes, 1);
      expect(result.iceMotes, 0);
    });

    test('fire and ice generation track independently', () {
      const motes = MageMotes(characterId: characterId);
      final result =
          motes.generate(MoteElement.fire).generate(MoteElement.ice);
      expect(result.fireMotes, 1);
      expect(result.iceMotes, 1);
    });

    test('is a silent no-op once the shared cap is reached', () {
      var motes = const MageMotes(characterId: characterId);
      for (int i = 0; i < MOTE_CAP; i++) {
        motes = motes.generate(MoteElement.fire);
      }
      expect(motes.totalMotes, MOTE_CAP);

      final overflowed = motes.generate(MoteElement.ice);
      // The generated mote fizzles: no error, no auto-consumption of
      // existing motes to make room, state simply unchanged.
      expect(overflowed, motes);
      expect(overflowed.totalMotes, MOTE_CAP);
    });

    test('cap is shared across elements, not per-element', () {
      var motes = const MageMotes(characterId: characterId);
      motes = motes.generate(MoteElement.fire).generate(MoteElement.fire);
      // 2 fire + would-be 2 ice exceeds the shared cap of 3.
      motes = motes.generate(MoteElement.ice).generate(MoteElement.ice);
      expect(motes.totalMotes, MOTE_CAP);
      expect(motes.fireMotes, 2);
      expect(motes.iceMotes, 1);
    });
  });

  group('consumeAll', () {
    test('zeroes out the element and reports how many were consumed', () {
      const motes = MageMotes(characterId: characterId, fireMotes: 2);
      final result = motes.consumeAll(MoteElement.fire);
      expect(result.consumed, 2);
      expect(result.motes.fireMotes, 0);
    });

    test('consuming one element leaves the other untouched', () {
      const motes =
          MageMotes(characterId: characterId, fireMotes: 2, iceMotes: 1);
      final result = motes.consumeAll(MoteElement.fire);
      expect(result.motes.iceMotes, 1);
    });

    test('consuming an empty element is a valid 0-consumed no-op', () {
      const motes = MageMotes(characterId: characterId, iceMotes: 1);
      final result = motes.consumeAll(MoteElement.fire);
      expect(result.consumed, 0);
      expect(result.motes, motes);
    });
  });

  test('banked motes carry no derived value beyond the raw counts', () {
    // i.e. there's no idle/passive multiplier baked into the model itself —
    // totalMotes is a plain sum, nothing more.
    const motes =
        MageMotes(characterId: characterId, fireMotes: 1, iceMotes: 1);
    expect(motes.totalMotes, 2);
  });
}
