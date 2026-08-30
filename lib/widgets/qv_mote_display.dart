import 'package:flutter/material.dart';
import 'package:questvale/data/models/mage_motes.dart';
import 'package:questvale/helpers/constants.dart';
import 'package:questvale/helpers/shared_enums.dart';
import 'package:questvale/widgets/qv_bar.dart';
import 'package:questvale/widgets/qv_text_styles.dart';

// Mage's resource display: MOTE_CAP discrete pip slots rather than a
// fraction-fill bar (QvBar/QvResourceBar) used directly, since Motes are a
// small capped count of two typed items, not a pool that drains/refills
// continuously. Each pip is still a real QvBar underneath (currentValue 0
// or 1 against maxValue 1) — per feedback, this should look like the
// health bar (same inset background peeking through an empty pip, same
// bordered/beveled bar image filling a full one), just recolored per mote
// element and split into MOTE_CAP discrete stretched segments instead of
// one continuous fraction. Pip fill order (Fire slots first, then Ice) is
// just a stable, deterministic way to lay out two counts against one
// shared cap; it carries no game-logic meaning of its own.
class QvMoteDisplay extends StatelessWidget {
  const QvMoteDisplay({
    super.key,
    required this.motes,
    this.pipHeight = 20,
  });

  final MageMotes motes;
  final double pipHeight;

  static const double _pipSpacing = 4;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'MOTES',
              style:
                  QvTextStyles.sectionHeader.copyWith(color: MOTE_LABEL_COLOR),
            ),
            Text(
              '${motes.totalMotes} / $MOTE_CAP',
              style:
                  QvTextStyles.sectionHeader.copyWith(color: MOTE_LABEL_COLOR),
            ),
          ],
        ),
        const SizedBox(height: 2),
        SizedBox(
          height: pipHeight,
          child: Row(
            spacing: _pipSpacing,
            children: [
              for (int i = 0; i < MOTE_CAP; i++)
                Expanded(
                  child:
                      _MotePip(height: pipHeight, element: _elementForPip(i)),
                ),
            ],
          ),
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

// A single mote slot as a QvBar with only two states — fully filled
// (currentValue: 1, maxValue: 1) or fully empty (currentValue: 0) — rather
// than a genuine fraction. An empty pip's resource choice is irrelevant
// (QvBar renders zero-width fill at fraction 0, leaving just the shared
// inset background visible, same as an empty stretch of the health bar).
class _MotePip extends StatelessWidget {
  const _MotePip({required this.height, required this.element});

  final double height;
  final MoteElement? element;

  @override
  Widget build(BuildContext context) {
    return QvBar(
      currentValue: element == null ? 0 : 1,
      maxValue: 1,
      resource:
          element == MoteElement.ice ? QvBarResource.ice : QvBarResource.fire,
      size: QvBarSize.mini,
      height: height,
      child: const SizedBox.shrink(),
    );
  }
}
