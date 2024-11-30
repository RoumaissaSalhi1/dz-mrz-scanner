import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrz_new/controllers/id_card/new_id_card_camera_controller.dart';
import 'package:camera/camera.dart';

class NewIdCardCamera extends StatelessWidget {
  const NewIdCardCamera({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NewIdCardCameraControllerImp());

    return Scaffold(
      body: Obx(() {
        if (!controller.isCameraInitialized.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            CameraPreview(controller.cameraController),
            Positioned(
              bottom: 50,
              child: Obx(() => Text(
                    'MRZ: ${controller.info.value}',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  )),
            ),
          ],
        );
      }),
    );
  }
}
