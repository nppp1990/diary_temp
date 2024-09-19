import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract class KeyboardUtils {
  static hideKeyboardByChannel() async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  static void hideKeyboard(BuildContext context) {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.hasFocus) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  static void showKeyboard(BuildContext context) {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && !currentFocus.hasFocus) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  static showKeyboardByChannel() async {
    SystemChannels.textInput.invokeMethod('TextInput.show');
  }
}
