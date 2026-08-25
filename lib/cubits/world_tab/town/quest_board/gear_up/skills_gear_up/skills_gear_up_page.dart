import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/cubits/world_tab/town/quest_board/gear_up/skills_gear_up/skills_gear_up_cubit.dart';
import 'package:questvale/cubits/world_tab/town/quest_board/gear_up/skills_gear_up/skills_gear_up_state.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/character_skill.dart';
import 'package:questvale/data/providers/game_data.dart';
import 'package:questvale/data/providers/game_data_models/skill_data.dart';
import 'package:questvale/helpers/constants.dart';
import 'package:questvale/services/skill_progression_service.dart';
import 'package:questvale/widgets/qv_button.dart';
import 'package:questvale/widgets/qv_confirmation_modal.dart';
import 'package:questvale/widgets/qv_fading_scrollable.dart';
import 'package:questvale/widgets/qv_card_border.dart';
import 'package:questvale/widgets/qv_skill_button.dart';
import 'package:questvale/widgets/qv_text_styles.dart';
import 'package:sqflite/sqflite.dart';

String _percentText(double value) => '${(value * 100).round()}%';

String _capitalize(String value) =>
    value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';

// SkillData.cooldown is in fractional hours (e.g. 0.5 for Firebolt) — see
// its own doc comment. 0/null both mean "no cooldown" (Arcane Bolt).
String _cooldownText(double? cooldownHours) {
  final hours = cooldownHours ?? 0;
  if (hours <= 0) return 'None';
  final wholeHours = hours.floor();
  final minutes = ((hours % 1) * 60).round();
  if (wholeHours == 0) return '${minutes}m';
  if (minutes == 0) return '${wholeHours}h';
  return '${wholeHours}h ${minutes}m';
}

// Dart 2.19 (this project's SDK floor) doesn't have switch expressions —
// a plain if-chain over SkillUnlockBlockReason instead.
String _unlockLabel(SkillUnlockBlockReason? blockReason, SkillData skill) {
  if (blockReason == SkillUnlockBlockReason.tierLocked) {
    return 'Locked until Level ${SkillProgressionService.requiredLevelForTier(skill.tier)}';
  }
  if (blockReason == SkillUnlockBlockReason.insufficientPoints) {
    return 'Need a Skill Point';
  }
  if (blockReason == SkillUnlockBlockReason.alreadyOwned) {
    return 'Owned';
  }
  return 'Unlock — 1 pt';
}

class SkillsGearUpPage extends StatelessWidget {
  const SkillsGearUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final character = context.read<PlayerCubit>().state.character;
    if (character == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return BlocProvider<SkillsGearUpCubit>(
      create: (context) => SkillsGearUpCubit(
        db: context.read<Database>(),
        gameData: context.read<GameData>(),
        playerCubit: context.read<PlayerCubit>(),
        character: character,
      ),
      child: const SkillsGearUpView(),
    );
  }
}

class SkillsGearUpView extends StatelessWidget {
  const SkillsGearUpView({super.key});

  @override
  Widget build(BuildContext context) {
    final gameData = context.read<GameData>();
    return BlocBuilder<SkillsGearUpCubit, SkillsGearUpState>(
      builder: (context, state) {
        final classSkills = gameData.skills
            .where((skill) => skill.characterClass == state.character.characterClass)
            .toList();
        final tiers = classSkills.map((skill) => skill.tier).toSet().toList()..sort();
        return Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  'Skill Points: ${state.character.skillPoints}',
                  style: QvTextStyles.sectionTitle.copyWith(color: SKILL_POINTS_COLOR),
                ),
              ),
              Expanded(
                child: QvFadingScrollable(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    itemCount: tiers.length,
                    itemBuilder: (context, index) {
                      final tier = tiers[index];
                      final skillsInTier =
                          classSkills.where((skill) => skill.tier == tier).toList();
                      return _TierSection(tier: tier, skills: skillsInTier);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TierSection extends StatelessWidget {
  final int tier;
  final List<SkillData> skills;
  const _TierSection({required this.tier, required this.skills});

  @override
  Widget build(BuildContext context) {
    final character = context.watch<SkillsGearUpCubit>().state.character;
    final requiredLevel = SkillProgressionService.requiredLevelForTier(tier);
    final tierLocked = character.level < requiredLevel;

    final actives =
        skills.where((skill) => skill.type == SkillType.active).toList();
    final passives =
        skills.where((skill) => skill.type == SkillType.passive).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TierHeader(
            label: tierLocked
                ? 'Tier $tier — Locked until Level $requiredLevel'
                : 'Tier $tier',
            dimmed: tierLocked,
          ),
          const SizedBox(height: 6),
          ..._skillRows(actives, tierLocked),
          // Passives are always grouped together on their own row(s),
          // after every active row, regardless of how many of each a
          // tier has — see the Skills UI ticket's subtask 3.
          if (passives.isNotEmpty) ..._skillRows(passives, tierLocked),
        ],
      ),
    );
  }

  List<Widget> _skillRows(List<SkillData> group, bool tierLocked) {
    const columns = 3;
    final rows = <Widget>[];
    for (var i = 0; i < group.length; i += columns) {
      final rowSkills =
          group.sublist(i, i + columns > group.length ? group.length : i + columns);
      rows.add(_SkillRow(rowSkills: rowSkills, tierLocked: tierLocked));
    }
    return rows;
  }
}

// Centered label with divider lines extending to either side — same
// "---- Tier 1 ----" shape as combat_status_card.dart's _SectionHeader,
// just a size up (this screen has one section per tier instead of two
// fixed sections total, so a slightly bigger label reads better as the
// primary heading on the page).
class _TierHeader extends StatelessWidget {
  final String label;
  final bool dimmed;
  const _TierHeader({required this.label, this.dimmed = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = dimmed
        ? colorScheme.onSurface.withValues(alpha: 0.5)
        : colorScheme.primary;
    final dividerColor = dimmed
        ? colorScheme.onSurface.withValues(alpha: 0.15)
        : colorScheme.primary.withValues(alpha: 0.4);
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: dividerColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            label,
            style: QvTextStyles.emphasis.copyWith(color: textColor),
          ),
        ),
        Expanded(child: Container(height: 1, color: dividerColor)),
      ],
    );
  }
}

