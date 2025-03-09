import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:questvale/data/models/task.dart';

class DifficultySelectorView extends StatelessWidget {
  final void Function(DifficultyLevel) onDifficultySelected;

  const DifficultySelectorView({
    super.key,
    required this.onDifficultySelected,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surfaceContainerLow,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Symbols.trophy, color: colorScheme.onSurfaceVariant),
                SizedBox(width: 16),
                Text(
                  'Difficulty',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.onSurfaceVariant),
          ...DifficultyLevel.values.map((difficulty) => ListTile(
                leading: Icon(
                  Symbols.trophy,
                  color: difficulty.color,
                ),
                title: Text(difficulty.name),
                onTap: () {
                  onDifficultySelected(difficulty);
                  Navigator.pop(context);
                },
              )),
        ],
      ),
    );
  }
}

class DifficultyPage {
  static Future<void> showModal(
    BuildContext context, {
    required void Function(DifficultyLevel) onDifficultySelected,
  }) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => DifficultySelectorView(
        onDifficultySelected: onDifficultySelected,
      ),
    );
  }
}
