import 'package:flutter/material.dart';

class BackgroundForm extends StatelessWidget {
  const BackgroundForm({
    Key? key,
    required this.screenHeight,
    required this.backColor,
  }) : super(key: key);

  final double screenHeight;
  final Color backColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: backColor,
          ),
        ),
        Transform.scale(
          scale: 1.4,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: RotationTransition(
              turns: const AlwaysStoppedAnimation(-10 / 360),
              alignment: Alignment.bottomCenter,
              child: Container(
                alignment: Alignment.bottomCenter,
                height: screenHeight * 0.22,
                width: double.infinity,
                decoration: const BoxDecoration(
                color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        Container(
          alignment: Alignment.bottomRight,
          padding: const EdgeInsets.all(15),
          child: Image(
            image: const AssetImage('assets/images/build_green_logo.png'),
            height: screenHeight * 0.1,
            ),
        ),
      ],
    );
  }
}