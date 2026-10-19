
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showIapSnackbar({
  required String title,
  required String message,
  bool isError = false,
}) {
  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: const Color(0xFF181818),
    colorText: Colors.white,
    borderRadius: 14,
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.symmetric(
      horizontal: 18,
      vertical: 16,
    ),
    duration: const Duration(seconds: 3),
    animationDuration: const Duration(milliseconds: 300),
    borderColor: isError
        ? const Color(0xFFE05252)
        : const Color(0xFFFFD54F),
    borderWidth: 1,
    icon: Icon(
      isError ? Icons.error_outline : Icons.check_circle_outline,
      color: isError
          ? const Color(0xFFE05252)
          : const Color(0xFFFFD54F),
    ),
    shouldIconPulse: false,
    titleText: Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    ),
    messageText: Text(
      message,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 13,
        height: 1.4,
      ),
    ),
  );
}
