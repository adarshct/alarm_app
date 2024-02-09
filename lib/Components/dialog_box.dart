import 'package:flutter/material.dart';
import 'package:get/get.dart';

void invalidDialogBox({required String content}) async {
  await Get.defaultDialog(
    radius: 10,
    title: "INVALID !",
    titlePadding: EdgeInsets.only(top: 20, bottom: 10),
    titleStyle: TextStyle(
      color: Colors.red[400],
      fontWeight: FontWeight.bold,
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 20),
    content: Text(
      content,
      style: TextStyle(fontSize: 16),
    ),
    actions: [
      SizedBox(
        width: 200,
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text(
            "OK",
            style: TextStyle(
              color: Colors.teal,
            ),
          ),
        ),
      ),
    ],
  );
}
