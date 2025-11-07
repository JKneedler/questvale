import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/town_tab/questing/quest_floor_begin/quest_floor_begin_cubit.dart';
import 'package:questvale/cubits/town_tab/questing/quest_floor_begin/quest_floor_begin_state.dart';
import 'package:questvale/data/providers/game_data.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/data/repositories/quest_repository.dart';
import 'package:questvale/widgets/qv_blinking.dart';
import 'package:sqflite/sqflite.dart';

class QuestFloorBeginPage extends StatelessWidget {
  const QuestFloorBeginPage({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: GestureDetector(
        onTap: () => {
          Navigator.popUntil(context, (route) => route.isFirst),
        },
        child: BlocProvider<QuestFloorBeginCubit>(
          create: (context) => QuestFloorBeginCubit(
            CharacterRepository(db: context.read<Database>()),
            QuestRepository(db: context.read<Database>()),
          ),
          child: BlocBuilder<QuestFloorBeginCubit, QuestFloorBeginState>(
              builder: (context, state) {
            final questZones = context.read<GameData>().questZones;
            final zone =
                questZones.firstWhere((zone) => zone.id == state.quest!.zoneId);
            return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: state.quest != null
                  ? BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          'images/backgrounds/${zone.id}.png',
                        ),
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.none,
                      ),
                    )
                  : null,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    state.quest != null ? zone.name : '',
                    style: TextStyle(
                      color: colorScheme.secondary,
                      fontSize: 48,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 50),
                  Text(
                    state.quest != null ? 'Number of Encounters' : '',
                    style: TextStyle(
                      color: colorScheme.secondary,
                      fontSize: 28,
                    ),
                  ),
                  Container(
                      height: 2, width: 180, color: colorScheme.secondary),
                  Text(
                    state.quest != null
                        ? '${state.quest!.numEncountersCurFloor}'
                        : '',
                    style: TextStyle(
                      color: colorScheme.secondary,
                      fontSize: 36,
                    ),
                  ),
                  SizedBox(height: 200),
                  QvBlinking(
                    duration: Duration(milliseconds: 1200),
                    minOpacity: 0.5,
                    child: Text(
                      state.quest != null ? 'Tap anywhere to begin' : '',
                      style: TextStyle(
                          color: colorScheme.secondary.withValues(alpha: 0.5),
                          fontSize: 28),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
