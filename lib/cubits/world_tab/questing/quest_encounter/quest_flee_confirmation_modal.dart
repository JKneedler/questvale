import 'package:flutter/material.dart';
import 'package:questvale/widgets/qv_button.dart';
import 'package:questvale/widgets/qv_metal_corner_border.dart';

class QuestFleeConfirmationModal extends StatelessWidget {
  final Future<void> Function() onFlee;
  const QuestFleeConfirmationModal({super.key, required this.onFlee});

  static Future<void> showModal(
      BuildContext context, Future<void> Function() onFlee) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return QuestFleeConfirmationModal(onFlee: onFlee);
      },
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
                        'Would you like to flee?',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w500,
                        ),
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
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w500,
                          ),
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
                  'Fleeing will end the current quest and return you fully back to town. You will lose any progress you have made in this quest but will receive any loot you have collected.',
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              QvButton(
                onTap: () async {
                  Navigator.pop(context);
                  await onFlee();
                },
                width: 200,
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                buttonColor: ButtonColor.primary,
                child: Center(
                  child: Text(
                    'Yes, Flee',
                    style:
                        TextStyle(fontSize: 26, color: colorScheme.secondary),
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
