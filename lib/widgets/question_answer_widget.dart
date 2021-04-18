import 'dart:core';

import 'package:flutter/material.dart';

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
  bool displayingAnswer = false;

  void _displayAnswer() {
    widget.displayingAnswerNotifier.value = true;
    setState(() => displayingAnswer = true);
  }

  Widget _getDisplayingAnswerWidget() {
    var screenWidth = MediaQuery.of(context).size.width;
    var width = MediaQuery.of(context).orientation == Orientation.portrait
        ? screenWidth / 1.3
        : screenWidth / 2;
    var height = MediaQuery.of(context).orientation == Orientation.portrait
        ? screenWidth / (1.3 * 3)
        : screenWidth / 8;
    if (displayingAnswer) {
      return Container(
          alignment: Alignment.topCenter,
          decoration: BoxDecoration(
            border: Border.all(width: 1.0),
            borderRadius: BorderRadius.all(
                Radius.circular(5.0) //         <--- border radius here
                ),
          ),
          height: height,
          width: width,
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
        height: height,
        width: width,
        child: OutlinedButton(
            onPressed: _displayAnswer,
            child: Text(
              'Think about the answer, then check it here.',
              style: TextStyle(fontSize: 15),
            )));
  }

  @override
  void initState() {
    widget.displayingAnswerNotifier.addListener(() {
      displayingAnswer = widget.displayingAnswerNotifier.value;
    });
    super.initState();
  }

  _QuestionAnswerWidgetState() : controller = TextEditingController();

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
