import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:openai_gpt3_api/invalid_request_exception.dart';
import 'package:openai_gpt3_api/openai_gpt3_api.dart';

class Constants {
  static GPT3? api;

  static void initializeApi(String apiKey) {
    api = GPT3(apiKey);
  }
}

Future navigateToHome(BuildContext context) {
  return Navigator.of(context)
      .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
}

/// Returns the app's default snackbar with a [text].
SnackBar getGenericSnackBar(String text, bool isError) {
  return SnackBar(
    content: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: isError ? Colors.red : Colors.white,
        fontSize: 16.0,
      ),
    ),
  );
}

void showErrorSnackBar(InvalidRequestException e, BuildContext context) {
  ScaffoldMessenger.of(context)
      .showSnackBar(getGenericSnackBar(e.message, true));
}

Future<UserCredential> signInWithGoogle() async {
  // Create a new provider
  var googleProvider = GoogleAuthProvider();

  googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

  // Once signed in, return the UserCredential
  return await FirebaseAuth.instance.signInWithPopup(googleProvider);

  // Or use signInWithRedirect
  // return await FirebaseAuth.instance.signInWithRedirect(googleProvider);
}

Widget buildFloatingSearchBar(BuildContext context) {
  final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

  return FloatingSearchBar(
    hint: 'Search for a book...',
    scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
    transitionDuration: const Duration(milliseconds: 200),
    transitionCurve: Curves.easeInOut,
    physics: const BouncingScrollPhysics(),
    axisAlignment: 0,
    openAxisAlignment: 0.0,
    width: isPortrait ? 600 : 500,
    debounceDelay: const Duration(milliseconds: 200),
    onQueryChanged: (query) {
      // Call your model, bloc, controller here.
    },
    // Specify a custom transition to be used for
    // animating between opened and closed stated.
    transition: CircularFloatingSearchBarTransition(),
    actions: [
      FloatingSearchBarAction(
        showIfOpened: false,
        child: CircularButton(
          icon: const Icon(Icons.search),
          onPressed: () {},
        ),
      ),
      FloatingSearchBarAction.searchToClear(
        showIfClosed: false,
      ),
    ],
    builder: (context, transition) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Material(
          color: Colors.white,
          elevation: 4.0,
          child: Container(
              height: 112,
              child: Center(
                  child: Text(
                'Sorry, no books saved yet. You can add one below.',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 20,
                  color: Color(0xde000000),
                  letterSpacing: -0.48,
                  fontWeight: FontWeight.w300,
                  height: 1.2,
                ),
              ))),
        ),
      );
    },
  );
}

final boxTextStyle = const TextStyle(
  fontFamily: 'Roboto',
  fontSize: 30,
  color: Color(0xde000000),
  letterSpacing: -0.48,
  fontWeight: FontWeight.w300,
  height: 1.2,
);
final boxColor = const Color(0xFFF3F3F3);

Widget textDivider(String text) {
  return Row(children: <Widget>[
    Expanded(
      child: new Container(
          margin: const EdgeInsets.only(left: 10.0, right: 20.0),
          child: Divider()),
    ),
    Text(text,
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 20,
          color: Color(0xae000000),
          letterSpacing: -0.48,
          fontWeight: FontWeight.w300,
          height: 1.2,
        )),
    Expanded(
      child: new Container(
          margin: const EdgeInsets.only(left: 20.0, right: 10.0),
          child: Divider()),
    ),
  ]);
}
