import 'package:flutter/material.dart';
import 'package:jk_pixel_ui/jk_pixel_ui.dart';

// Full-width header region for the quest encounter flow (combat, chest
// encounters, and their loot pages) — two stacked bars sharing the
// surface family CombatVitalsAndSkillsCard/NavBar already use: a plain
// filler (surfaceNoTopNoBottom, matching NavBar's own texture) covering
// what used to be BackgroundPage's own unstyled top padding — the scenic
// encounter background image showed through there before, not matching
// the bar below it — then the "Encounter X / Y" bar itself (surfaceNoTop
// — cap on the bottom edge since nothing sits below it to cap against,
// flat top since the filler bar above it already continues seamlessly
// into it). Used to be a centered, primary-colored QvButton pill; per
// feedback, the whole header region now reads as one themed bar instead
// of a floating pill, matching the bottom vitals section's own
// full-width treatment.
class QvQuestEncounterHeader extends StatelessWidget {
  const QvQuestEncounterHeader({
    super.key,
    required this.darkened,
    required this.curEncounterNum,
    required this.numEncountersCurFloor,
    this.capBottom = true,
  });

  final bool darkened;
  final int curEncounterNum;
  final int numEncountersCurFloor;

  // False only while CombatPage's own action-button bar (Flee/Potions/Bag,
  // see combat_page.dart's _CombatActionBar) is about to render directly
  // below this with no gap — that bar carries the actual cap/bottom
  // border instead, so this bar renders flat (surfaceNoTopNoBottom) to
  // keep the whole region reading as one continuous background rather
  // than showing two caps stacked with a seam between them. Every other
  // caller (chest encounters, both loot pages) has nothing capped
  // following it, so defaults to true — same surfaceNoTop cap this
  // always had.
  final bool capBottom;

  // Matches BackgroundPage's old EdgeInsets.only(top: 60) exactly — see
  // this class's own doc comment. QuestEncounterView falls back to a
  // plain SizedBox(height: topFillerHeight) on states that don't show
  // this header at all, so removing BackgroundPage's own padding didn't
  // shift those screens' content.
  static const double topFillerHeight = 60;
  static const double _barHeight = 40;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final region = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        QvBackground(
          type: QvBackgroundType.surfaceNoTopNoBottom,
          width: double.infinity,
          height: topFillerHeight,
          child: const SizedBox.shrink(),
        ),
        QvBackground(
          type: capBottom
              ? QvBackgroundType.surfaceNoTop
              : QvBackgroundType.surfaceNoTopNoBottom,
          width: double.infinity,
          height: _barHeight,
          child: Center(
            child: Text(
              'Encounter $curEncounterNum / $numEncountersCurFloor',
              style:
                  QvTextStyles.overlay.copyWith(color: colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
    // QvButton's own darkened effect (a translucent black overlay via
    // ColorFilter) — replicated here directly since QvBackground doesn't
    // take a darkened param itself.
    if (!darkened) return region;
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
          Colors.black.withValues(alpha: 0.5), BlendMode.srcATop),
      child: region,
    );
  }
}
