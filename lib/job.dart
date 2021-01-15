import 'dart:io';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:cozyseal_survey/db.dart';

enum SurveyItemType {
  dropdown,
  radioButtons,
  imageChoice,
  text,
  integer,
  decimal
}

class SurveyItemData {
  int id;
  SurveyItemType type;
  String hint;
  String current;

  // these two can be null if you've got an
  // item that doesn't use them
  List<String> choices;
  Map<String, String> imageNames;

  SurveyItemData(
      this.id,
      this.type,
      this.hint,
      this.current,
      this.choices,
      this.imageNames
      );
}


// wrap a job.json file in a typesafe way
class Job {
  int jobNumber;
  String address;
  String resident;
  var items = List<SurveyItemData>();


  Future<void> loadString(Future<String> data) async {

    var job = jsonDecode(await data);

    jobNumber = job['id'];
    address = job['address'];
    resident = job['resident'];

    developer.log('items');

    var itemsRaw = job['survey'];
    for (int i = 0; i < itemsRaw.length; i++) {
      SurveyItemType type;
      String hint;
      List<String> choices = [];

      switch(itemsRaw[i]['type']) {
        case 'dropdown': { type = SurveyItemType.dropdown; }
        break;

        case 'radioButtons': { type = SurveyItemType.radioButtons; }
        break;

        case 'imageChoice': { type = SurveyItemType.imageChoice; }
        break;

        case 'text': { type = SurveyItemType.text; }
        break;

        case 'integer': { type = SurveyItemType.integer; }
        break;

        case 'decimal': { type = SurveyItemType.decimal; }
        break;
      }

      hint = itemsRaw[i]['hint'];
      var choicesRaw = itemsRaw[i]['choices'];
      // we want to initialize everything with a string, they'll give back an int regardless
      var current = itemsRaw[i]['result']['value'].toString();
      Map<String, String> imageNames = (type == SurveyItemType.imageChoice) ? Map<String, String>() : null;

      if (choicesRaw != null) {
        for (int j = 0; j < choicesRaw.length; j++) {
          if (type == SurveyItemType.imageChoice) {
            var choice = choicesRaw[j];
            String url = '${Database.SERVER}:${Database.PORT}/jobs/retrieveAsset?jobID=$jobNumber&assetName=$choice';
            choices.add(url);
            imageNames[url] = choice;
            if (current == choice) { current = url; }
          } else {
            choices.add(choicesRaw[j]);
          }
        }
      }

      items.add(
          SurveyItemData(i, type, hint, current, choices, imageNames)
      );
    }
  }
}