import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:questvale/cubits/home/nav_cubit.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/cubits/home/player_state.dart';
import 'package:questvale/cubits/settings/settings_cubit.dart';
import 'package:questvale/cubits/settings/settings_state.dart';
import 'package:questvale/data/providers/game_data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:jk_pixel_ui/jk_pixel_ui.dart';

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
              navCubit: context.read<NavCubit>(),
              character: characterDataState.character!),
          child: BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, settingsState) {
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  QvAppBar(title: 'Settings'),
                  Expanded(
                    child: QvFadingScrollable(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            spacing: 10,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                      child: Text('Generate 10 loot',
                                          style: QvTextStyles.label.copyWith(
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
                                          style: QvTextStyles.label.copyWith(
                                              color: colorScheme.onPrimary)),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                      child: Text('Reset AP + daily AP to 0',
                                          style: QvTextStyles.label.copyWith(
                                              color: colorScheme.onSurface))),
                                  QvButton(
                                    width: 180,
                                    height: 50,
                                    buttonColor: ButtonColor.silver,
                                    onTap: () =>
                                        context.read<SettingsCubit>().resetAp(),
                                    child: Center(
                                      child: Text('Reset',
                                          style: QvTextStyles.label.copyWith(
                                              color: colorScheme.onPrimary)),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                      child: Text(
                                          'Level up (LVL ${characterDataState.character!.level})',
                                          style: QvTextStyles.label.copyWith(
                                              color: colorScheme.onSurface))),
                                  QvButton(
                                    width: 180,
                                    height: 50,
                                    buttonColor: ButtonColor.silver,
                                    onTap: () =>
                                        context.read<SettingsCubit>().levelUp(),
                                    child: Center(
                                      child: Text('Level Up',
                                          style: QvTextStyles.label.copyWith(
                                              color: colorScheme.onPrimary)),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                      child: Text(
                                          'Unlock next skill (${characterDataState.character!.skillPoints} pts)',
                                          style: QvTextStyles.label.copyWith(
                                              color: colorScheme.onSurface))),
                                  QvButton(
                                    width: 180,
                                    height: 50,
                                    buttonColor: ButtonColor.silver,
                                    onTap: () => context
                                        .read<SettingsCubit>()
                                        .unlockNextSkill(),
                                    child: Center(
                                      child: Text('Unlock',
                                          style: QvTextStyles.label.copyWith(
                                              color: colorScheme.onPrimary)),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                      child: Text('Upgrade first owned skill',
                                          style: QvTextStyles.label.copyWith(
                                              color: colorScheme.onSurface))),
                                  QvButton(
                                    width: 180,
                                    height: 50,
                                    buttonColor: ButtonColor.silver,
                                    onTap: () => context
                                        .read<SettingsCubit>()
                                        .upgradeFirstSkill(),
                                    child: Center(
                                      child: Text('Upgrade',
                                          style: QvTextStyles.label.copyWith(
                                              color: colorScheme.onPrimary)),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                      child: Text('Theme',
                                          style: QvTextStyles.label.copyWith(
                                              color: colorScheme.onSurface))),
                                  ThemePicker(),
                                ],
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text('Admin Actions',
                                    style: QvTextStyles.sectionTitle.copyWith(
                                        color: colorScheme.onSurface)),
                              ),
                              _AdminActionRow(
                                label: 'Delete all tasks/todos/habits',
                                buttonLabel: 'Delete',
                                onTap: () => QvConfirmationModal.showModal(
                                  context,
                                  title: 'Delete all todos?',
                                  description:
                                      'Deletes every task and habit, along '
                                      'with their reminders and tag '
                                      'assignments. Your tags themselves are '
                                      'kept. This can\'t be undone.',
                                  confirmLabel: 'Delete Todos',
                                  onConfirm: () => context
                                      .read<SettingsCubit>()
                                      .deleteAllTodos(),
                                ),
                              ),
                              _AdminActionRow(
                                label: 'Delete all tags',
                                buttonLabel: 'Delete',
                                onTap: () => QvConfirmationModal.showModal(
                                  context,
                                  title: 'Delete all tags?',
                                  description:
                                      'Removes every tag you\'ve created and '
                                      'untags all todos. This can\'t be undone.',
                                  confirmLabel: 'Delete Tags',
                                  onConfirm: () => context
                                      .read<SettingsCubit>()
                                      .deleteAllTags(),
                                ),
                              ),
                              _AdminActionRow(
                                label: 'Delete/cleanup all equipment',
                                buttonLabel: 'Delete',
                                onTap: () => QvConfirmationModal.showModal(
                                  context,
                                  title: 'Delete all equipment?',
                                  description:
                                      'Unequips and deletes every piece of '
                                      'gear you own, worn or not. This '
                                      'can\'t be undone.',
                                  confirmLabel: 'Delete Equipment',
                                  onConfirm: () => context
                                      .read<SettingsCubit>()
                                      .deleteAllEquipment(),
                                ),
                              ),
                              _AdminActionRow(
                                label: 'Cancel/delete quest',
                                buttonLabel: 'Cancel',
                                onTap: () => QvConfirmationModal.showModal(
                                  context,
                                  title: 'Cancel the current quest?',
                                  description:
                                      'Ends your active quest and deletes any '
                                      'progress in it. This can\'t be undone.',
                                  confirmLabel: 'Cancel Quest',
                                  onConfirm: () => context
                                      .read<SettingsCubit>()
                                      .cancelQuest(),
                                ),
                              ),
                              _AdminActionRow(
                                label: 'Reset all skill cooldowns',
                                buttonLabel: 'Reset',
                                onTap: () => QvConfirmationModal.showModal(
                                  context,
                                  title: 'Reset skill cooldowns?',
                                  description:
                                      'Clears every skill\'s cooldown so '
                                      'they\'re all ready to cast again '
                                      'immediately. This can\'t be undone.',
                                  confirmLabel: 'Reset Cooldowns',
                                  onConfirm: () => context
                                      .read<SettingsCubit>()
                                      .resetAllSkillCooldowns(),
                                ),
                              ),
                              _AdminActionRow(
                                label: 'Reset character to initial config',
                                buttonLabel: 'Reset',
                                onTap: () => QvConfirmationModal.showModal(
                                  context,
                                  title: 'Reset character?',
                                  description:
                                      'Resets level progress, gold, exp, AP, '
                                      'equipment, and skills back to a fresh '
                                      'start. Your todos and name are kept. '
                                      'This can\'t be undone.',
                                  confirmLabel: 'Reset Character',
                                  onConfirm: () => context
                                      .read<SettingsCubit>()
                                      .resetCharacter(),
                                ),
                              ),
                            ],
                          ),
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

class _AdminActionRow extends StatelessWidget {
  final String label;
  final String buttonLabel;
  final VoidCallback onTap;

  const _AdminActionRow({
    required this.label,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
            child: Text(label,
                style:
                    QvTextStyles.label.copyWith(color: colorScheme.onSurface))),
        QvButton(
          width: 180,
          height: 50,
          buttonColor: ButtonColor.silver,
          onTap: onTap,
          child: Center(
            child: Text(buttonLabel,
                style:
                    QvTextStyles.label.copyWith(color: colorScheme.onPrimary)),
          ),
        ),
      ],
    );
  }
}

class ThemePicker extends StatelessWidget {
  const ThemePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final activeTheme = context.watch<ThemeCubit>().state.theme;
    final settingsCubit = context.read<SettingsCubit>();
    return QvButton(
      width: 180,
      height: 50,
      buttonColor: ButtonColor.silver,
      onTap: () => showModalBottomSheet(
        context: context,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        builder: (context) => BlocProvider.value(
          value: settingsCubit,
          child: const ThemeSelectSheet(),
        ),
      ),
      child: Center(
        child: Text(activeTheme.displayName,
            style: QvTextStyles.note
                .copyWith(color: Theme.of(context).colorScheme.onPrimary)),
      ),
    );
  }
}

class ThemeSelectSheet extends StatelessWidget {
  const ThemeSelectSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final activeTheme = context.watch<ThemeCubit>().state.theme;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final theme in APP_THEMES.values)
            _ThemeRow(
              theme: theme,
              isSelected: theme.id == activeTheme.id,
              onTap: () {
                context.read<SettingsCubit>().setTheme(theme.id);
                Navigator.pop(context);
              },
            ),
        ],
      ),
    );
  }
}

class _ThemeRow extends StatelessWidget {
  final AppTheme theme;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeRow({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(Symbols.palette,
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                size: 20),
            const SizedBox(width: 14),
            Text(theme.displayName,
                style: QvTextStyles.note.copyWith(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface)),
          ],
        ),
      ),
    );
  }
}
