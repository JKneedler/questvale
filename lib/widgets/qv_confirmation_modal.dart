import 'package:flutter/material.dart';
import 'package:questvale/widgets/qv_button.dart';
import 'package:questvale/widgets/qv_metal_corner_border.dart';
import 'package:questvale/widgets/qv_text_styles.dart';

/// Generic destructive-action confirmation dialog, matching
/// QuestFleeConfirmationModal's look but parameterized for reuse (e.g. the
/// Settings page's admin actions).
class QvConfirmationModal extends StatelessWidget {
  final String title;
  final String description;
  final String confirmLabel;
  final Future<void> Function() onConfirm;

  const QvConfirmationModal({
    super.key,
    required this.title,
    required this.description,
    required this.confirmLabel,
    required this.onConfirm,
  });

  static Future<void> showModal(
    BuildContext context, {
    required String title,
    required String description,
    required String confirmLabel,
    required Future<void> Function() onConfirm,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => QvConfirmationModal(
        title: title,
        description: description,
        confirmLabel: confirmLabel,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: SizedBox(
        width: 360,
        height: 280,
        child: QvMetalCornerBorder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: SizedBox(
                    height: 54,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        style: QvTextStyles.heading,
                      ),
                    ),
                  )),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: SizedBox(
                      width: 20,
                      height: 40,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          'x',
                          style: QvTextStyles.display.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                height: 2,
                width: MediaQuery.of(context).size.width * 0.7,
                color: colorScheme.secondary,
              ),
              SizedBox(height: 10),
              Expanded(
                child: Text(
                  description,
                  style: QvTextStyles.note.copyWith(color: colorScheme.onSurface),
                  textAlign: TextAlign.center,
                ),
              ),
              QvButton(
                onTap: () async {
                  Navigator.pop(context);
                  await onConfirm();
                },
                width: 200,
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                buttonColor: ButtonColor.primary,
                child: Center(
                  child: Text(
                    confirmLabel,
                    style: QvTextStyles.overlay.copyWith(color: colorScheme.secondary),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
