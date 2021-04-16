import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LandingPage extends StatelessWidget {
  LandingPage({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      body: Stack(
        children: <Widget>[
          // Adobe XD layer: 'pexels-ena-marinkov…' (shape)
          Container(
            width: 1920.0,
            height: 1080.0,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage(''),
                fit: BoxFit.cover,
              ),
              border: Border.all(width: 1.0, color: const Color(0xff707070)),
            ),
          ),
          // Adobe XD layer: 'pexels-ena-marinkov…' (shape)
          ClipRect(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
              child: Container(
                width: 1920.0,
                height: 1080.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage(''),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.0), BlendMode.dstIn),
                  ),
                  border:
                      Border.all(width: 1.0, color: const Color(0xff707070)),
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(298.9, 150.0),
            child: SizedBox(
              width: 1322.0,
              child: Text(
                'Do you want to remember the things you read?',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 60,
                  color: const Color(0xde000000),
                  letterSpacing: -0.48,
                  fontWeight: FontWeight.w300,
                  height: 1.2,
                ),
                textHeightBehavior:
                    TextHeightBehavior(applyHeightToFirstAscent: false),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Container(),
          Transform.translate(
            offset: Offset(389.1, 342.0),
            child: SizedBox(
              width: 1142.0,
              child: Text(
                'Quiz yourself on the article you just read:',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 60,
                  color: const Color(0xde000000),
                  letterSpacing: -0.48,
                  fontWeight: FontWeight.w300,
                  height: 1.2,
                ),
                textHeightBehavior:
                    TextHeightBehavior(applyHeightToFirstAscent: false),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(160.5, 598.5),
            child: SvgPicture.string(
              _svg_nt4vky,
              allowDrawingOutsideViewBox: true,
            ),
          ),
          Transform.translate(
            offset: Offset(917.0, 567.0),
            child: SizedBox(
              width: 86.0,
              child: Text(
                'OR',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 48,
                  color: const Color(0xde000000),
                  height: 1.1666666666666667,
                ),
                textHeightBehavior:
                    TextHeightBehavior(applyHeightToFirstAscent: false),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(1060.5, 598.5),
            child: SvgPicture.string(
              _svg_ub41fg,
              allowDrawingOutsideViewBox: true,
            ),
          ),
          Container(),
          Transform.translate(
            offset: Offset(569.5, 652.0),
            child: SizedBox(
              width: 781.0,
              child: Text(
                'Simply paste your text here:',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 60,
                  color: const Color(0xde000000),
                  letterSpacing: -0.48,
                  fontWeight: FontWeight.w300,
                  height: 1.2,
                ),
                textHeightBehavior:
                    TextHeightBehavior(applyHeightToFirstAscent: false),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const String _svg_nt4vky =
    '<svg viewBox="160.5 598.5 700.0 1.0" ><path transform="translate(160.5, 598.5)" d="M 0 0 L 700 0" fill="none" stroke="#707070" stroke-width="5" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_ub41fg =
    '<svg viewBox="1060.5 598.5 700.0 1.0" ><path transform="translate(1060.5, 598.5)" d="M 0 0 L 700 0" fill="none" stroke="#707070" stroke-width="5" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
