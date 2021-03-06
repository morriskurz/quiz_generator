import 'package:flutter/material.dart';
import 'package:openai_gpt3_api/invalid_request_exception.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:quiz_generator/utils/constants.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _boxColor = const Color(0xFFF3F3F3);
  final _boxTextStyle = const TextStyle(
    fontFamily: 'Roboto',
    fontSize: 30,
    color: Color(0xde000000),
    letterSpacing: -0.48,
    fontWeight: FontWeight.w300,
    height: 1.2,
  );

  Widget _getBox(Widget child) {
    var screenWidth = MediaQuery.of(context).size.width;
    var width = MediaQuery.of(context).orientation == Orientation.portrait
        ? screenWidth / 2
        : screenWidth / 6;
    var height = MediaQuery.of(context).orientation == Orientation.portrait
        ? screenWidth / 3
        : screenWidth / 10;
    return Container(
      decoration: BoxDecoration(
        color: _boxColor,
        border: Border.all(color: _boxColor, width: 1.0),
        borderRadius: BorderRadius.all(
            Radius.circular(20.0) //         <--- border radius here
            ),
      ),
      height: height,
      width: width,
      child: Center(child: child),
    );
  }

  void _myKeeps() {
    showErrorSnackBar(
        InvalidRequestException('Sorry, this feature is not implemented yet.'),
        context);
  }

  void _dailyRepetition() {
    showErrorSnackBar(
        InvalidRequestException('Sorry, this feature is not implemented yet.'),
        context);
  }

  void _addAKeep() {
    Navigator.pushNamed(context, '/');
  }

  /// Don't judge, short time to code
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'Welcome back!',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 40,
                  color: const Color(0xde000000),
                  letterSpacing: -0.48,
                  fontWeight: FontWeight.w300,
                  height: 1.2,
                ),
              ),
            ),
          ),
          Expanded(
              child: MediaQuery.of(context).orientation == Orientation.portrait
                  ? Column(
                      children: _getBoxes(),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _getBoxes(),
                    )),
          Expanded(child: Container()),
        ],
      ),
    );
  }

  List<Widget> _getBoxes() {
    return [
      _getBox(ElevatedButton(
        style:
            ButtonStyle(backgroundColor: MaterialStateProperty.all(_boxColor)),
        onPressed: _dailyRepetition,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Center(
              child: Text(
                'Daily repetition',
                style: _boxTextStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: LinearPercentIndicator(
                animation: true,
                linearGradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 0, 116, 252),
                    Color.fromARGB(255, 0, 255, 159),
                  ],
                ),
                lineHeight: 20.0,
                animationDuration: 500,
                percent: 0.7,
                center: Text('70%'),
              ),
            ),
          ],
        ),
      )),
      _getBox(ElevatedButton(
        style:
            ButtonStyle(backgroundColor: MaterialStateProperty.all(_boxColor)),
        onPressed: _myKeeps,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Center(
              child: Text(
                'My Keeps',
                style: _boxTextStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  height: MediaQuery.of(context).size.width / 20,
                  width: MediaQuery.of(context).size.width / 12,
                  child: Image.asset(
                    'keeps.png',
                    fit: BoxFit.scaleDown,
                  )),
            ),
          ],
        ),
      )),
      _getBox(ElevatedButton(
        style:
            ButtonStyle(backgroundColor: MaterialStateProperty.all(_boxColor)),
        onPressed: _addAKeep,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Center(
                child: Text(
                  'Add a Keep',
                  style: _boxTextStyle,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(bottom: 15),
              height: MediaQuery.of(context).size.width / 20,
              width: MediaQuery.of(context).size.width / 12,
              child: Image.asset(
                'add.png',
                fit: BoxFit.scaleDown,
              ),
            ),
          ],
        ),
      )),
    ];
  }
}
