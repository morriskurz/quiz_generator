import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

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
    setState(() => _loading = true);
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
      print(e.toString());
      showErrorSnackBar(
          InvalidRequestException(
              'Unable to reach the service. Please try again later. ' +
                  e.toString()),
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
        'What are some key points I should know when studying this text:\n\"\"\"' +
            text +
            '\n\"\"\"\n1.';
    var words = text.split(' ');
    var numberOfWords = words.length;
    setState(() => _loading = true);
    CompletionApiResult answers;
    CompletionApiResult questions;
    try {
      answers = await Constants.api!.completion(text,
          stop: '\n\n',
          engine: Engine.curieInstruct,
          maxTokens: 64,
          temperature: 0.4,
          frequencyPenalty: 0.1,
          presencePenalty: 0.1,
          topP: 1);
      var keyPoints = answers.choices.first.text;
      text = 'Formulate questions to these statements:\n\"\"\"' +
          keyPoints +
          '\n\"\"\"\n1.';
      questions = await Constants.api!.completion(text,
          stop: '\n\n',
          engine: Engine.curieInstruct,
          maxTokens: 64,
          temperature: 0.4,
          frequencyPenalty: 0.1,
          presencePenalty: 0.1,
          topP: 1);
    } on InvalidRequestException catch (e) {
      showErrorSnackBar(e, context);
      setState(() => _loading = false);
      return;
    }
    var questionsString = '1.' + questions.choices.first.text;
    var answersString = '1.' + answers.choices.first.text;
    print(questionsString);
    print(answersString);
    var questionsList = questionsString.split('\n');
    var answersList = answersString.split('\n');
    // Ensure both have same size
    questionsList.length = min(questionsList.length, answersList.length);
    answersList.length = min(questionsList.length, answersList.length);
    await Navigator.pushNamed(context, '/qa',
        arguments: QuestionPageArguments(questionsList, answersList));
    setState(() => _loading = false);
  }

  Future<UserCredential> _signInWithGoogle() async {
    // Create a new provider
    var googleProvider = GoogleAuthProvider();

    googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithPopup(googleProvider);

    // Or use signInWithRedirect
    // return await FirebaseAuth.instance.signInWithRedirect(googleProvider);
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
    if (!_initialized) {
      return LoadingOverlay(isLoading: true, child: Container());
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (_initialized) {
                _signInWithGoogle();
              }
            },
            child: Text('LOG IN'),
          )
        ],
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
                child: Column(
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
      ),
    );
  }
}
