import 'package:flutter/material.dart';

class SummarySlice extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;
  const SummarySlice(
      {super.key,
      required this.title,
      required this.value,
      required this.valueColor});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/ui/secondary-background-2x.png'),
          centerSlice: Rect.fromLTWH(16, 16, 32, 32),
          fit: BoxFit.fill,
          filterQuality: FilterQuality.none,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.primary,
              height: 1,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              color: valueColor,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
