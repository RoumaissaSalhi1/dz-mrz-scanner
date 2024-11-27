import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
 import 'package:mrz_new/controllers/passport/passport_camera_controller.dart';

class PassportCamera extends StatelessWidget {
  const PassportCamera({super.key});

  @override
  Widget build(BuildContext context) {
    final PassportCameraControllerImp controller =
        Get.put(PassportCameraControllerImp());
    return Scaffold(
      // appBar: AppBar(title: Text("Capture Photo")),
      body: Obx(() {
        if (!controller.isCameraInitialized.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            // Camera Preview
            CameraPreview(controller.cameraController),

            // Top rectangle overlay
            Positioned(
              top: 0,
              left: Get.width * 0.05,
              child: Container(
                width: Get.width * 0.9,
                height: Get.height * 0.4, // Adjust the height if necessary
                color: Colors.white.withOpacity(0.5),
              ),
            ),

            // Bottom rectangle overlay
            Positioned(
              bottom: 0,
              left: Get.width * 0.05,
              child: Container(
                width: Get.width * 0.9,
                height: Get.height * 0.4, // Adjust the height if necessary
                color: Colors.white.withOpacity(0.5),
              ),
            ),

            // Left rectangle overlay
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              width: Get.width * 0.05,
              child: Container(
                color: Colors.white.withOpacity(0.5),
              ),
            ),

            // Right rectangle overlay
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              width: Get.width * 0.05,
              child: Container(
                color: Colors.white.withOpacity(0.5),
              ),
            ),

            // Transparent rectangle (focus area in the center)
            Center(
              child: Container(
                width: Get.width * 0.9,
                height:
                    Get.height * 0.20, // Adjust the height of the focus area
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.deepPurple, width: 2),
                  color: Colors.transparent, // Transparent inside
                ),
              ),
            ),

            // Camera Button (placed at the bottom)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FloatingActionButton(
                  onPressed: controller.isTakingPicture.value
                      ? null
                      : () async {
                          await controller.captureImage();
                        },
                  child: const Icon(Icons.camera),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
