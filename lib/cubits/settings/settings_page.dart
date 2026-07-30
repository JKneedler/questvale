import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/cubits/home/player_state.dart';
import 'package:questvale/cubits/settings/settings_cubit.dart';
import 'package:questvale/cubits/settings/settings_state.dart';
import 'package:questvale/cubits/theme/theme_cubit.dart';
import 'package:questvale/data/providers/game_data.dart';
import 'package:questvale/helpers/constants.dart';
import 'package:questvale/widgets/qv_app_bar.dart';
import 'package:questvale/widgets/qv_button.dart';
import 'package:questvale/widgets/qv_popup_menu.dart';
import 'package:questvale/widgets/qv_popup_menu_item.dart';
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
              gameData: context.read<GameData>(),
              playerCubit: context.read<PlayerCubit>(),
              themeCubit: context.read<ThemeCubit>(),
              character: characterDataState.character!),
          child: BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, settingsState) {
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  QvAppBar(title: 'Settings'),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
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
                                      .deleteTableContents(settingsState
                                          .tableInfos
                                          .firstWhere((tableInfo) =>
                                              tableInfo.tableType ==
                                              TableType.quests))
                                  : () => {},
                            ),
                            Row(
                              children: [
                                Expanded(
                                    child: Text('Generate 10 loot',
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: colorScheme.onSurface))),
                                QvButton(
                                  width: 180,
                                  height: 50,
                                  buttonColor: ButtonColor.silver,
                                  onTap: () => context
                                      .read<SettingsCubit>()
                                      .generateLoot(),
                                  child: Center(
                                    child: Text('Generate',
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: colorScheme.onPrimary)),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                    child: Text('Reset AP + daily AP to 0',
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: colorScheme.onSurface))),
                                QvButton(
                                  width: 180,
                                  height: 50,
                                  buttonColor: ButtonColor.silver,
                                  onTap: () =>
                                      context.read<SettingsCubit>().resetAp(),
                                  child: Center(
                                    child: Text('Reset',
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: colorScheme.onPrimary)),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                    child: Text('Theme',
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: colorScheme.onSurface))),
                                ThemePicker(),
                              ],
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text('DB Tables',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface)),
                            ),
                            Column(
                              children: [
                                for (var tableInfo in settingsState.tableInfos)
                                  TableInfoSlice(tableInfo: tableInfo),
                              ],
                            ),
                          ],
                        ),
                      ),
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
                  style:
                      TextStyle(fontSize: 16, color: colorScheme.onSurface))),
          SizedBox(
              width: 40,
              child: Text(tableInfo.numRows.toString(),
                  style:
                      TextStyle(fontSize: 20, color: colorScheme.onSurface))),
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
            width: 120,
            child: Text(title,
                style: TextStyle(fontSize: 20, color: colorScheme.onSurface))),
        SizedBox(
            width: 80,
            child: Text(count.toString(),
                style: TextStyle(fontSize: 20, color: colorScheme.onSurface))),
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

class ThemePicker extends StatelessWidget {
  ThemePicker({super.key});

  final MenuController menuController = MenuController();

  @override
  Widget build(BuildContext context) {
    final activeTheme = context.watch<ThemeCubit>().state.theme;
    return QVPopupMenu(
      menuController: menuController,
      offset: const Offset(0, -8),
      button: QvButton(
        width: 180,
        height: 50,
        buttonColor: ButtonColor.silver,
        child: Center(
          child: Text(activeTheme.displayName,
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onPrimary)),
        ),
      ),
      menuContents: [
        for (final theme in APP_THEMES.values)
          QvPopupMenuItem(
            text: theme.displayName,
            icon: Symbols.palette,
            iconColor: theme.id == activeTheme.id
                ? Theme.of(context).colorScheme.primary
                : null,
            textColor: theme.id == activeTheme.id
                ? Theme.of(context).colorScheme.primary
                : null,
            onPressed: () {
              menuController.close();
              context.read<SettingsCubit>().setTheme(theme.id);
            },
          ),
      ],
    );
  }
}
