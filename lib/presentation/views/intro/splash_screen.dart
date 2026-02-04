import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/intro/splash_screen_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    controller.splashScreenLogic();
    return Scaffold(
      // backgroundColor: colorBlack,
      body: Center(
        child: Text(
          "Vanashree",
          style: TextStyle(fontSize: 35, color: Colors.black),
        ),
      ),
    );
  }
}
