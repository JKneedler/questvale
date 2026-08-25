import 'package:flutter/material.dart';
import 'package:questvale/widgets/qv_button.dart';
import 'package:questvale/widgets/qv_text_styles.dart';

class QvQuestEncounterHeader extends StatelessWidget {
  const QvQuestEncounterHeader({
    super.key,
    required this.darkened,
    required this.curEncounterNum,
    required this.numEncountersCurFloor,
  });

  final bool darkened;
  final int curEncounterNum;
  final int numEncountersCurFloor;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          QvButton(
            darkened: darkened,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Encounter $curEncounterNum / $numEncountersCurFloor',
                  style: QvTextStyles.overlay.copyWith(color: colorScheme.secondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
