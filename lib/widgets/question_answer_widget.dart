import 'package:flutter/material.dart';

class QuestionAnswerWidget extends StatefulWidget {
  QuestionAnswerWidget({Key? key, required this.question}) : super(key: key);

  final String question;

  @override
  _QuestionAnswerWidgetState createState() => _QuestionAnswerWidgetState();
}

class _QuestionAnswerWidgetState extends State<QuestionAnswerWidget> {
  TextEditingController controller;
  Future<void> _submitAnswer() {
    return Future.error('not implemented');
  }

  _QuestionAnswerWidgetState() : controller = TextEditingController();

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
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'answer',
              ),
              minLines: 2,
              maxLines: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  onPressed: () {/* ... */},
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
