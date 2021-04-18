import 'package:flutter/material.dart';
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
    color: const Color(0xde000000),
    letterSpacing: -0.48,
    fontWeight: FontWeight.w300,
    height: 1.2,
  );

  Widget _getBox(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: _boxColor,
        border: Border.all(color: _boxColor, width: 1.0),
        borderRadius: BorderRadius.all(
            Radius.circular(20.0) //         <--- border radius here
            ),
      ),
      height: MediaQuery.of(context).size.width / 10,
      width: MediaQuery.of(context).size.width / 6,
      child: Center(child: child),
    );
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
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _getBox(Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'Daily repetition',
                    style: _boxTextStyle,
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
              )),
              _getBox(Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'My Keeps',
                    style: _boxTextStyle,
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
              )),
              _getBox(Column(
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
              )),
            ],
          )),
          Expanded(child: Container()),
        ],
      ),
    );
  }
}
