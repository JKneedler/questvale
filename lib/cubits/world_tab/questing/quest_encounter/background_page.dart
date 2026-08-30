import 'package:flutter/material.dart';

class BackgroundPage extends StatelessWidget {
  const BackgroundPage(
      {super.key,
      required this.child,
      required this.zoneName,
      required this.darkened});
  final Widget child;
  final String zoneName;
  final bool darkened;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Used to pad the child down by 60px to clear the status bar/notch,
      // leaving this Container's own scenic background image visible in
      // that gap. QvQuestEncounterHeader now renders its own top filler
      // bar of the exact same height instead, covering that space with a
      // themed background rather than showing the scenery through it —
      // see its own doc comment. QuestEncounterView falls back to a plain
      // SizedBox of the same height on the states that don't show that
      // header at all, so this removal doesn't shift their content.
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
              'images/backgrounds/${zoneName.toLowerCase()}-encounter.png'),
          // colorFilter: ColorFilter.mode(
          //     Colors.black.withValues(alpha: darkened ? 0.5 : 0.2),
          //     BlendMode.darken),
          fit: BoxFit.fill,
          filterQuality: FilterQuality.low,
        ),
      ),
      child: child,
    );
  }
}
