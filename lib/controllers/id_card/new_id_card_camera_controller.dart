import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:typed_data';

abstract class NewIdCardCameraController extends GetxController {
  late CameraController cameraController;
  var isCameraInitialized = false.obs;
  late TextRecognizer textRecognizer;
  RxString detectedText = ''.obs;
  RxList<String> extractedLines = <String>[].obs;
  RxList<String> filteredStrings = <String>[].obs;
  RxString filtered = ''.obs; //not obs
  RxString info = ''.obs;

  Future<void> initializeCamera();
  Future<void> processCameraFrame(CameraImage image);
}

class NewIdCardCameraControllerImp extends NewIdCardCameraController {
  @override
  void onInit() async {
    super.onInit();
    textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    await initializeCamera();
  }

  @override
  Future<void> initializeCamera() async {
    final cameras = await availableCameras();

    if (cameras.isNotEmpty) {
      // Set to high resolution
      cameraController = CameraController(
        cameras[0],
        ResolutionPreset.medium,
        enableAudio: false, // Disable audio if not needed
      );

      try {
        await cameraController.initialize();
        isCameraInitialized.value = true;

        // Start processing frames
        cameraController.startImageStream((image) => processCameraFrame(image));
      } catch (e) {
        Get.snackbar("Camera Error", "Failed to initialize: $e");
      }
    } else {
      Get.snackbar("Error", "No cameras available");
    }
  }

  @override
  @override
  Future<void> processCameraFrame(CameraImage image) async {
    final rotation = InputImageRotationValue.fromRawValue(
            cameraController.description.sensorOrientation) ??
        InputImageRotation.rotation0deg;

    // Convert the image to InputImage
    final inputImage = await convertCameraImageToInputImage(image, rotation);

    if (inputImage != null) {
      try {
        final recognizedText = await textRecognizer.processImage(inputImage);
        print('OCR Result: ${recognizedText.text}');

        // Create a set to store unique text lines
        Set<String> uniqueLines = {};

        for (TextBlock block in recognizedText.blocks) {
          for (TextLine line in block.lines) {
            String text = line.text.replaceAll(' ', '').toUpperCase();

            // Add only unique lines
            uniqueLines.add(text);
          }
        }

        // Update extractedLines with unique lines
        extractedLines.value = uniqueLines.toList();

        filteredStrings.value = filterValidStrings(extractedLines);
        filtered.value = combineLines(filteredStrings.value);
        photoTextProcess();
      } catch (e) {
        print('Error processing image: $e');
      }
    } else {
      print('Error: Unable to convert camera image to InputImage.');
    }
  }

  Future<InputImage?> convertCameraImageToInputImage(
      CameraImage image, InputImageRotation rotation) async {
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    print('Converted image format: $format');

    // Check if the image format is supported
    if (format == InputImageFormat.yuv_420_888) {
      final yuvBytes = _convertYUV420_888ToNV21(image);
      return InputImage.fromBytes(
        bytes: yuvBytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: InputImageFormat.nv21, // We convert it to nv21
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );
    } else {
      print('Unsupported format: $format');
      return null; // Handle unsupported formats
    }
  }

  // Converts YUV420_888 format to NV21
  Uint8List _convertYUV420_888ToNV21(CameraImage image) {
    var width = image.width;
    var height = image.height;

    // Get Y, U, and V planes
    var yPlane = image.planes[0];
    var uPlane = image.planes[1];
    var vPlane = image.planes[2];

    var yBuffer = yPlane.bytes;
    var uBuffer = uPlane.bytes;
    var vBuffer = vPlane.bytes;

    var nv21 = List<int>.filled((width * height * 1.5).toInt(), 0);

    int idY = 0;
    int idUV = width * height;
    int uvWidth = width ~/ 2;
    int uvHeight = height ~/ 2;

    // Convert Y and UV planes to NV21 format
    for (int y = 0; y < height; ++y) {
      int uvOffset = y * uPlane.bytesPerRow;
      int yOffset = y * yPlane.bytesPerRow;

      for (int x = 0; x < width; ++x) {
        nv21[idY++] = yBuffer[yOffset + x];

        if (y < uvHeight && x < uvWidth) {
          int uvIndex = uvOffset + (x * uPlane.bytesPerPixel!);

          // Store V and U values
          nv21[idUV++] = vBuffer[uvIndex];
          nv21[idUV++] = uBuffer[uvIndex];
        }
      }
    }

    return Uint8List.fromList(nv21);
  }

