import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flash/flash_helper.dart';

Future<void> showNoConnectionToast(String message, BuildContext context) async {
  await showFlash(
      duration: Duration(seconds: 2),
      context: context,
      builder: (ctx, controller) {
        return Flash(controller: controller, child: Text(message));
      });
}
