import 'package:flutter/material.dart';
import 'package:jk_pixel_ui/jk_pixel_ui.dart';

// Shows a transient "+ N AP" pill — thin app-side wrapper around
// jk_pixel_ui's generic showAmountToast (was its own standalone widget
// before the UI-kit extraction; see showAmountToast's own doc comment).
void showApToast(BuildContext context, int amount) {
  showAmountToast(
    context,
    amount: amount,
    label: 'AP',
    buttonColor: ButtonColor.primary,
  );
}