  @override
  List<String> filterValidStrings(List<String> inputStrings) {
    // Regular expression to match the allowed pattern
    RegExp validPattern = RegExp(r'^[A-Za-z0-9][A-Za-z0-9\s<«()*]*$');

    // Regular expression to check if the string contains at least one letter
    RegExp containsLetters = RegExp(r'[A-Za-z]');

    // Filtering the list
    return inputStrings.where((str) {
      // Ensure the string matches the main pattern
      if (!validPattern.hasMatch(str)) return false;

      // Ensure the string is not just numbers
      return containsLetters.hasMatch(str);
    }).toList();
  }

  String combineLines(List<String?> lines) {
    // Join the lines into one string separated by a space
    return lines.where((line) => line != null).join('\n');
  }

  @override
  photoTextProcess() {
    try {
      List<String?> processLines = [];

      // Split the message into lines
      List<String> lines = filteredStrings.value;

      // Find the index where 'ID' appears
      int index = lines.indexWhere((line) => line.contains('IDD'));
      if (index >= 0) {
        // Collect lines starting from 'ID' to the end
        processLines = lines.sublist(index).map((e) => e.trim()).toList();
      }
      print('process lines----------');
      print(processLines);
      // If there are enough lines (at least 3), process the MRZ text

      if (processLines.length >= 3) {
        processMrzText(processLines);
      }
    } catch (error) {
      print("Error processing text: $error");
    }
  }

  @override
  processMrzText(List<String?> processLines) {
    try {
      String firstLine = processLines[0] ?? '';
      String secondLine = processLines[1] ?? '';
      String thirdLine = processLines[2] ?? '';

      // Extracting information from the first line
      String docType = firstLine.substring(0, 2); // Document type (IDD for ID)
      String nationality =
          firstLine.substring(2, 5); // Nationality (DZA for Algeria)
      String idNumber = firstLine.substring(5, 14); // ID number

      // Extracting information from the second line
      String birthDate = secondLine.substring(0, 6); // Birthdate (YYMMDD)
      String gender = secondLine[7]; // Gender (M or F)
      String expiryDate = secondLine.substring(8, 14); // Expiry date (YYMMDD)
      String country =
          secondLine.substring(15, 18); // Country code (DZA for Algeria)
      // Extracting information from the third line
      String name = cleanAndFormatName(thirdLine);

      // Format the output
      info.value = '''
        Document Type: $docType
        ID Number: $idNumber
        Nationality: $nationality
        Birthdate: ${formatMrzDate(birthDate, 'b')}
        Gender: $gender
        Expiry Date: ${formatMrzDate(expiryDate, 'e')}
        Country: $country
        Name: $name
        ''';

      // print(info.value);
    } catch (e) {
      debugPrint("Error processing MRZ: $e");
    }
  }

  @override
  String cleanAndFormatName(String input) {
    // Replace all specified characters with a space
    String cleaned = input.replaceAll(RegExp(r'[<«()*]+'), ' ');

    // Replace multiple consecutive spaces with a single space
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Convert to uppercase
    return cleaned.toUpperCase();
  }

  @override
  String formatMrzDate(String date, String type) {
    if (date.length == 6) {
      // Extract the year part (first 2 digits), month, and day
      String yearPart = date.substring(0, 2);
      String month = date.substring(2, 4);
      String day = date.substring(4, 6);

      int year = int.parse(yearPart);
      int fullYear;

      // Check type and handle year logic
      if (type == 'e') {
        fullYear = 2000 + year;
      } else if (type == 'b') {
        fullYear = (year < 30) ? 2000 + year : 1900 + year;
      } else {
        return "Invalid type, use 'b' or 'e'";
      }

      String formattedDate = '$fullYear-$month-$day';
      return formattedDate;
    }
    return date; // Return original date if it's not in the expected format
  }

  @override
  void onClose() {
    cameraController.dispose();
    textRecognizer.close();
    super.onClose();
  }
}
