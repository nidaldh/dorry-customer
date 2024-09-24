import 'package:dorry/main.dart';
import 'package:flutter/material.dart';

void successSnackBar(String message) {
  if (appContext == null) {
    return;
  }
  ScaffoldMessenger.of(appContext!).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    ),
  );
}

void errorSnackBar(String message) {
  if (appContext == null) {
    return;
  }
  ScaffoldMessenger.of(appContext!).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ),
  );
}
