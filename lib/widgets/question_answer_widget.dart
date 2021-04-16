import 'package:flutter/material.dart';
import 'package:openai_gpt3_api/completion.dart';
import 'package:openai_gpt3_api/invalid_request_exception.dart';
import 'package:quiz_generator/constants.dart';

class QuestionAnswerWidget extends StatefulWidget {
  QuestionAnswerWidget({Key? key, required this.question}) : super(key: key);

  final String question;

  @override
  _QuestionAnswerWidgetState createState() => _QuestionAnswerWidgetState();
}

class _QuestionAnswerWidgetState extends State<QuestionAnswerWidget> {
  TextEditingController controller;
  bool _loading;
  String _answerText;

  void _submitAnswer() async {
    setState(() => _loading = true);
    CompletionApiResult result;
    try {
      result = await Constants.api!.completion(controller.text);
    } on InvalidRequestException catch (e) {
      setState(() => _loading = false);
      showErrorSnackBar(e, context);
      return;
    }
    setState(() {
      _loading = false;
      _answerText = result.choices.first.text;
    });
  }

  _QuestionAnswerWidgetState()
      : controller = TextEditingController(),
        _loading = false,
        _answerText = '';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.question_answer),
              title: Text(widget.question),
            ),
            SizedBox(
              height: 100,
              child: Flexible(
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'answer',
                  ),
                  minLines: 2,
                  maxLines: 5,
                ),
              ),
            ),
            Text(_answerText),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  onPressed: () => _submitAnswer(),
                  child: const Text('EVALUATE'),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
