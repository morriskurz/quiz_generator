import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
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
  List<QuestionAnswerWidget> _questionAnswerWidgets;

  _QuestionPageState()
      : _currentIndex = 0,
        args = QuestionPageArguments(['Test question 1', 'Test question 2'],
            ['Test answer 1', 'Test answer 2']),
        _questionAnswerWidgets = [] {
    for (var i = 0; i < args.questions.length; i++) {
      _questionAnswerWidgets.add(QuestionAnswerWidget(
          question: args.questions[i], answer: args.answers[i]));
    }
  }

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

  double _getProgressPercentage() {
    if (args.questions.isEmpty) {
      return 1;
    }
    return _currentIndex / args.questions.length;
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
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(15.0),
                child: LinearPercentIndicator(
                  width: MediaQuery.of(context).size.width - 60,
                  animation: true,
                  lineHeight: 20.0,
                  animationDuration: 500,
                  percent: _getProgressPercentage(),
                  center:
                      Text((_getProgressPercentage() * 100).toString() + '%'),
                  linearStrokeCap: LinearStrokeCap.roundAll,
                  progressColor: Colors.green,
                ),
              ),
              Expanded(flex: 3, child: _questionAnswerWidgets[_currentIndex]),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                        height: MediaQuery.of(context).size.width / 12,
                        width: MediaQuery.of(context).size.width / 6,
                        child: OutlinedButton(
                            onPressed: null, child: Text('Again'))),
                    Container(
                        height: MediaQuery.of(context).size.width / 12,
                        width: MediaQuery.of(context).size.width / 6,
                        child: OutlinedButton(
                            onPressed: null, child: Text('Hard'))),
                    Container(
                        height: MediaQuery.of(context).size.width / 12,
                        width: MediaQuery.of(context).size.width / 6,
                        child: OutlinedButton(
                            onPressed: null, child: Text('Easy')))
                  ],
                ),
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
