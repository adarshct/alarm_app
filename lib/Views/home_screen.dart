import 'package:alarm_app/Views/add_alarm_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../Components/delete_confirmation.dart';
import '../Controllers/location_controller.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final LocationController controller = Get.put(LocationController());

  List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  @override
  Widget build(BuildContext context) {
    controller.getAlarmList();
    return Scaffold(
      backgroundColor: Colors.grey[200],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 172, 122, 229),
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        onPressed: () {
          controller.textFieldController.text = "";

          Get.to(() => AddAlarmScreen());
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Obx(
        () => Container(
          padding: EdgeInsets.all(20),
          child: controller.alarmList.isEmpty
              ? Center(
                  child: Text(
                    "No Alarms Set",
                    style: TextStyle(
                      color: Color.fromARGB(255, 172, 122, 229),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 80),
                    Row(
                      children: [
                        Text(
                          "Your Alarm",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: Obx(
                        () {
                          controller.getAlarmList();
                          return ListView.separated(
                            padding: EdgeInsets.only(top: 10, bottom: 50),
                            itemCount: controller.alarmList.length,
                            itemBuilder: (context, index) {
                              //formatting date and time vaiables
                              String amOrPm =
                                  controller.alarmList[index].alarmTime.hour <
                                          12
                                      ? "AM"
                                      : "PM";
                              int hour = controller
                                          .alarmList[index].alarmTime.hour <=
                                      12
                                  ? controller.alarmList[index].alarmTime.hour
                                  : controller.alarmList[index].alarmTime.hour -
                                      12;
                              final formatter = NumberFormat('00');
                              String hourAsString = formatter.format(hour);

                              String minuteAsString = formatter.format(
                                  controller.alarmList[index].alarmTime.minute);
                              String month = months[
                                  controller.alarmList[index].alarmTime.month -
                                      1];
                              return AlarmTile(
                                index: index,
                                month: month,
                                hourAsString: hourAsString,
                                minuteAsString: minuteAsString,
                                amOrPm: amOrPm,
                              );
                            },
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 20),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class AlarmTile extends StatelessWidget {
  final int index;
  final String month;
  final String hourAsString;
  final String minuteAsString;
  final String amOrPm;

  AlarmTile({
    required this.index,
    required this.month,
    required this.hourAsString,
    required this.minuteAsString,
    required this.amOrPm,
  });

  final LocationController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width * 0.8,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 8,
                    width: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(255, 172, 122, 229),
                    ),
                  ),
                  SizedBox(width: 5),
                  Text(
                    "${controller.alarmList[index].alarmTime.day} $month, ${controller.alarmList[index].alarmTime.year}",
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 25),
                  Text(
                    "$hourAsString:$minuteAsString",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 5),
                  Text(amOrPm),
                ],
              ),
              Row(
                children: [
                  SizedBox(width: 25),
                  Text(
                    controller.alarmList[index].alarmLabel,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  //passing alarmId to edit section
                  controller.alarmId.value = controller.alarmList[index].id;

                  Get.to(() => AddAlarmScreen());

                  //setting tile date and time to edit screen
                  controller.selectedDate.value = DateTime(
                    controller.alarmList[index].alarmTime.year,
                    controller.alarmList[index].alarmTime.month,
                    controller.alarmList[index].alarmTime.day,
                  );

                  controller.selectedTime.value = TimeOfDay(
                    hour: controller.alarmList[index].alarmTime.hour,
                    minute: controller.alarmList[index].alarmTime.minute,
                  );

                  //setting tile label inside textfield
                  controller.textFieldController.text =
                      controller.alarmList[index].alarmLabel;
                },
                icon: Icon(
                  Icons.edit,
                  color: Color.fromARGB(255, 158, 99, 226),
                ),
              ),
              IconButton(
                onPressed: () {
                  deleteConfirmationDialog(context: context, index: index);
                },
                icon: Icon(
                  Icons.delete,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
