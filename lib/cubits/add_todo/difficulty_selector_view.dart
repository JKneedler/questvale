import 'package:flutter/material.dart';

class DifficultyPage extends StatelessWidget {
  final Function(int) onDifficultySelected;

  const DifficultyPage({
    super.key,
    required this.onDifficultySelected,
  });

  static Future<void> showModal(
    BuildContext context, {
    required Function(int) onDifficultySelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DifficultyPage(
        onDifficultySelected: onDifficultySelected,
      ),
    );
  }

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
            child: Text(
              'Select Difficulty',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: 5,
            itemBuilder: (context, index) {
              final difficulty = index + 1;
              return ListTile(
                title: Text(
                  'Level $difficulty',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
                leading: Icon(
                  Icons.star,
                  color: colorScheme.primary,
                ),
                onTap: () {
                  onDifficultySelected(difficulty);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
