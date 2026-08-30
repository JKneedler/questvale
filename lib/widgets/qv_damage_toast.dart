import 'package:flutter/material.dart';
import 'package:jk_pixel_ui/jk_pixel_ui.dart';

// Shows a transient "- N HP" pill for when an enemy attack resolves and
// damages the player — thin app-side wrapper around jk_pixel_ui's generic
// showAmountToast (was its own standalone widget before the UI-kit
// extraction; see showAmountToast's own doc comment).
void showDamageToast(BuildContext context, int amount) {
  showAmountToast(
    context,
    amount: amount,
    label: 'HP',
    prefix: '-',
    buttonColor: ButtonColor.fireRed,
    textColor: Colors.white,
  );
}
