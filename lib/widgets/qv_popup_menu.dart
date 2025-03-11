import 'package:flutter/material.dart';

class QVPopupMenu extends StatefulWidget {
  final Widget button;
  final List<Widget> menuContents;
  final AlignmentGeometry alignment;
  final Offset offset;
  final MenuController menuController;

  const QVPopupMenu({
    super.key,
    required this.button,
    required this.menuContents,
    this.alignment = AlignmentDirectional.bottomStart,
    this.offset = const Offset(0, 0),
    required this.menuController,
  });

  @override
  State<QVPopupMenu> createState() => _QVPopupMenuState();
}

class _QVPopupMenuState extends State<QVPopupMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return MenuAnchor(
      controller: widget.menuController,
      onOpen: () {
        setState(() => _isOpen = true);
        _animationController.forward();
      },
      onClose: () async {
        setState(() => _isOpen = false);
        await _animationController.reverse();
      },
      style: MenuStyle(
        alignment: widget.alignment,
        backgroundColor:
            WidgetStateProperty.all(colorScheme.surfaceContainerHigh),
        shadowColor: WidgetStateProperty.all(colorScheme.surface),
        elevation: WidgetStateProperty.all(10.0),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
      alignmentOffset: widget.offset,
      menuChildren: widget.menuContents
          .map((child) => FadeTransition(
                opacity: _fadeAnimation,
                child: child,
              ))
          .toList(),
      builder: (context, controller, child) {
        return GestureDetector(
          onTap: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          child: widget.button,
        );
      },
      child: widget.button,
    );
  }
}
