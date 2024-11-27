import 'package:flutter/material.dart';
import 'package:get/get.dart';
 import 'package:mrz_new/controllers/passport/passport_result_controller.dart';

class PassportInfo extends StatelessWidget {
  const PassportInfo({super.key});

  @override
  Widget build(BuildContext context) {
    PassportResultControllerImp controller =
        Get.put(PassportResultControllerImp());

    return Scaffold(
      appBar: AppBar(title: const Text("Passport MRZ")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Obx(() {
          return ListView(
            children: [
              // Container(
              //   child: controller.imagePath.value.isNotEmpty
              //       ? Image.file(File(controller.imagePath.value))
              //       : const Text("Aucune image à afficher"),
              // ),
              // const SizedBox(height: 16),
              // if (controller.filteredStrings.value.isNotEmpty)
              //   Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text(controller.filtered.value),
              //     ],
              //   ),
              // const SizedBox(height: 16),
              Text(
                'Extracted information :',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Text(controller.info.value),
            ],
          );
        }),
      ),
    );
  }
}
