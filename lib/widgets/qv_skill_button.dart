import 'package:flutter/material.dart';
import 'package:questvale/data/providers/game_data_models/skill_data.dart';

class QvSkillButton extends StatelessWidget {
  const QvSkillButton({
    super.key,
    this.onTap,
    this.width,
    this.height,
    required this.skillIconPath,
    required this.skillButtonColor,
    this.darkened = false,
  });

  final VoidCallback? onTap;
  final String skillIconPath;
  final double? width;
  final double? height;
  final SkillButtonColor skillButtonColor;
  final bool darkened;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: ColorFiltered(
        colorFilter: darkened
            ? ColorFilter.mode(
                Colors.black.withValues(alpha: 0.5), BlendMode.srcATop)
            : const ColorFilter.mode(Colors.transparent, BlendMode.color),
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
      ),
    );
  }
}
