import 'package:alarm_app/Controllers/location_controller.dart';
import 'package:alarm_app/Models/alarm_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

void deleteConfirmationDialog(
    {required BuildContext context, required int index}) {
  final LocationController controller = Get.find();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        actionsPadding: EdgeInsets.only(bottom: 10, right: 15),
        titlePadding: EdgeInsets.only(top: 10),
        content: Text(
          'Are you sure want to Delete?',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Box<AlarmModel> box = Hive.box<AlarmModel>("Alarm_Model");

              box.delete(controller.alarmList[index].id);

              controller.deleteAlarm(
                  dateTime: controller.alarmList[index].alarmTime);

              Get.back();
            },
            child: Text('Delete'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text('Close'),
          ),
        ],
      );
    },
  );
}
