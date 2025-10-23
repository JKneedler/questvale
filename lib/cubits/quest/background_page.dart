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
      padding: EdgeInsets.only(top: 60),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
              'images/backgrounds/${zoneName.toLowerCase()}-encounter.png'),
          colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: darkened ? 0.5 : 0.2),
              BlendMode.darken),
          fit: BoxFit.fill,
          filterQuality: FilterQuality.low,
        ),
      ),
      child: child,
    );
  }
}
