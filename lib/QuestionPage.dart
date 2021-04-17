import 'package:flutter/material.dart';
import 'package:quiz_generator/utils/constants.dart';
import 'package:quiz_generator/widgets/question_answer_widget.dart';

class QuestionPage extends StatefulWidget {
  QuestionPage({Key? key}) : super(key: key);

  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  int _currentIndex;
  QuestionPageArguments args;

  _QuestionPageState()
      : _currentIndex = 0,
        args = QuestionPageArguments(['Test question 1', 'Test question 2'],
            ['Test answer 1', 'Test answer 2']);

  List<QuestionAnswerWidget> _getQuestionAnswerWidgets(
      QuestionPageArguments args) {
    var result = <QuestionAnswerWidget>[];
    for (var i = 0; i < args.questions.length; i++) {
      result.add(QuestionAnswerWidget(
          question: args.questions[i], answer: args.answers[i]));
    }
    return result;
  }

  void _nextIndex() {
    if (_currentIndex == args.questions.length - 1) {
      return null;
    }
    setState(() {
      _currentIndex++;
    });
  }

  @override
  Widget build(BuildContext context) {
    var args =
        ModalRoute.of(context)!.settings.arguments as QuestionPageArguments?;
    args ??= QuestionPageArguments(['Test question 1', 'Test question 2'],
        ['Test answer 1', 'Test answer 2']);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 26, 26, 26),
        title: TextButton(
            onPressed: () => navigateToHome(context),
            child: Image.asset(
              'assets/logo.png',
              fit: BoxFit.fitHeight,
              scale: 2.5,
            )),
        actions: [
          TextButton(
            onPressed: () {
              signInWithGoogle();
            },
            child: Text('LOG IN'),
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: ListView(
            children: [
              LinearProgressIndicator(
                value: _currentIndex / args.questions.length,
              ),
              QuestionAnswerWidget(
                question: args.questions[_currentIndex],
                answer: args.answers[_currentIndex],
              ),
              ElevatedButton(
                  onPressed: () {
                    if (_currentIndex == 0) {
                      return null;
                    }
                    setState(() {
                      _currentIndex--;
                    });
                  },
                  child: Text('Back')),
              ElevatedButton(
                  onPressed: () {
                    if (_currentIndex == args!.questions.length - 1) {
                      return null;
                    }
                    setState(() {
                      _currentIndex++;
                    });
                  },
                  child: Text('Next')),
            ],
          ),
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
