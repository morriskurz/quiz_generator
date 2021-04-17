import 'package:flutter/material.dart';
import 'package:quiz_generator/widgets/question_answer_widget.dart';

class QuestionPage extends StatelessWidget {
  List<QuestionAnswerWidget> _getQuestionAnswerWidgets(
      QuestionPageArguments args) {
    var result = <QuestionAnswerWidget>[];
    for (var i = 0; i < args.questions.length; i++) {
      result.add(QuestionAnswerWidget(
          question: args.questions[i], answer: args.answers[i]));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as QuestionPageArguments?;
    if (args == null) {
      //Navigator.pushNamed(context, '/');
      return Container();
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(
          children: _getQuestionAnswerWidgets(args),
        ),
      ),
    );
  }
}

class QuestionPageArguments {
  final List<String> questions;
  final List<String> answers;

  QuestionPageArguments(this.questions, this.answers);
}
