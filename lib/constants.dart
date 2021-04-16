import 'package:flutter/material.dart';
import 'package:openai_gpt3_api/invalid_request_exception.dart';
import 'package:openai_gpt3_api/openai_gpt3_api.dart';

class Constants {
  static GPT3? api;

  static void initializeApi(String apiKey) {
    api = GPT3(apiKey);
  }
}

/// Returns the app's default snackbar with a [text].
SnackBar getGenericSnackBar(String text, bool isError) {
  return SnackBar(
    content: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: isError ? Colors.red : Colors.white,
        fontSize: 16.0,
      ),
    ),
  );
}

void showErrorSnackBar(InvalidRequestException e, BuildContext context) {
  ScaffoldMessenger.of(context)
      .showSnackBar(getGenericSnackBar(e.message, true));
}
