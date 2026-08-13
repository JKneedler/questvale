import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/world_tab/town/quest_board/gear_up/equipment_gear_up/equipment_gear_up_page.dart';
import 'package:questvale/cubits/world_tab/town/quest_board/gear_up/gear_up_cubit.dart';
import 'package:questvale/cubits/world_tab/town/quest_board/gear_up/gear_up_state.dart';
import 'package:questvale/cubits/world_tab/town/quest_board/gear_up/skills_gear_up/skills_gear_up_page.dart';
import 'package:questvale/cubits/world_tab/town/quest_board/quest_board_cubit.dart';
import 'package:questvale/widgets/qv_button.dart';
import 'package:questvale/widgets/qv_inset_background.dart';

class GearUpPage extends StatelessWidget {
  const GearUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GearUpCubit>(
      create: (context) => GearUpCubit(),
      child: GearUpView(),
    );
  }
}

class GearUpView extends StatelessWidget {
  const GearUpView({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return BlocBuilder<GearUpCubit, GearUpState>(
        builder: (context, gearUpState) {
      // Renders inside the Quest Board TownVisitSheet's non-scrollable body
      // slot, alongside SelectQuestPage (see QuestBoardView) — the sheet's
      // own arrival header already says "Quest Board", so this only needs
      // a lightweight in-content link back to the zone list, not a full
      // Scaffold/AppBar of its own.
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: GestureDetector(
              onTap: () =>
                  context.read<QuestBoardCubit>().onGoBackWhileGearingUp(),
              behavior: HitTestBehavior.translucent,
              child: Row(
                children: [
                  Text('<',
                      style: TextStyle(
                          fontSize: 20, color: colorScheme.onSurface)),
                  const SizedBox(width: 6),
                  Text('Back to Zones',
                      style: TextStyle(
                          fontSize: 16, color: colorScheme.onSurface)),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Column(
                spacing: 6,
                children: [
                  QvInsetBackground(
                    width: double.infinity,
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GearUpTab(
                          title: 'Equipment',
                          selected: gearUpState.gearTabIndex == 0,
                          onTap: () => context
                              .read<GearUpCubit>()
                              .onGearTabIndexSelected(0),
                        ),
                        GearUpTab(
                          title: 'Skills',
                          selected: gearUpState.gearTabIndex == 1,
                          onTap: () => context
                              .read<GearUpCubit>()
                              .onGearTabIndexSelected(1),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: QvInsetBackground(
                      width: double.infinity,
                      child: Column(
                        children: [
                          if (gearUpState.gearTabIndex == 0)
                            EquipmentGearUpPage(),
                          if (gearUpState.gearTabIndex == 1)
                            SkillsGearUpPage(),
                        ],
                      ),
                    ),
                  ),
                  QvButton(
                    width: double.infinity,
                    height: 60,
                    buttonColor: ButtonColor.primary,
                    onTap: () =>
                        context.read<QuestBoardCubit>().onBeginQuest(context),
                    child: Center(
                      child: Text(
                        'Begin Quest',
                        style: TextStyle(
                            fontSize: 30, color: colorScheme.onPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      );
    });
  }
}

class GearUpTab extends StatelessWidget {
  const GearUpTab({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    if (!selected) {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.translucent,
          child: Center(
            child: Text(
              title,
              style: TextStyle(fontSize: 24, color: colorScheme.primary),
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: QvButton(
        width: double.infinity,
        buttonColor: ButtonColor.primary,
        child: Center(
          child: Text(
            title,
            style: TextStyle(fontSize: 24, color: colorScheme.onPrimary),
          ),
        ),
      ),
    );
  }
}
