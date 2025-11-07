import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/town_tab/town/town_cubit.dart';
import 'package:questvale/cubits/town_tab/town/town_state.dart';
import 'package:questvale/widgets/qv_button.dart';

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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            width: 60,
            height: 40,
            child: QvButton(
                darkened: darkened,
                onTap: () => context
                    .read<TownCubit>()
                    .setCurrentLocation(TownLocation.townSquare),
                child: Center(
                  child: Text('<',
                      style: TextStyle(
                          color: colorScheme.secondary,
                          fontSize: 26,
                          height: 1)),
                )),
          ),
          QvButton(
            darkened: darkened,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Encounter $curEncounterNum / $numEncountersCurFloor',
                  style: TextStyle(color: colorScheme.secondary, fontSize: 26),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(width: 60),
        ],
      ),
    );
  }
}
