import 'package:flutter/material.dart';
import 'surveyWidgets.dart';
import 'survey.dart';
import 'db.dart';
import 'job.dart';
import 'dart:developer' as developer;

class SurveyScreen extends StatefulWidget {
  final int _jobNumber;

  SurveyScreen(
      this._jobNumber,
      );

  @override
  _SurveyScreenState createState() => _SurveyScreenState(_jobNumber);
}

class _SurveyScreenState extends State<SurveyScreen> {
  final int _jobID;
  final _database = Database();
  final _controller = SurveyController();
  var _surveyItems = List<Widget>();

  bool _canRenderSurvey = false;

  String _bottomErrorText = '';

  Job job;

  _SurveyScreenState(
      this._jobID
      ) {
    _initSurveyItems();
  }

  // TODO: initialize survey items with value from server

  void _initSurveyItems() async {

    job = await _database.getJob(_jobID);

    //developer.log('Initializing survey items from job');

    for (int i = 0; i < job.items.length; i++) {
      var current = job.items[i];
      Widget item;

      var context = SurveyItemContext(current.id, current.hint, current.current, current.imageNames);

      switch (current.type) {
        case SurveyItemType.dropdown:
          {
            item = DropdownItem(current.choices, context, _controller);
          }
          break;

        case SurveyItemType.radioButtons:
          {
            item = RadioButtonsItem(current.choices, context, _controller);
          }
          break;

        case SurveyItemType.imageChoice:
          {
            item = ImageChoiceItem(current.choices, context, _controller);
          }
          break;

        case SurveyItemType.text:
          {
            item = TextItem(context, _controller);
          }
          break;

        case SurveyItemType.integer:
          {
            item = IntegerItem(context, _controller);
          }
          break;

        case SurveyItemType.decimal:
          {
            item = DecimalItem(context, _controller);
          }
          break;
      }

      _surveyItems.add(item);
    }

    setState(() {
      _canRenderSurvey = true;
    });

  }

  void _returnSurvey() {
    bool allValid = true;
    for (int i = 0; i < _controller.getItems().length; i++) {
      if (!_controller.getItems()[i].get().isValid) {
        allValid = false;
        developer.log('Invalid item: $i');
      }
    }

    if (!allValid) {
      setState(() {
        _bottomErrorText = 'Invalid items detected';
      });
      return;
    }

    _database.returnJob(_jobID, _controller.getItems());

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Cozyseal Survey')
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: ListView(
          //shrinkWrap: true,
          children: _canRenderSurvey ?
          [
            Text('Job ${job.jobNumber}'),
            Text('Address: ${job.address}'),
            Text('Resident: ${job.resident}'),
            Divider(color: Theme.of(context).accentColor),
            Survey(_surveyItems),
            Column(
              children:
                [
                  FlatButton(
                    onPressed: _returnSurvey,
                    child: Text(
                      'Submit Survey',
                      style: TextStyle(
                        color: Theme.of(context).highlightColor,
                      ),
                    ),
                    color: Theme.of(context).primaryColor,
                  ),
                  Text(
                    _bottomErrorText,
                    style: TextStyle(
                      color: Colors.red
                    ),
                  )
              ]
            )
          ] : [Text('Loading...')],
        )
      )
    );
  }
}
