import 'package:flutter/material.dart';

enum SkillButtonColor {
  fireRed,
  iceBlue,
  arcanePurple;

  String get borderImagePath => {
        SkillButtonColor.fireRed: 'images/ui/borders/skills/infernal_ruby.png',
        SkillButtonColor.iceBlue: 'images/ui/borders/skills/arctic_dawn.png',
        SkillButtonColor.arcanePurple:
            'images/ui/borders/skills/royal_dusk.png',
      }[this]!;

  Color get backgroundColor => {
        SkillButtonColor.fireRed: Color(0xFF4A0C0A),
        SkillButtonColor.iceBlue: Color(0xFF0C2034),
        SkillButtonColor.arcanePurple: Color(0xFF200A2D),
      }[this]!;
}

class QvSkillButton extends StatelessWidget {
  const QvSkillButton({
    super.key,
    this.onTap,
    this.width,
    this.height,
    required this.skillIconPath,
    required this.skillButtonColor,
  });
  final VoidCallback? onTap;
  final String skillIconPath;
  final double? width;
  final double? height;
  final SkillButtonColor skillButtonColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: SizedBox(
        width: width ?? 64,
        height: height ?? 64,
        child: Stack(
          children: [
            Center(
              child: FractionallySizedBox(
                widthFactor: .8,
                heightFactor: .8,
                child: Container(
                  color: skillButtonColor.backgroundColor,
                  padding:
                      EdgeInsets.only(left: 2, right: 2, top: 2, bottom: 4),
                  child: Image.asset(
                    skillIconPath,
                    filterQuality: FilterQuality.none,
                    scale: .1,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  foregroundDecoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(skillButtonColor.borderImagePath),
                      centerSlice: Rect.fromLTWH(16, 16, 32, 32),
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.none,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
