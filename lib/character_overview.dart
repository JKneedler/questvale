import 'package:flutter/material.dart';

class CharacterOverview extends StatelessWidget {
  const CharacterOverview({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 250,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox.square(
                          dimension: 60,
                          child: CircularProgressIndicator(
                            value: .5,
                            color: Colors.red,
                            strokeWidth: 12,
                          ),
                        ),
                        Text("50",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red))
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox.square(
                          dimension: 60,
                          child: CircularProgressIndicator(
                            value: .5,
                            color: Colors.blue,
                            strokeWidth: 12,
                          ),
                        ),
                        Text("50",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue))
                      ],
                    ),
                  ),
                ]),
            const Image(
              image: AssetImage("images/single-standing.png"),
              height: 230,
            ),
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox.square(
                          dimension: 60,
                          child: CircularProgressIndicator(
                            value: .8,
                            color: Colors.amber,
                            strokeWidth: 12,
                          ),
                        ),
                        Text("80",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber))
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(36)),
                          height: 72,
                          width: 72,
                        ),
                        const Row(
                          children: [
                            Icon(
                              Icons.attach_money,
                              color: Colors.white,
                            ),
                            Text("50",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ],
                        )
                      ],
                    ),
                  ),
                ]),
          ],
        ),
      ),
    );
  }
}
