import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrz_new/controllers/home_controller.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    HomeControllerImp controller = Get.put(HomeControllerImp());
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FilledButton(
              onPressed: () {
                controller.goToPassport();
              },
              child: const Text('Passport'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                controller.goToIdCard();
              },
              child: const Text('Id Card'),
            ),
          ],
        ),
      ),
    );
  }
}
