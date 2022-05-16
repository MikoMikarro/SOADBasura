import 'package:flutter/material.dart';

class GeneralBackground extends StatelessWidget {
  const GeneralBackground({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Colors.white,
          Colors.lightGreen,
          ],
        )
      ),
    );
  }
}