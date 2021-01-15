import 'package:flutter/material.dart';

class Survey extends StatefulWidget {
  final List<Widget> _surveyItems;

  Survey(
      this._surveyItems
      );

  @override
  _SurveyState createState() => _SurveyState(_surveyItems);
}

class _SurveyState extends State<Survey> {

  List<Widget> _surveyItems;

  _SurveyState(
      this._surveyItems
      );

  List<Widget> _insertDividers() {
    var r = List<Widget>();
    for (int i = 0; i < _surveyItems.length; i++) {
      if (i != 0) {
        r.add(Divider(color: Theme.of(context).accentColor));
      }
      r.add(_surveyItems[i]);
    }

    return r;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
          children: _insertDividers()
      )
    );
  }
}