class _SkillRow extends StatelessWidget {
  final List<SkillData> rowSkills;
  final bool tierLocked;
  const _SkillRow({required this.rowSkills, required this.tierLocked});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SkillsGearUpCubit, SkillsGearUpState>(
      builder: (context, state) {
        final expandedSkill = rowSkills
            .firstWhereOrNull((skill) => skill.id == state.expandedSkillId);
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final skill in rowSkills)
                    _SkillGridIcon(
                        skill: skill,
                        tierLocked: tierLocked,
                        character: state.character),
                ],
              ),
              if (expandedSkill != null)
                _SkillDetailPanel(
                    skill: expandedSkill,
                    tierLocked: tierLocked,
                    character: state.character),
            ],
          ),
        );
      },
    );
  }
}

class _SkillGridIcon extends StatelessWidget {
  final SkillData skill;
  final bool tierLocked;
  final Character character;
  const _SkillGridIcon(
      {required this.skill, required this.tierLocked, required this.character});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final owned =
        character.skills.firstWhereOrNull((s) => s.skillId == skill.id);
    return Column(
      children: [
        QvSkillButton(
          skillIconPath: skill.iconPath,
          skillButtonColor: skill.buttonColor,
          darkened: tierLocked,
          onTap: () => context.read<SkillsGearUpCubit>().toggleExpanded(skill.id),
        ),
        SizedBox(
          height: 16,
          child: owned != null
              ? Text('Lv ${owned.level}',
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurface))
              : null,
        ),
      ],
    );
  }
}

