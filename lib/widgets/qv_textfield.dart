import 'package:flutter/material.dart';

class QvTextField extends StatelessWidget {
  final Key? inputKey;
  final String? hint;
  final TextEditingController? controller;
  final void Function(String) onChanged;
  final void Function(String)? onSubmitted;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final int? minLines;
  final double? textSize;
  final TextInputType? keyboardType;
  final bool autofocus;

  const QvTextField({
    super.key,
    this.inputKey,
    this.hint,
    this.controller,
    required this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.maxLines,
    this.minLines,
    this.textSize,
    this.keyboardType,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return TextField(
      key: inputKey,
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        isDense: true,
      ),
      style: TextStyle(
        fontSize: textSize,
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      textInputAction: textInputAction,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      maxLines: maxLines,
      minLines: minLines,
      keyboardType: keyboardType,
      autofocus: autofocus,
    );
  }
}
