import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jk_pixel_ui/jk_pixel_ui.dart';

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
    final themeId = context.watch<ThemeCubit>().state.theme.id;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
              'images/ui/backgrounds/$themeId/background-secondary.png'),
          centerSlice: STANDARD_BORDER_SLICE,
          fit: BoxFit.fill,
          filterQuality: FilterQuality.none,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: QvTextStyles.note
                .copyWith(color: colorScheme.primary, height: 1),
          ),
          Text(
            value,
            style: QvTextStyles.label.copyWith(color: valueColor, height: 1),
          ),
        ],
      ),
    );
  }
}
