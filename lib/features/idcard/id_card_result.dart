import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrz_new/controllers/id_card/id_card_result_controller.dart';

class IdCardInfo extends StatelessWidget {
  const IdCardInfo({super.key});

  @override
  Widget build(BuildContext context) {
    IdCardResultControllerImp controller = Get.put(IdCardResultControllerImp());

    return Scaffold(
      appBar: AppBar(title: const Text("ID Card MRZ")),
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
