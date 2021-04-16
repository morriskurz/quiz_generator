import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:openai_gpt3_api/openai_gpt3_api.dart';
import 'package:quiz_generator/QuestionPage.dart';

void main() {
  runApp(MyApp());
}

const OPENAI_API_KEY =
    String.fromEnvironment('OPENAI_API_KEY', defaultValue: '123123123');

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => MyHomePage(title: 'KeepMind'),
          '/qa': (context) => QuestionPage(),
        },
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController controller;
  GPT3 api;
  bool _loading;

  Future<void> _sendTextToGpt3() async {
    var text = controller.text;
    text =
        'Generate a quiz of three questions for the key points from this text:\n\"\"\"' +
            text +
            '\n\"\"\"\nThe three quiz questions are:\n1.';
    var words = text.split(' ');
    var numberOfWords = words.length;
    setState(() => _loading = true);
    CompletionApiResult answer;
    try {
      answer = await api.completion(text,
          engine: Engine.curieInstruct,
          maxTokens: 64,
          temperature: 0.2,
          topP: 1);
    } on InvalidRequestException {
      print('error');
      return;
    }
    var questions = '1. ' + answer.choices.first.text;
    print(questions);
    print(questions.split('\n').toString());
    await Navigator.pushNamed(context, '/qa',
        arguments: QuestionPageArguments(questions.split('\n')));
    setState(() => _loading = false);
  }

  _MyHomePageState()
      : controller = TextEditingController(),
        api = GPT3(OPENAI_API_KEY),
        _loading = false;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: LoadingOverlay(
        isLoading: _loading,
        child: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Invoke "debug painting" (press "p" in the console, choose the
            // "Toggle Debug Paint" action from the Flutter Inspector in Android
            // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
            // to see the wireframe for each widget.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: controller,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                minLines: 5,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Input your text here',
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendTextToGpt3,
        tooltip: 'Send',
        child: Icon(Icons.send),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
