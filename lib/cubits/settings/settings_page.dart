import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/character_data_cubit.dart';
import 'package:questvale/cubits/home/character_data_state.dart';
import 'package:questvale/cubits/settings/settings_cubit.dart';
import 'package:questvale/cubits/settings/settings_state.dart';
import 'package:questvale/widgets/qv_app_bar.dart';
import 'package:sqflite/sqflite.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: BlocBuilder<CharacterDataCubit, CharacterDataState>(
          builder: (context, characterDataState) {
        return BlocProvider<SettingsCubit>(
          create: (context) => SettingsCubit(
              db: context.read<Database>(),
              character: characterDataState.character!),
          child: BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, settingsState) {
            return Column(
              spacing: 10,
              children: [
                QVAppBar(title: 'Settings'),
                BlocListener<SettingsCubit, SettingsState>(
                  listenWhen: (prev, next) => prev.questsNum != next.questsNum,
                  listener: (context, settingsState) {
                    context.read<CharacterDataCubit>().updateQuest();
                  },
                  child: InfoSlice(
                    title: 'Quests',
                    count: settingsState.questsNum,
                    onTap: settingsState.questsNum > 0
                        ? () => context.read<SettingsCubit>().deleteQuests()
                        : () => {},
                  ),
                ),
                InfoSlice(
                  title: 'Encounters',
                  count: settingsState.encountersNum,
                  onTap: settingsState.encountersNum > 0
                      ? () => context.read<SettingsCubit>().deleteEncounters()
                      : () => {},
                ),
                InfoSlice(
                  title: 'Enemies',
                  count: settingsState.enemiesNum,
                  onTap: settingsState.enemiesNum > 0
                      ? () => context.read<SettingsCubit>().deleteEnemies()
                      : () => {},
                ),
              ],
            );
          }),
        );
      }),
      backgroundColor: colorScheme.surface,
    );
  }
}

class InfoSlice extends StatelessWidget {
  final String title;
  final int count;
  final Function() onTap;
  const InfoSlice(
      {super.key,
      required this.title,
      required this.count,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        SizedBox(
            width: 120, child: Text(title, style: TextStyle(fontSize: 20))),
        SizedBox(
            width: 80,
            child: Text(count.toString(), style: TextStyle(fontSize: 20))),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 200,
            height: 50,
            decoration: BoxDecoration(
              image: DecorationImage(
                image:
                    AssetImage('images/ui/buttons/white-button-filled-2x.png'),
                centerSlice: Rect.fromLTWH(16, 16, 32, 32),
                fit: BoxFit.fill,
                filterQuality: FilterQuality.none,
              ),
            ),
            child: Center(
              child: Text(count > 0 ? 'Delete all $title' : 'None to delete',
                  style: TextStyle(color: colorScheme.onPrimary, fontSize: 20)),
            ),
          ),
        ),
      ],
    );
  }
}
