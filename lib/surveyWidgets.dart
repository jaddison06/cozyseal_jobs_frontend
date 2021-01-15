import 'package:flutter/material.dart';
import 'cozysealTextInput.dart';
import 'dart:developer' as developer;

// TODO: can initialise with value

// ------------------ SURVEY ITEMS: BOILERPLATE ------------------

// public so we can make a list of them
abstract class SurveyItem<OutputType> extends StatefulWidget {
  final SurveyItemContext _context;
  final SurveyController _controller;

  SurveyItem(
      this._context,
      this._controller,
      );
}

abstract class _MultipleChoiceItem extends SurveyItem<String> {
  final List<String> _choices;

  _MultipleChoiceItem(
      this._choices,
      context,
      controller
      ): super(context, controller);
}

class DropdownItem extends _MultipleChoiceItem {
  DropdownItem(
      choices,
      context,
      controller
      ): super(choices, context, controller);

  @override
  _DropdownItemState createState() => _DropdownItemState(_choices, _context, _controller);
}

class RadioButtonsItem extends _MultipleChoiceItem {
  RadioButtonsItem(
      choices,
      context,
      controller
      ): super(choices, context, controller);

  @override
  _RadioButtonsItemState createState() => _RadioButtonsItemState(_choices, _context, _controller);
}

class ImageChoiceItem extends _MultipleChoiceItem {
  ImageChoiceItem(
      choices,
      context,
      controller
      ): super(choices, context, controller);

  @override
  _ImageChoiceItemState createState() => _ImageChoiceItemState(_choices, _context, _controller);
}

abstract class _AbstractTextItem<OutputType> extends SurveyItem<OutputType> {
  _AbstractTextItem(
      context,
      controller
      ): super(context, controller);
}

class IntegerItem extends _AbstractTextItem<int> {
  IntegerItem(
      context,
      controller
      ): super(context, controller);

  @override
  _IntegerItemState createState() => _IntegerItemState(_context, _controller);
}

class DecimalItem extends _AbstractTextItem<double> {
  DecimalItem(
      context, controller
      ): super(context, controller);

  @override
  _DecimalItemState createState() => _DecimalItemState(_context, _controller);
}

class TextItem extends _AbstractTextItem<String> {
  TextItem(
      context,
      controller
      ): super(context, controller);

  @override
  _TextItemState createState() => _TextItemState(_context, _controller);
}

// ------------------ SURVEY ITEMS: ABSTRACT/INHERITED CLASSES ------------------

abstract class SurveyItemState<OutputType> extends State<SurveyItem<OutputType>> {
  final SurveyItemContext _context;
  final SurveyController _controller;

  SurveyItemState(
      this._context,
      this._controller
      ) {
    _controller.addItem(this);
  }

  int getID() => _context.id;

  Validated<OutputType> get();
}

abstract class _MultipleChoiceItemState extends SurveyItemState<String> {
  final List<String> _choices;
  String _current;


  // get Validated of current. usually current should
  // be _current, but in an _ImageChoiceItemState everything
  // has a different name
  Validated<String> _get(String current) {
    bool valid = current != null;
    return Validated(
      valid,
      valid ? current : ''
    );
  }

  // override this
  Validated<String> get() => _get(_current);

  _MultipleChoiceItemState(
      this._choices,
      context,
      controller
  ): super(context, controller) {
    // this could be null, it's a concrete responsibility to
    // test for this if required.
    _current = _context.current;
  }

}

// generic text input
abstract class _AbstractTextItemState<OutputType> extends SurveyItemState<OutputType> {

  // init this at concrete level
  ScopedTextEditingController _editingController;


  _AbstractTextItemState(
      context,
      controller
      ): super(context, controller);

  // only call this once _editingController has been initialized
  void _setInitialValue() {
    _editingController.text = _context.current ?? '';
  }

  TextInputType _getInputType();

  @override
  Widget build(BuildContext context) {
    return CozysealTextInput(_context.hint, _editingController, _getInputType());
  }

}

// ------------------ SURVEY ITEMS: CONCRETE CLASSES ------------------

class SurveyItemContext {
  int id;
  String hint;
  String current;
  Map<String, String> imageNames;

  SurveyItemContext(
      this.id,
      this.hint,
      this.current,
      this.imageNames
      );
}

class SurveyController {
  var _items = Map<int, SurveyItemState>();


  void addItem(SurveyItemState item) {
    var id = item.getID();

    if (_items.containsKey(id)) { developer.log('Warning: key $id already exists'); }
    else { _items[id] = item; }
  }

