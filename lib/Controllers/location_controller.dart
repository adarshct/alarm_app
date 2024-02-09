import 'dart:convert';

import 'package:alarm/alarm.dart';
import 'package:alarm_app/Models/alarm_model.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class LocationController extends GetxController {
  RxBool servicePermission = false.obs;
  Rx<LocationPermission> permission = LocationPermission.denied.obs;
  RxDouble latitude = 0.0.obs;
  RxDouble longitude = 0.0.obs;
  RxString place = "".obs;
  RxString weatherDescription = "".obs;
  RxInt temperature = 0.obs;
  Rx<DateTime> selectedDate = DateTime.now().obs;
  Rx<TimeOfDay> selectedTime = TimeOfDay.now().obs;
  RxList<AlarmModel> alarmList = RxList();
  TextEditingController textFieldController = TextEditingController();
  RxInt alarmId = 0.obs;

  void getAlarmList() async {
    Box<AlarmModel> box = await Hive.openBox<AlarmModel>("Alarm_Model");

    //deleting alarm after triggered
    box.values.forEach((element) async {
      if (element.alarmTime.millisecondsSinceEpoch <
          DateTime.now().millisecondsSinceEpoch) {
        await box.delete(element.id);
      }
    });

    //sort by time
    alarmList.value = box.values.toList();
    alarmList.sort((a, b) => a.alarmTime.millisecondsSinceEpoch
        .compareTo(b.alarmTime.millisecondsSinceEpoch));
  }

  void getCurrentLocation() async {
    servicePermission.value = await Geolocator.isLocationServiceEnabled();

    if (!servicePermission.value) {
      permission.value = await Geolocator.checkPermission();
      if (permission.value == LocationPermission.denied) {
        permission.value = await Geolocator.requestPermission();
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    latitude.value = position.latitude;
    longitude.value = position.longitude;
  }

  void getWeatherData() async {
    getCurrentLocation();

    var client = http.Client();
    String apiKey = "a374d95ee2a892cc09e6b2f00e398ba1";

    final apiUrl =
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey';

    var response = await client.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      var decoded = json.decode(response.body);

      place.value = decoded['name'];
      weatherDescription.value = decoded['weather'][0]['description'];
      double temperatureInDouble = decoded['main']['temp'] - 273.15;
      temperature.value = temperatureInDouble.round();
    } else {
      await Get.dialog(
        Text("Server Error"),
      );
    }
  }

  void setAlarm(
      {required DateTime dateTime,
      required String alarmLabel,
      required int alarmId}) async {
    final alarmSettings = AlarmSettings(
      androidFullScreenIntent: true,
      id: DateTime.now().hashCode,
      dateTime: dateTime,
      assetAudioPath: 'assets/alarm.mp3',
      loopAudio: false,
      vibrate: true,
      volume: 0.8,
      notificationTitle: "Alarm",
      notificationBody: alarmLabel,
    );

    await Alarm.set(alarmSettings: alarmSettings);
  }

  void deleteAlarm({required DateTime dateTime}) {
    List<AlarmSettings> alarmSettingsList = Alarm.getAlarms();
    int alarmSettingsId;

    alarmSettingsList.forEach((element) async {
      if (element.dateTime == dateTime) {
        alarmSettingsId = element.id;
        await Alarm.stop(alarmSettingsId);
      }
    });
  }
}
