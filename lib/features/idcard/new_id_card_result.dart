import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrz_new/controllers/id_card/new_id_card_result_controller.dart';
 
class NewIdCardInfo extends StatelessWidget {
  const NewIdCardInfo({super.key});

  @override
  Widget build(BuildContext context) {
    NewIdCardResultControllerImp controller = Get.put(NewIdCardResultControllerImp());

    return Scaffold(
      appBar: AppBar(title: const Text("ID Card MRZ")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Obx(() {
          return ListView(
            children: [
             
              Text(
                'Extracted information :',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Text(controller.info),
            ],
          );
        }),
      ),
    );
  }
}
