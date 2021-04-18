import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:firebase_messaging/firebase_messaging.dart';

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
      onGenerateRoute: (RouteSettings settings) {
        var routes = <String, WidgetBuilder>{
          '/': (ctx) => MyHomePage(),
          '/qa': (ctx) => QuestionPage(
                args: settings.arguments as QuestionPageArguments?,
              ),
        };
        var builder = routes[settings.name];
        return MaterialPageRoute(builder: (ctx) => builder!(ctx));
      },
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController controller;
  TextEditingController apiKeyController;
  bool _loading;
  bool _initialized;
  // CollectionReference called books that references the firestore collection
  CollectionReference keeps = FirebaseFirestore.instance.collection('books');

  // File picking
  final _pickingType = FileType.custom;
  List<PlatformFile>? _paths;
  String? _fileName;

  // PDF extraction
  List<String> _chapterNames;
  int? _selectedChapterIndex;
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

  Future<void> addKeep(List<String> questionsList, List<String> answersList) {
    //List of all questions and answers
    var questionsAndAnswersMap = <String, String>{};
    var keepnumber = 0;

    var iterator = 0;
    for (final question in questionsList) {
      questionsAndAnswersMap[question] = answersList[iterator++];
    }

    // Call the user's CollectionReference to add a new user
    return keeps
        .doc('keep' + keepnumber.toString())
        .set({
          'questions_answers': questionsAndAnswersMap,
          'timesCorrect': 0,
          'timesWrong': 0
        })
        .then((value) => {print('Book Added'),keepnumber++})
        .catchError((error) => print('Failed to add book: $error'));
  }

  void _openFileExplorer() async {
    setState(() => _loading = true);
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
    setState(() => _loading = false);
    if (_document!.bookmarks.count == 0) {
      showErrorSnackBar(
          InvalidRequestException(
              'Sorry, this book does not contain bookmarks.'),
          context);
      return;
    }
    print(_chapterNames);
    print(document.bookmarks[0].title);
    print(document.bookmarks[0].action);
    print(document.bookmarks[0].destination);
    print(document.bookmarks[0].count);
    print(document.bookmarks[0].color);
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
        _selectedChapterIndex == null) {
      return;
    }
    PdfPage firstPage;
    if (_document!.bookmarks[_selectedChapterIndex!].namedDestination == null) {
      firstPage =
          _document!.bookmarks[_selectedChapterIndex!].destination!.page;
    } else {
      firstPage = _document!.bookmarks[_selectedChapterIndex!].namedDestination!
          .destination!.page;
    }
    PdfPage lastPage;
    if (_selectedChapterIndex! < _document!.bookmarks.count - 1) {
      if (_document!.bookmarks[_selectedChapterIndex! + 1].namedDestination ==
          null) {
        lastPage =
            _document!.bookmarks[_selectedChapterIndex! + 1].destination!.page;
      } else {
        lastPage = _document!.bookmarks[_selectedChapterIndex! + 1]
            .namedDestination!.destination!.page;
      }
    } else {
      lastPage = _document!.pages[_document!.pages.count - 1];
    }
    var indexOfFirstPage = (_document!.pages.indexOf(firstPage));
    var indexOfLastPage = (_document!.pages.indexOf(lastPage));
    print('First page $indexOfFirstPage, last page $indexOfLastPage');
    var extractor = PdfTextExtractor(_document!);
    var text = extractor.extractText(
        endPageIndex: indexOfLastPage - 1, startPageIndex: indexOfFirstPage);
    print(text);
    _sendTextToGpt3(text);
  }

  Future<void> _sendTextToGpt3(String text) async {
    if (apiKeyController.text.isNotEmpty) {
      Constants.initializeApi(apiKeyController.text);
    }
    var words = text.split(' ');
    var numberOfWords = words.length;
    print('Nr of words: $numberOfWords');
    text =
        'What are some key points I should know when studying this text:\n\"\"\"' +
            text.substring(0, min(numberOfWords * 4, 6000)) +
            '\n\"\"\"\n1.';

    setState(() => _loading = true);
    CompletionApiResult answers;
    CompletionApiResult questions;
    try {
      answers = await Constants.api!.completion(text,
          stop: '\n\n',
          engine: Engine.curieInstruct,
          maxTokens: 100,
          temperature: 0.5,
          frequencyPenalty: 0.15,
          presencePenalty: 0.15,
          topP: 1);
      var keyPoints = answers.choices.first.text;
      text = 'Formulate questions to these statements:\n\"\"\"' +
          keyPoints +
          '\n\"\"\"\n1.';
      questions = await Constants.api!.completion(text,
          stop: '\n\n',
          engine: Engine.curieInstruct,
          maxTokens: 100,
          temperature: 0.4,
          frequencyPenalty: 0.15,
          presencePenalty: 0.15,
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

    //save Lists for database
    await addKeep(questionsList, answersList);

    await Navigator.pushNamed(context, '/qa',
        arguments: QuestionPageArguments(questionsList, answersList));
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
    if (!_initialized) {
      return LoadingOverlay(isLoading: true, child: Container());
    }
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
              if (_initialized) {
                signInWithGoogle();
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
                        DropdownButton<int>(
                          onChanged: (value) => setState(() {
                            _selectedChapterIndex = value!;
                          }),
                          value: _selectedChapterIndex,
                          hint: const Text('Which chapter?'),
                          items: _chapterNames
                              .map((e) => DropdownMenuItem(
                                  value: _chapterNames.indexOf(e),
                                  child: Text(e)))
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
        onPressed: () => _sendTextToGpt3(controller.text),
        tooltip: 'Send',
        child: Icon(Icons.send),
      ),
    );
  }
}
