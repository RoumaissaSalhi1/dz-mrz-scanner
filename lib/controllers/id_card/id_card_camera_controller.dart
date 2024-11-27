import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:mrz_new/features/idcard/id_card_result.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;

abstract class IdCardCameraController extends GetxController {
  late CameraController _cameraController;
  CameraController get cameraController => _cameraController;

  var isCameraInitialized = false.obs;
  var isTakingPicture = false.obs;

  late List<CameraDescription> cameras;
  late XFile? capturedImage;

  Future<void> initializeCamera();
  Future<void> captureImage();
}

class IdCardCameraControllerImp extends IdCardCameraController {
  @override
  void onInit() async {
    super.onInit();
    await initializeCamera();
  }

  @override
  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _cameraController = CameraController(
        cameras[0], // Use the rear camera
        ResolutionPreset.high,
      );
      await _cameraController.initialize();
      isCameraInitialized.value = true;
    } else {
      Get.snackbar("Erreur", "Aucune caméra disponible");
    }
  }

  @override
  Future<void> captureImage() async {
    if (!isCameraInitialized.value) return;
    isTakingPicture.value = true;

    try {
      capturedImage = await _cameraController.takePicture();

      if (capturedImage != null) {
        final filePath = capturedImage!.path;

        // Load the captured image using the 'image' package
        final img.Image? image =
            img.decodeImage(await capturedImage!.readAsBytes());

        if (image != null) {
          // // Define the bounds of the focus area (center container) in terms of pixels

          // // Calculate crop dimensions (center container)
          // double containerWidth = Get.width * 0.8;
          // double containerHeight = Get.height * 0.10;

          // // Scale container dimensions to match image resolution
          // double scaleX = image.width / Get.width;
          // double scaleY = image.height / Get.height;

          // int cropWidth = (containerWidth * scaleX).toInt();
          // int cropHeight = (containerHeight * scaleY).toInt();

          // int cropX = ((image.width - cropWidth) ~/ 2);
          // int cropY = ((image.height - cropHeight) ~/ 2) + 50;

          // print("ScaleX: $scaleX, ScaleY: $scaleY");
          // print("CropX: $cropX, CropY: $cropY");

          // // Perform cropping
          // img.Image croppedImage = img.copyCrop(
          //   image,
          //   x: cropX,
          //   y: cropY,
          //   width: cropWidth,
          //   height: cropHeight,
          // );
          // // Save the cropped image to a new file
          // final croppedImagePath =
          //     '${Directory.systemTemp.path}/cropped_image.png';
          // await File(croppedImagePath)
          //     .writeAsBytes(img.encodePng(croppedImage));

          // Save the cropped image path to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          //await prefs.setString('image_path', croppedImagePath);
          await prefs.setString('image_path', filePath);

          // Navigate to the result screen and pass the path of the cropped image
          Get.to(() => const IdCardInfo());
        }
      }
    } catch (e) {
      print("Erreur impossible de capturer l'image : $e");
    } finally {
      isTakingPicture.value = false;
    }
  }

  @override
  void onClose() {
    _cameraController.dispose();
    super.onClose();
  }
}