class _SkillDetailPanel extends StatelessWidget {
  final SkillData skill;
  final bool tierLocked;
  final Character character;
  const _SkillDetailPanel({
    required this.skill,
    required this.tierLocked,
    required this.character,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cubit = context.read<SkillsGearUpCubit>();
    final owned =
        character.skills.firstWhereOrNull((s) => s.skillId == skill.id);
    final previewLevel = owned?.level ?? 1;

    final description = skill.type == SkillType.active
        ? cubit.skillService.getSkillById(skill.id, level: previewLevel).description
        : cubit.skillService
            .getPassiveSkillById(skill.id, level: previewLevel)
            .description;

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      // QvCardBorder, not QvMetalCornerBorder — this panel sits in a
      // ListView.builder item, an unbounded-height context.
      // QvMetalCornerBorder's FractionallySizedBox needs a bounded height
      // to size against and crashes here; QvCardBorder is built to size
      // off its child's own content in exactly this situation (see its
      // own doc comment).
      child: QvCardBorder(
        type: QvCardBorderType.primary,
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(skill.name,
                style: QvTextStyles.sectionTitle.copyWith(color: colorScheme.onSurface)),
            const SizedBox(height: 4),
            Text(description,
                style: QvTextStyles.body.copyWith(color: colorScheme.onSurface)),
            // AP cost/cooldown are only ever set on actives — skill.apCost
            // is null for every passive (see skills.json), so this line is
            // naturally omitted for them rather than needing its own
            // skill.type check.
            if (skill.apCost != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                    'AP Cost: ${skill.apCost} • Cooldown: ${_cooldownText(skill.cooldown)}',
                    style: QvTextStyles.caption
                        .copyWith(color: colorScheme.onSurface.withValues(alpha: 0.75))),
              ),
            const SizedBox(height: 8),
            ..._statLines(skill, previewLevel, owned != null)
                .map((line) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(line,
                          style: QvTextStyles.caption.copyWith(color: colorScheme.onSurface)),
                    )),
            const SizedBox(height: 8),
            _ActionButton(
                skill: skill, owned: owned, tierLocked: tierLocked, character: character),
          ],
        ),
      ),
    );
  }

  // One line per real effect component the skill declares, showing its
  // value at previewLevel — and, once owned, the value it would become at
  // the next level, so upgrading has a concrete "what this increases"
  // preview rather than just a level number. Reads SkillData's effect
  // components directly (via SkillEffectComponent.valueAtLevel and
  // StatModifierType.skillTierValue) rather than building a full
  // BaseActiveSkill/BasePassiveSkill instance, since not every kind maps
  // onto that class hierarchy the same way (a passive has no damage
  // effect, an active has no statModifier effect, etc).
  List<String> _statLines(SkillData skill, int currentLevel, bool owned) {
    final nextLevel = currentLevel + 1;
    final lines = <String>[];

    String line(String label, double curVal, double nextVal, {bool isPercent = true}) {
      final curText = isPercent ? _percentText(curVal) : curVal.round().toString();
      final nextText = isPercent ? _percentText(nextVal) : nextVal.round().toString();
      return owned ? '$label: $curText → $nextText' : '$label: $curText';
    }

    final damage = skill.damageEffect;
    if (damage != null) {
      lines.add(line('${damage.damageType?.name ?? 'Weapon Type'} Damage',
          damage.valueAtLevel(currentLevel), damage.valueAtLevel(nextLevel)));
    }
    final shield = skill.shieldEffect;
    if (shield != null) {
      lines.add(line('Shield (Max HP)', shield.valueAtLevel(currentLevel),
          shield.valueAtLevel(nextLevel)));
    }
    for (final chance in skill.statusEffectChances) {
      lines.add(line(
          '${_capitalize(chance.statusEffectType?.name ?? 'Status')} Chance',
          chance.valueAtLevel(currentLevel),
          chance.valueAtLevel(nextLevel)));
    }
    for (final mod in skill.statModifierEffects) {
      final type = mod.statModifierType;
      // Inert data (Mote Potency today) — no real StatModifierType means
      // nothing is actually consumed for it yet, so there's no honest
      // number to preview here.
      if (type == null) continue;
      lines.add(line(type.displayName, type.skillTierValue(currentLevel),
          type.skillTierValue(nextLevel),
          isPercent: type.isPercentage()));
    }
    return lines;
  }
}

class _ActionButton extends StatelessWidget {
  final SkillData skill;
  final CharacterSkill? owned;
  final bool tierLocked;
  final Character character;
  const _ActionButton({
    required this.skill,
    required this.owned,
    required this.tierLocked,
    required this.character,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cubit = context.read<SkillsGearUpCubit>();

    if (owned == null) {
      final blockReason = SkillProgressionService.checkUnlock(
        skill: skill,
        characterLevel: character.level,
        skillPoints: character.skillPoints,
        alreadyOwned: false,
      );
      final label = _unlockLabel(blockReason, skill);
      return QvButton(
        width: double.infinity,
        height: 40,
        buttonColor: ButtonColor.primary,
        darkened: blockReason != null,
        onTap: blockReason == null
            ? () => QvConfirmationModal.showModal(
                  context,
                  title: 'Unlock ${skill.name}?',
                  description:
                      'Spends 1 Skill Point to permanently unlock ${skill.name}. This can\'t be undone.',
                  confirmLabel: 'Unlock',
                  onConfirm: () => cubit.unlockSkill(skill.id),
                )
            : null,
        child: Center(
            child: Text(label, style: TextStyle(color: colorScheme.onPrimary))),
      );
    }

    final blockReason = SkillProgressionService.checkUpgrade(
        owned: true, skillPoints: character.skillPoints);
    final label = blockReason == null
        ? 'Upgrade to Lv ${owned!.level + 1} — 1 pt'
        : 'Need a Skill Point';
    return QvButton(
      width: double.infinity,
      height: 40,
      buttonColor: ButtonColor.primary,
      darkened: blockReason != null,
      onTap: blockReason == null
          ? () => QvConfirmationModal.showModal(
                context,
                title: 'Upgrade ${skill.name}?',
                description:
                    'Spends 1 Skill Point to upgrade ${skill.name} to level ${owned!.level + 1}. This can\'t be undone.',
                confirmLabel: 'Upgrade',
                onConfirm: () => cubit.upgradeSkill(skill.id),
              )
          : null,
      child:
          Center(child: Text(label, style: TextStyle(color: colorScheme.onPrimary))),
    );
  }
}
