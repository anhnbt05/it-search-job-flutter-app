import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

void showTopToastification({
  required String content,
  required String title,
  required Color color,
  required IconData icon}) {
  toastification.show(
    style: ToastificationStyle.fillColored,
    autoCloseDuration: const Duration(seconds: 5),
    title: Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 17,
        color: Colors.white,
      ),
    ),
    description: RichText(
        text: TextSpan(
            text: content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            )
        )
    ),
    alignment: Alignment.topCenter,
    direction: TextDirection.ltr,
    animationDuration: const Duration(milliseconds: 300),
    icon: Icon(
      icon,
      size: 30,
    ),
    showIcon: true,
    primaryColor: color,
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    margin: const EdgeInsets.only(left: 10, right: 10, top: 5),
    borderRadius: BorderRadius.circular(12),
    closeOnClick: true,
    dragToClose: true,
    applyBlurEffect: true,
  );
}

void showSuccessToastification({required String title, required String message}) {
  showTopToastification(content: message, title: title, color: successColor, icon: Icons.check_circle_outline);
}

void showErrorToastification({required String title, required String message}) {
  showTopToastification(content: message, title: title, color: errorColor, icon: Icons.error_outline);
}
