import 'package:flutter/material.dart';
import 'package:jk_pixel_ui/jk_pixel_ui.dart';

class QuestBagInventoryModal extends StatelessWidget {
  const QuestBagInventoryModal({super.key});

  static Future<void> showModal(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return QuestBagInventoryModal();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 360,
        height: 500,
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
                        'Quest Bag Contents',
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
                          style: QvTextStyles.display
                              .copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
