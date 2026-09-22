import 'package:flutter/material.dart';

class AppIcon extends StatelessWidget {
  final double height;
  final double width;

  const AppIcon({super.key, required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/icon/icon.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
