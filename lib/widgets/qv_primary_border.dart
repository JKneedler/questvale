import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/theme/theme_cubit.dart';
import 'package:questvale/helpers/constants.dart';

class QvPrimaryBorder extends StatelessWidget {
  final Widget child;
  final double widthFactor;
  final double heightFactor;
  final EdgeInsets padding;
  final Color? color;
  const QvPrimaryBorder({
    super.key,
    required this.child,
    this.widthFactor = .95,
    this.heightFactor = .95,
    this.padding = const EdgeInsets.all(6),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final themeId = context.watch<ThemeCubit>().state.theme.id;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: STANDARD_BORDER_MIN_SIZE.width,
        minHeight: STANDARD_BORDER_MIN_SIZE.height,
      ),
      child: Stack(
        children: [
          Center(
            child: FractionallySizedBox(
              widthFactor: widthFactor,
              heightFactor: heightFactor,
              child: Container(
                color: color ?? colorScheme.surface,
                padding: padding,
                child: child,
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                foregroundDecoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        'images/ui/borders/$themeId/border-primary.png'),
                    centerSlice: STANDARD_BORDER_SLICE,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.none,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
