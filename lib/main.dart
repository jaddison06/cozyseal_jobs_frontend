import 'package:flutter/material.dart';
import 'db.dart';
import 'surveyScreen.dart';
import 'cozysealTextInput.dart';
import 'dart:developer' as developer;
import 'dart:io';

// allow bad certificates globally
class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cozyseal Survey',
      home: StartScreen(),
      theme: ThemeData(
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
        textTheme: Typography.blackCupertino,
        accentColor: Color.fromARGB(70, 128, 128, 128),
        highlightColor: Colors.black
      ),
      darkTheme: ThemeData(
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: Color.fromARGB(255, 18, 18, 18),
        textTheme: Typography.whiteCupertino,
        accentColor: Color.fromARGB(170, 128, 128, 128),
        highlightColor: Color.fromARGB(255, 200, 200, 200)
      ),
    );
  }
}

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final database = Database();

  // Controller for the TextEdit
  final tfController = IntegerInputController();
  // Text for the Start button
  String _errorMsg = '';

  // Called when start button pressed
  void _doSurveyScreen(String unused) async {
    final jobNumberString = tfController.get();
    if (!jobNumberString.isValid ||
        jobNumberString.text.length != 5 ||
        !await database.jobExists(int.parse(jobNumberString.text))
    ) {
      setState(() {
        _errorMsg = 'Please enter a valid job number';
        });

      if (!jobNumberString.isValid) {developer.log('invalid int');}
      else if (jobNumberString.text.length != 5) {developer.log('invalid length');}
      else if (!await database.jobExists(int.parse(jobNumberString.text))) {developer.log('no such job');}

    } else {
      setState(() {
        _errorMsg = '';
      });

      tfController.clear();

      Navigator.of(context).push(
        MaterialPageRoute(builder: (BuildContext context) {
          return SurveyScreen(int.parse(jobNumberString.text));
        })
      );

    }
  }

  // Called on destroy
  @override
  void dispose() {
    tfController.dispose();
    super.dispose();
  }

  // Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cozyseal Survey')
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 60.0,
                child: Row(
                  children: [
                    // Entry field, has to be in a Flexible to
                    // determine width and a Container for
                    // reliable decoration
                    Flexible(
                      child: CozysealTextInput(
                        'Job number',
                        tfController,
                        TextInputType.number,
                        onSubmitted: _doSurveyScreen
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0)
                    ),
                    // Start button
                    /*
                    FlatButton(
                      onPressed: _doSurveyScreen,
                      //child: Text('Start'),
                      child: Icon(
                        Icons.send,
                        color: Theme.of(context).highlightColor,
                      ),
                    ),*/
                    IconButton(
                      icon: Icon(Icons.send),
                      color: Theme.of(context).highlightColor,
                      onPressed: () {_doSurveyScreen(null);}
                    )
                  ]
                )
              ),
              // Error message underneath
              Text(
                '$_errorMsg',
                style: TextStyle(
                  color: Colors.red
                ),
              )

            ]
          )
        )
      )
    );
  }
}

