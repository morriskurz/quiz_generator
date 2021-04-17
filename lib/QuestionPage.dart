import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:quiz_generator/utils/constants.dart';
import 'package:quiz_generator/widgets/question_answer_widget.dart';

class QuestionPage extends StatefulWidget {
  QuestionPage({Key? key, required this.args}) : super(key: key);

  final QuestionPageArguments? args;

  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  int _currentIndex;
  List<QuestionAnswerWidget> _questionAnswerWidgets;
  bool _displayingAnswer = false;

  _QuestionPageState()
      : _currentIndex = 0,
        _questionAnswerWidgets = [],
        _displayingAnswer = false {}

  @override
  void initState() {
    var notifier = ValueNotifier<bool>(_displayingAnswer);
    notifier.addListener(() {
      setState(() {
        print('Setting displayAnswer to ' + notifier.value.toString());
        _displayingAnswer = notifier.value;
      });
    });
    QuestionPageArguments args;
    if (widget.args == null) {
      args = QuestionPageArguments(['Test question 1', 'Test question 2'],
          ['Test answer 1', 'Test answer 2']);
    } else {
      args = widget.args!;
    }
    for (var i = 0; i < args.questions.length; i++) {
      _questionAnswerWidgets.add(QuestionAnswerWidget(
        question: args.questions[i],
        answer: args.answers[i],
        displayingAnswerNotifier: notifier,
      ));
    }
    super.initState();
  }

  void _nextIndex() {
    // Reset value so that it does not reveal the answer on the next question immediately.
    _questionAnswerWidgets[_currentIndex + 1].displayingAnswerNotifier.value =
        false;
    setState(() {
      _currentIndex++;
      _displayingAnswer = false;
    });
  }

  void _previousIndex() {
    // Reset value so that it does not reveal the answer on the next question immediately.
    _questionAnswerWidgets[_currentIndex - 1].displayingAnswerNotifier.value =
        false;
    setState(() {
      _currentIndex--;
      _displayingAnswer = false;
    });
  }

  double _getProgressPercentage() {
    if (_questionAnswerWidgets.isEmpty) {
      return 1;
    }
    return _currentIndex / _questionAnswerWidgets.length;
  }

  void _againButton() {
    _questionAnswerWidgets.add(_questionAnswerWidgets[_currentIndex]);
    _nextIndex();
  }

  void _difficultyButton() {
    _nextIndex();
    // Für den Prototypen nicht wichtig, was hier passiert.
  }

  @override
  Widget build(BuildContext context) {
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
                  center: Text(
                      (_getProgressPercentage() * 100).ceil().toString() + '%'),
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
                            onPressed: _displayingAnswer ? _againButton : null,
                            child: Text('Again'))),
                    Container(
                        height: MediaQuery.of(context).size.width / 12,
                        width: MediaQuery.of(context).size.width / 6,
                        child: OutlinedButton(
                            onPressed:
                                _displayingAnswer ? _difficultyButton : null,
                            child: Text('Hard'))),
                    Container(
                        height: MediaQuery.of(context).size.width / 12,
                        width: MediaQuery.of(context).size.width / 6,
                        child: OutlinedButton(
                            onPressed:
                                _displayingAnswer ? _difficultyButton : null,
                            child: Text('Easy')))
                  ],
                ),
              ),
              ElevatedButton(
                  onPressed: _currentIndex == 0 ? null : _previousIndex,
                  child: Text('Back')),
              ElevatedButton(
                  onPressed: _currentIndex == _questionAnswerWidgets.length - 1
                      ? null
                      : _nextIndex,
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
