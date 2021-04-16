import 'package:flutter/material.dart';
import 'package:quiz_generator/widgets/question_answer_widget.dart';

class QuestionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as QuestionPageArguments?;
    if (args == null) {
      //Navigator.pushNamed(context, '/');
      return Container();
    }
    return ListView(
      children: [
        ...args.questions.map((e) => QuestionAnswerWidget(question: e)).toList()
      ],
    );
  }
}

class QuestionPageArguments {
  final List<String> questions;

  QuestionPageArguments(this.questions);
}
