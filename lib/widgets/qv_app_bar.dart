import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/widgets/qv_inset_background.dart';

class QvAppBar extends StatelessWidget {
  const QvAppBar({
    super.key,
    this.title = 'Questvale',
    this.color,
    this.insetColor,
    this.includeBackButton = false,
    this.onBackButtonPressed,
    this.showAP = false,
  });

  final String title;
  final Color? color;
  final QvInsetBackgroundType? insetColor;
  final bool includeBackButton;
  final VoidCallback? onBackButtonPressed;
  final bool showAP;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(top: topPadding, left: 16, right: 16),
      height: 40 + topPadding,
      color: color ?? colorScheme.surface,
      child: Row(
        children: [
          GestureDetector(
            onTap: onBackButtonPressed ?? () => Navigator.pop(context),
            child: SizedBox(
              width: 60,
              height: 40,
              child: onBackButtonPressed == null
                  ? SizedBox.shrink()
                  : SizedBox(
                      child: Text(
                        '<',
                        style: TextStyle(
                          fontSize: 26,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: TextStyle(color: colorScheme.onSurface, fontSize: 28),
              ),
            ),
          ),
          SizedBox(
            width: 60,
            height: 40,
            child: showAP
                ? QvInsetBackground(
                    type: insetColor ?? QvInsetBackgroundType.secondary,
                    child: Center(
                      child: Text(
                        '${context.read<PlayerCubit>().state.character?.attacksRemaining ?? 0}',
                        style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 28,
                            height: 1),
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
