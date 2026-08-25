import 'package:flutter/material.dart';
import 'package:questvale/widgets/qv_inset_background.dart';
import 'package:questvale/widgets/qv_text_styles.dart';

class QvAppBarButton {
  final String button;
  final VoidCallback onTap;

  QvAppBarButton({required this.button, required this.onTap});
}

class QvAppBar extends StatelessWidget {
  const QvAppBar({
    super.key,
    this.title = 'Questvale',
    this.color,
    this.insetColor,
    this.onBackButtonPressed,
    this.trailingButton,
    this.leading,
  });

  final String title;
  final Color? color;
  final QvInsetBackgroundType? insetColor;
  final VoidCallback? onBackButtonPressed;
  final QvAppBarButton? trailingButton;
  final Widget? leading;

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
          if (leading != null)
            leading!
          else
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
                          style: QvTextStyles.overlay.copyWith(color: colorScheme.onSurface),
                          textAlign: TextAlign.center,
                        ),
                      ),
              ),
            ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: QvTextStyles.banner.copyWith(color: colorScheme.onSurface),
              ),
            ),
          ),
          GestureDetector(
            onTap: trailingButton?.onTap ?? () {},
            child: SizedBox(
              width: 60,
              height: 40,
              child: trailingButton == null
                  ? SizedBox.shrink()
                  : SizedBox(
                      child: Text(
                        trailingButton!.button,
                        style: QvTextStyles.overlay.copyWith(color: colorScheme.onSurface),
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