  Map<int, SurveyItemState> getItems() => _items;

}

// Dropdown box
class _DropdownItemState extends _MultipleChoiceItemState {

  _DropdownItemState(
      choices,
      context,
      controller
      ): super(choices, context, controller) {
    _current ??= _choices[0];
  }

  //Validated<String> get() => Validated(true, _current);

  List<DropdownMenuItem> _generateMenuItems() {
    return _choices.map((String val) {
      return DropdownMenuItem(
          value: val,
          child: Text(
            val,
          )
      );
    }).toList();
  }

  void _onDropdownChanged(String newVal) {
    setState(() {
      _current = newVal;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ListTile is nice bc we get leading & title
    return ListTile(
        leading: Text(_context.hint),
        title: DropdownButton<String>(
          value: _current,
          items: _generateMenuItems(),
          onChanged: _onDropdownChanged,
          dropdownColor: Colors.grey,
          underline: Container(height: 0),
        )
    );
  }
}

// Radio buttons
class _RadioButtonsItemState extends _MultipleChoiceItemState {
  _RadioButtonsItemState(
      choices,
      context,
      controller
      ): super(choices, context, controller);

  Widget _generateTitle(String choice) {
    return Text(choice);
  }

  List<Widget> _generateTiles() {
    var r = List<Widget>();
    r += [
      Text(_context.hint),
      Padding(padding: EdgeInsets.fromLTRB(20, 0, 0, 0))
    ];

    for (int i = 0; i < _choices.length; i++) {
      r += [
        RadioListTile(
          value: _choices[i],
          groupValue: _current,
          onChanged: (String value) {
            setState(() {
              _current = value;
            });
          },
          title: _generateTitle(_choices[i]),
          activeColor: Theme.of(context).highlightColor,

        ),
        //Text(_choices[i]),
        Padding(padding: EdgeInsets.fromLTRB(15, 0, 0, 0))
      ];
    }

    return r;
  }

  Widget build(BuildContext context) {
    /*
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _generateTiles(),
      )
    );*/
    return Wrap(
        children: _generateTiles()
    );
  }
}

/*
// Shows some images to the user and allows them to select one
class _ImageChoiceItemState extends _MultipleChoiceItemState {
  _ImageChoiceItemState(
      choices,
      context,
      controller
      ): super(choices, context, controller);

  String get() {}

  Widget build(BuildContext context) {
    return Image.asset('test_images/image_2.jpg');
  }
}*/

class _ImageChoiceItemState extends _RadioButtonsItemState {
  _ImageChoiceItemState(
      choices,
      context,
      controller
      ): super(choices, context, controller) {
    //developer.log(_current);
    //developer.log(_context.imageNames.toString());
    //developer.log(_choices.toString());
  }


  @override
  Validated<String> get() => _get(_context.imageNames[_current]);

  @override
  Widget _generateTitle(String choice) {
    //developer.log(choice);
    //developer.log(_context.imageNames.toString());

    //NetworkImage(choice);
    return Image.network(choice);
    //return Text('yeet');
  }
}

// Allow the user to input an integer
class _IntegerItemState extends _AbstractTextItemState<int> {
  _IntegerItemState(
      context,
      controller
      ): super(context, controller) {
    _editingController = IntegerInputController();
    _setInitialValue();
  }

  TextInputType _getInputType() => TextInputType.number;

  Validated<int> get() {
    Validated<String> current = _editingController.get();
    return Validated(
        current.isValid,
        current.isValid ? int.parse(current.text) : 0
    );
  }
}

// Allow any number
class _DecimalItemState extends _AbstractTextItemState<double> {
  _DecimalItemState(
      context,
      controller
      ): super(context, controller) {
    _editingController = DecimalInputController();
    _setInitialValue();
  }

  TextInputType _getInputType() => TextInputType.number;

  Validated<double> get() {
    Validated<String> current = _editingController.get();
    return Validated(
        current.isValid,
        current.isValid ? double.parse(current.text) : 0
    );
  }
}

// Text input. Starts at startHeight _lines_
// high, defaults to 1
class _TextItemState extends _AbstractTextItemState<String> {
  _TextItemState(
      context,
      controller
      ): super(context, controller) {
    _editingController = TextInputController();
    _setInitialValue();
  }

  TextInputType _getInputType() => TextInputType.text;

  Validated<String> get() => _editingController.get();

}