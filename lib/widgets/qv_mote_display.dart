import 'package:flutter/material.dart';
import 'package:questvale/data/models/mage_motes.dart';
import 'package:questvale/helpers/constants.dart';
import 'package:questvale/helpers/shared_enums.dart';

// Mage's resource display: MOTE_CAP discrete pip slots rather than a
// fraction-fill bar (QvBar/QvResourceBar), since Motes are a small capped
// count of two typed items, not a pool that drains/refills continuously.
// Purely presentational — pip fill order (Fire slots first, then Ice) is
// just a stable, deterministic way to lay out two counts against one
// shared cap; it carries no game-logic meaning of its own.
class QvMoteDisplay extends StatelessWidget {
  const QvMoteDisplay({
    super.key,
    required this.motes,
    this.pipSize = 18,
  });

  final MageMotes motes;
  final double pipSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'MOTES',
              style: TextStyle(
                color: MOTE_LABEL_COLOR,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${motes.totalMotes} / $MOTE_CAP',
              style: const TextStyle(
                color: MOTE_LABEL_COLOR,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < MOTE_CAP; i++) ...[
              if (i != 0) SizedBox(width: pipSize * 0.3),
              _MotePip(size: pipSize, element: _elementForPip(i)),
            ],
          ],
        ),
      ],
    );
  }

  // Fire fills first, then Ice, then the rest sit empty — an arbitrary but
  // stable ordering so the same bank state always draws the same pips.
  MoteElement? _elementForPip(int index) {
    if (index < motes.fireMotes) return MoteElement.fire;
    if (index < motes.fireMotes + motes.iceMotes) return MoteElement.ice;
    return null;
  }
}

class _MotePip extends StatelessWidget {
  const _MotePip({required this.size, required this.element});

  final double size;
  final MoteElement? element;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: element?.color ?? Colors.white.withValues(alpha: 0.15),
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
