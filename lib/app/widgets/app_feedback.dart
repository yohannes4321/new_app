import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:church_app/app/core/utils/app_error_message.dart';

enum AppFeedbackType { info, success, warning, error }

void showAppFeedback(
  String title,
  Object? message, {
  AppFeedbackType type = AppFeedbackType.info,
  Duration duration = const Duration(seconds: 4),
}) {
  final normalizedMessage = type == AppFeedbackType.error
      ? AppErrorMessage.userFriendly(message)
      : (message ?? '').toString();

  Get.closeCurrentSnackbar();
  Get.snackbar(
    '',
    normalizedMessage,
    snackPosition: SnackPosition.TOP,
    titleText: const SizedBox.shrink(),
    duration: duration,
  );
}
