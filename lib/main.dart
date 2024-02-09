import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:alarm_app/Models/alarm_model.dart';
import 'package:alarm_app/Views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //requesting permission for location and notification
  await Permission.location.request();
  await Permission.notification.request();

  await Alarm.init();

  await Hive.initFlutter();

  Hive.registerAdapter(AlarmModelAdapter());

  await Hive.openBox<AlarmModel>("Alarm_Model");

  //checking if the alarm is ringing. If yes alarm will stop in 20 seconds or stop on a button click.
  Timer.periodic(
    Duration(seconds: 1),
    (timer) {
      if (Alarm.getAlarms().isNotEmpty) {
        Alarm.getAlarms().forEach(
          (element) async {
            if (await Alarm.isRinging(element.id)) {
              Get.dialog(
                TextButton(
                  onPressed: () async {
                    await Alarm.stop(element.id);
                    Get.back();
                  },
                  child: Text(
                    "Stop Alarm",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              );

              Timer(
                Duration(seconds: 20),
                () async {
                  await Alarm.stop(element.id);
                },
              );
            }
          },
        );
      }
    },
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
