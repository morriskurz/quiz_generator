import 'dart:core';

import 'package:flutter/material.dart';
import 'package:openai_gpt3_api/completion.dart';
import 'package:openai_gpt3_api/invalid_request_exception.dart';
import 'package:quiz_generator/utils/constants.dart';

class QuestionAnswerWidget extends StatefulWidget {
  QuestionAnswerWidget(
      {Key? key,
      required this.question,
      required this.answer,
      required this.displayingAnswerNotifier})
      : super(key: key);

  final String question;
  final String answer;
  final ValueNotifier<bool> displayingAnswerNotifier;

  @override
  _QuestionAnswerWidgetState createState() => _QuestionAnswerWidgetState();
}

class _QuestionAnswerWidgetState extends State<QuestionAnswerWidget> {
  TextEditingController controller;
  bool _loading;
  String _answerText;
  bool displayingAnswer = false;

  void _submitAnswer() async {
    setState(() => _loading = true);
    CompletionApiResult result;
    try {
      //result = await Constants.api!.completion(controller.text);
    } on InvalidRequestException catch (e) {
      setState(() => _loading = false);
      showErrorSnackBar(e, context);
      return;
    }
    setState(() {
      _loading = false;
      _answerText = widget.answer;
    });
  }

  void _displayAnswer() {
    widget.displayingAnswerNotifier.value = true;
    setState(() => displayingAnswer = true);
  }

  Widget _getDisplayingAnswerWidget() {
    if (displayingAnswer) {
      return Container(
          alignment: Alignment.topCenter,
          decoration: BoxDecoration(
            border: Border.all(width: 1.0),
            borderRadius: BorderRadius.all(
                Radius.circular(5.0) //         <--- border radius here
                ),
          ),
          height: MediaQuery.of(context).size.width / 8,
          width: MediaQuery.of(context).size.width / 2,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              widget.answer,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 20,
                color: const Color(0xde000000),
                letterSpacing: -0.48,
                fontWeight: FontWeight.w300,
                height: 1.2,
              ),
            ),
          ));
    }
    return Container(
        height: MediaQuery.of(context).size.width / 8,
        width: MediaQuery.of(context).size.width / 2,
        child: OutlinedButton(
            onPressed: _displayAnswer, child: Text('Display answer')));
  }

  @override
  void initState() {
    widget.displayingAnswerNotifier.addListener(() {
      displayingAnswer = widget.displayingAnswerNotifier.value;
    });
    super.initState();
  }

  _QuestionAnswerWidgetState()
      : controller = TextEditingController(),
        _loading = false,
        _answerText = '';

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          height: 20,
        ),
        Text(
          widget.question,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 30,
            color: const Color(0xde000000),
            letterSpacing: -0.48,
            fontWeight: FontWeight.w300,
            height: 1.2,
          ),
        ),
        _getDisplayingAnswerWidget(),
      ],
    ));
  }
}
