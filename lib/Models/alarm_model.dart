import 'package:hive/hive.dart';
part "alarm_model.g.dart";

@HiveType(typeId: 1)
class AlarmModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final DateTime alarmTime;

  @HiveField(2)
  final String alarmLabel;
  AlarmModel(
      {required this.id, required this.alarmTime, required this.alarmLabel});
}
