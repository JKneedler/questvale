import 'package:flutter/material.dart';

class TownPage extends StatelessWidget {
  const TownPage({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Town', style: TextStyle(color: colorScheme.onPrimary)),
        backgroundColor: colorScheme.primary,
      ),
      backgroundColor: colorScheme.surface,
    );
  }
}
