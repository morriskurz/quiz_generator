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
import 'package:quiz_generator/ProfilePage.dart';
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
      onGenerateRoute: (RouteSettings settings) {
        var routes = <String, WidgetBuilder>{
          '/': (ctx) => MyHomePage(),
          '/profile': (ctx) => ProfilePage(),
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
        .then((value) => {print('Book Added'), keepnumber++})
        .catchError((error) => print('Failed to add book: $error'));
  }

  void _openFileExplorer() async {
    setState(() => _loading = true);
    try {
      _paths = (await FilePicker.platform.pickFiles(
        type: _pickingType,
        allowMultiple: false,
        allowedExtensions: ['pdf'],
      ))
          ?.files;
    } on PlatformException catch (e) {
      print('Unsupported operation' + e.toString());
    } catch (ex) {
      print(ex);
    }
    if (!mounted) {
      setState(() => _loading = false);
      return;
    }
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
    if (_paths == null) {
      setState(() => _loading = false);
      return;
    }
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
      showErrorSnackBar(
          InvalidRequestException(
              'Please select a document and chapter first.'),
          context);
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
            ((numberOfWords > 1200)
                ? text.substring(0, min(numberOfWords * 4, 6000))
                : text) +
            '\n\"\"\"\n1.';

    setState(() => _loading = true);
    CompletionApiResult answers;
    CompletionApiResult questions;
    try {
      answers = await Constants.api!.completion(text,
          stop: '\n\n',
          engine: Engine.curieInstruct,
          maxTokens: 100,
          temperature: 0.02,
          frequencyPenalty: 0.15,
          presencePenalty: 0.15,
          topP: 1);
      var keyPoints = answers.choices.first.text;
      text = 'Formulate questions to these statements:\n\"\"\"' +
          keyPoints +
          '\n\"\"\"\n1.';
      questions = await Constants.api!.completion(text,
          stop: '\n\n',
          engine: Engine.davinciInstruct,
          maxTokens: 200,
          temperature: 0,
          frequencyPenalty: 0.0,
          presencePenalty: 0.2,
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
      appBar: getAppBar(context),
      body: LoadingOverlay(
        isLoading: _loading,
        child: Stack(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2, // 20%
                  child: Container(),
                ),
                Expanded(
                  flex: 6, // 60%
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(height: 30),
                        textDivider('OR'),
                        Text('Copy a text', style: boxTextStyle),
                        Flexible(
                          child: TextField(
                            controller: controller,
                            keyboardType: TextInputType.multiline,
                            maxLines: 4,
                            minLines: 4,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Input your text here',
                            ),
                          ),
                        ),
                        textDivider('OR'),
                        Container(
                          decoration: BoxDecoration(
                            color: boxColor,
                            border: Border.all(color: boxColor, width: 1.0),
                            borderRadius: BorderRadius.all(Radius.circular(
                                    20.0) //         <--- border radius here
                                ),
                          ),
                          height: MediaQuery.of(context).size.width / 10,
                          width: MediaQuery.of(context).size.width / 6,
                          child: Center(
                              child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(boxColor)),
                            onPressed: _openFileExplorer,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Center(
                                  child: Text(
                                    _fileName ?? 'Upload PDF',
                                    overflow: TextOverflow.clip,
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: min(
                                          MediaQuery.of(context).size.width /
                                              40,
                                          MediaQuery.of(context).size.height /
                                              40),
                                      color: Color(0xde000000),
                                      letterSpacing: -0.48,
                                      fontWeight: FontWeight.w300,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Icon(Icons.file_upload,
                                      color: Colors.black87,
                                      size: min(
                                        MediaQuery.of(context).size.width / 20,
                                        MediaQuery.of(context).size.height / 10,
                                      )),
                                ),
                              ],
                            ),
                          )),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
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
                                onPressed: _printChapter,
                                child: Text('GENERATE'))
                          ],
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
                  flex: 2, // 20%
                  child: Container(),
                ),
              ],
            ),
            Center(
              child: Container(child: buildFloatingSearchBar(context)),
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
