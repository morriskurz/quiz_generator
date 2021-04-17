import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:openai_gpt3_api/completion.dart';
import 'package:openai_gpt3_api/invalid_request_exception.dart';
import 'package:openai_gpt3_api/openai_gpt3_api.dart';
import 'package:quiz_generator/QuestionPage.dart';
import 'package:quiz_generator/utils/constants.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  runApp(MyApp());
}

const OPENAI_API_KEY =
    String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');

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
  TextEditingController apiKeyController;
  bool _loading;
  bool _initialized;

  // File picking
  bool _loadingPath = false;
  final _pickingType = FileType.custom;
  List<PlatformFile>? _paths;
  String? _fileName;

  // PDF extraction
  List<String> _chapterNames;
  String? _selectedChapter;
  PdfDocument? _document;

  @override
  void initState() {
    _loading = true;
    initializeFlutterFire();
    super.initState();
  }

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
        _loading = false;
      });
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _loading = false;
      });
      showErrorSnackBar(
          InvalidRequestException(
              'Unable to reach the service. Please try again later.'),
          context);
    }
  }

  void _openFileExplorer() async {
    setState(() => _loadingPath = true);
    try {
      _paths = (await FilePicker.platform.pickFiles(
        type: _pickingType,
        allowMultiple: false,
        allowedExtensions: ['pdf', 'epub'],
      ))
          ?.files;
    } on PlatformException catch (e) {
      print('Unsupported operation' + e.toString());
    } catch (ex) {
      print(ex);
    }
    if (!mounted) return;
    setState(() {
      _loadingPath = false;
      _fileName =
          _paths != null ? _paths!.map((e) => e.name).toString() : '...';
    });
    _readPdf();
  }

  Future<List<int>> _readDocumentData() async {
    final file = File(_paths!.first.path!);
    return file.readAsBytes();
  }

  void _readPdf() async {
    //Load an existing PDF document.
    var document = PdfDocument(inputBytes: _paths!.first.bytes);
    setState(() {
      for (var i = 0; i < document.bookmarks.count; i++) {
        _chapterNames.add(document.bookmarks[i].title);
      }
    });
    _document = document;
    print(_chapterNames);
    print(document.bookmarks[4].title);
    print(document.bookmarks[4].action);
    print(document.bookmarks[4].destination);
    print(document.bookmarks[4].namedDestination!.destination!.location);
    print(document.bookmarks[4].namedDestination!.destination!.page);
    print(document.bookmarks[4].namedDestination!.destination!.mode);
    print(document.bookmarks[4].count);
    print(document.bookmarks[4].color);
    print(document.sections);
    //Create a new instance of the PdfTextExtractor.
    //var extractor = PdfTextExtractor(document);

    //Extract all the text from the document.
    //var text = extractor.extractText(endPageIndex: 10, startPageIndex: 0);
    //print(text);
  }

  void _printChapter() {
    if (_document == null ||
        _document!.bookmarks.count == 0 ||
        _selectedChapter == null) {
      return;
    }
    //_document!.bookmarks
  }

  Future<void> _sendTextToGpt3() async {
    if (apiKeyController.text.isNotEmpty) {
      Constants.initializeApi(apiKeyController.text);
    }
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
      answer = await Constants.api!.completion(text,
          stop: '\n\n',
          engine: Engine.curieInstruct,
          maxTokens: 64,
          temperature: 0.2,
          topP: 1);
    } on InvalidRequestException catch (e) {
      showErrorSnackBar(e, context);
      setState(() => _loading = false);
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
        apiKeyController = TextEditingController(),
        _loading = false,
        _chapterNames = [],
        _initialized = false {
    Constants.initializeApi(OPENAI_API_KEY);
  }

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
        child: Row(
          children: [
            Expanded(
              flex: 1, // 20%
              child: Container(),
            ),
            Expanded(
              flex: 8, // 60%
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
                    Row(
                      children: [
                        Expanded(child: Text(_fileName ?? '')),
                        Flexible(
                          child: TextButton(
                            onPressed: () => _openFileExplorer(),
                            child: Text('Upload PDF'),
                          ),
                        ),
                        DropdownButton<String>(
                          onChanged: (value) => setState(() {
                            _selectedChapter = value!;
                          }),
                          value: _selectedChapter,
                          hint: const Text('Which chapter?'),
                          items: _chapterNames
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
                              .toList(growable: false),
                        ),
                        TextButton(
                            onPressed: _printChapter, child: Text('DEBUG'))
                      ],
                    ),
                    Flexible(
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        minLines: 5,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Input your text here',
                        ),
                      ),
                    ),
                    Flexible(
                      child: TextField(
                        controller: apiKeyController,
                        maxLines: 1,
                        minLines: 1,
                        obscureText: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Input your API key here',
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1, // 20%
              child: Container(),
            ),
          ],
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
