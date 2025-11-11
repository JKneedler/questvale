import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/cubits/home/player_state.dart';
import 'package:questvale/cubits/settings/settings_cubit.dart';
import 'package:questvale/cubits/settings/settings_state.dart';
import 'package:questvale/widgets/qv_app_bar.dart';
import 'package:questvale/widgets/qv_button.dart';
import 'package:questvale/widgets/qv_inset_background.dart';
import 'package:sqflite/sqflite.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: BlocBuilder<PlayerCubit, PlayerState>(
          builder: (context, characterDataState) {
        return BlocProvider<SettingsCubit>(
          create: (context) => SettingsCubit(
              db: context.read<Database>(),
              character: characterDataState.character!),
          child: BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, settingsState) {
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  QvAppBar(title: 'Settings'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      spacing: 10,
                      children: [
                        InfoSlice(
                          title: 'Quests',
                          count: settingsState.questsNum,
                          onTap: settingsState.questsNum > 0
                              ? () => context
                                  .read<SettingsCubit>()
                                  .deleteTableContents(settingsState.tableInfos
                                      .firstWhere((tableInfo) =>
                                          tableInfo.tableType ==
                                          TableType.quests))
                              : () => {},
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: Text('Generate 10 loot',
                                    style: TextStyle(fontSize: 20))),
                            QvButton(
                              width: 180,
                              height: 50,
                              buttonColor: ButtonColor.silver,
                              onTap: () =>
                                  context.read<SettingsCubit>().generateLoot(),
                              child: Center(
                                child: Text('Generate',
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: colorScheme.onPrimary)),
                              ),
                            ),
                          ],
                        ),
                        QvInsetBackground(
                          width: double.infinity,
                          height: 430,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                for (var tableInfo in settingsState.tableInfos)
                                  TableInfoSlice(tableInfo: tableInfo),
                              ],
                            ),
                          ),
                        ),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      }),
    );
  }
}

class TableInfoSlice extends StatelessWidget {
  final TableInfo tableInfo;
  const TableInfoSlice({super.key, required this.tableInfo});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 50,
      child: Row(
        spacing: 10,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Text(tableInfo.tableType.name,
                  style: TextStyle(fontSize: 16))),
          SizedBox(
              width: 40,
              child: Text(tableInfo.numRows.toString(),
                  style: TextStyle(fontSize: 20))),
          QvButton(
            height: 40,
            width: tableInfo.isDeletable ? 60 : 130,
            buttonColor: ButtonColor.silver,
            onTap: () {
              context
                  .read<SettingsCubit>()
                  .logTableContents(tableInfo.tableType);
            },
            child: Center(
              child: Text('Log',
                  style: TextStyle(color: colorScheme.onPrimary, fontSize: 18)),
            ),
          ),
          tableInfo.isDeletable
              ? QvButton(
                  height: 40,
                  width: 80,
                  buttonColor: ButtonColor.silver,
                  onTap: () {
                    context
                        .read<SettingsCubit>()
                        .deleteTableContents(tableInfo);
                  },
                  child: Center(
                    child: Text('Delete',
                        style: TextStyle(
                            color: colorScheme.onPrimary, fontSize: 18)),
                  ),
                )
              : SizedBox.shrink(),
        ],
      ),
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
            width: 120, child: Text(title, style: TextStyle(fontSize: 20))),
        SizedBox(
            width: 80,
            child: Text(count.toString(), style: TextStyle(fontSize: 20))),
        Expanded(
          child: QvButton(
            buttonColor: ButtonColor.silver,
            onTap: onTap,
            height: 50,
            width: double.infinity,
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
