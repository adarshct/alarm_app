import 'package:alarm_app/Components/dialog_box.dart';
import 'package:alarm_app/Controllers/location_controller.dart';
import 'package:alarm_app/Models/alarm_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class AddAlarmScreen extends StatelessWidget {
  AddAlarmScreen({super.key});

  final LocationController controller = Get.put(LocationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: Icon(
                    Icons.arrow_back_ios,
                  ),
                ),
                SizedBox(
                  height: 37,
                  width: 80,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 172, 122, 229),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      Box<AlarmModel> box =
                          await Hive.openBox<AlarmModel>("Alarm_Model");

                      bool isAlarmAlreadyExists = false;

                      DateTime combinedDateTime = DateTime(
                        controller.selectedDate.value.year,
                        controller.selectedDate.value.month,
                        controller.selectedDate.value.day,
                        controller.selectedTime.value.hour,
                        controller.selectedTime.value.minute,
                      );

                      //if textfield is empty
                      if (controller.textFieldController.text.isEmpty) {
                        invalidDialogBox(
                            content: "Alarm label field can't be empty.");
                      }
                      //if selected a past time
                      else if (combinedDateTime.millisecondsSinceEpoch <
                          DateTime.now().millisecondsSinceEpoch) {
                        invalidDialogBox(
                            content: "Please select a future time.");
                      }
                      //else
                      else {
                        if (box.containsKey(controller.alarmId.value)) {
                          box.delete(controller.alarmId.value);
                        }

                        box.values.forEach((element) {
                          if (element.alarmTime == combinedDateTime) {
                            isAlarmAlreadyExists = true;
                          }
                        });
                        if (isAlarmAlreadyExists) {
                          invalidDialogBox(
                              content: "Alarm time already existing");
                        } else {
                          //creating object for hive model class.
                          AlarmModel alarmModel = AlarmModel(
                            id: DateTime.now().hashCode,
                            alarmTime: combinedDateTime,
                            alarmLabel: controller.textFieldController.text,
                          );

                          //inserting the object to hive with an id.
                          box.put(alarmModel.id, alarmModel);

                          //updating alarm list
                          controller.getAlarmList();

                          //setting alarm
                          controller.setAlarm(
                            dateTime: combinedDateTime,
                            alarmLabel: alarmModel.alarmLabel,
                            alarmId: alarmModel.id,
                          );

                          Get.back();
                        }
                      }
                    },
                    child: Text(
                      "Save",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            weatherCard(context),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20),
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      datePicker(context);
                    },
                    icon: Icon(Icons.calendar_month),
                    label: Obx(
                      () => Text(
                        controller.selectedDate.value
                            .toString()
                            .substring(0, 10),
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextButton.icon(
                    onPressed: () {
                      timePicker(context);
                    },
                    icon: Icon(Icons.timer),
                    label: Obx(
                      () {
                        final formatter = NumberFormat('00');

                        int hour = controller.selectedTime.value.hour <= 12
                            ? controller.selectedTime.value.hour
                            : controller.selectedTime.value.hour - 12;

                        int minute = controller.selectedTime.value.minute;

                        String hourAsString = formatter.format(hour);
                        String minuteAsString = formatter.format(minute);

                        String amOrPm = controller.selectedTime.value.hour < 12
                            ? "AM"
                            : "PM";
                        return Text(
                          "$hourAsString:$minuteAsString $amOrPm",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: controller.textFieldController,
                    decoration: InputDecoration(
                      labelText: "Enter Alarm Name Here",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            width: 2, color: Color.fromARGB(255, 143, 13, 165)),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget weatherCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 214, 172, 225),
              Color.fromARGB(255, 219, 190, 227),
            ],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Obx(
          () {
            controller.getWeatherData();
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "${controller.temperature.value.toString()}°C",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      controller.place.value,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      controller.weatherDescription.value,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void datePicker(BuildContext context) async {
    controller.selectedDate.value = await showDatePicker(
          context: context,
          helpText: 'Your Date of Birth',
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2050),
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: ColorScheme.light(
                  primary: Theme.of(context).colorScheme.primary,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
              ),
              child: child!,
            );
          },
        ) ??
        DateTime.now();
  }

  void timePicker(BuildContext context) async {
    controller.selectedTime.value = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: ColorScheme.light(
                  primary: Theme.of(context).colorScheme.primary,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
              ),
              child: child!,
            );
          },
        ) ??
        TimeOfDay.now();
  }
}
