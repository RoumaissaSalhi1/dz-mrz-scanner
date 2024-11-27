import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

abstract class IdCardResultController extends GetxController {
  var imagePath = ''.obs; //not obs
  RxList<String> extractedLines = <String>[].obs;
  RxList<String> filteredStrings = <String>[].obs;
  RxString filtered = ''.obs; //not obs
  RxString info = ''.obs; //*to replace with attributes

  Future<void>
      loadImagePath(); //needed just to show the image in the screen (zyada)
  Future<void> extractTextFromImage();
  Future<void> extractMRZCode(String filePath);
  photoTextProcess();
  processMrzText(List<String?> processLines);
  String cleanAndFormatName(String input);
  String formatMrzDate(String date, String type);
  List<String> filterValidStrings(List<String> inputStrings);
  String combineLines(
      List<String?>
          lines); //to remove later, needed just to show the info in the screen as one string
}

class IdCardResultControllerImp extends IdCardResultController {
  @override
  void onInit() async {
    super.onInit();
    await loadImagePath();
    await extractTextFromImage();
    photoTextProcess();
  }

  @override
  Future<void> loadImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    imagePath.value = prefs.getString('image_path') ?? '';
  }

  @override
  Future<void> extractTextFromImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('image_path');

    if (imagePath != null) {
      await extractMRZCode(imagePath);
    } else {
      print('No image found in SharedPreferences.');
    }
  }

  // Method to extract text from image using Google ML Kit
  @override
  Future<void> extractMRZCode(String filePath) async {
    final inputImage = InputImage.fromFilePath(filePath);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final recognizedText2 = await textRecognizer.processImage(inputImage);
      for (TextBlock block in recognizedText2.blocks) {
        for (TextLine line in block.lines) {
          String text = line.text;
          extractedLines.add(text
              .replaceAll(' ', '')
              .toUpperCase()); // Adds text to the extracted lines
        }
      }

      // Filtering the list based on the pattern
      filteredStrings.value = filterValidStrings(extractedLines);
      filtered.value = combineLines(filterValidStrings(extractedLines));
    } catch (e) {
      print('Error processing image: $e');
    } finally {
      await textRecognizer.close();
    }
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
}
