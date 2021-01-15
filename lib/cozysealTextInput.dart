import 'package:flutter/material.dart';

// ------------------ COZYSEALTEXTINPUT & CONTROLLERS ------------------

// a text input w/ proper formatting
class CozysealTextInput extends StatefulWidget {
  final String _hintText;
  final TextEditingController _controller;
  final TextInputType _inputType;
  ValueChanged<String> _onSubmitted;

  CozysealTextInput(
      this._hintText,
      this._controller,
      this._inputType,
      {
        ValueChanged<String> onSubmitted
      }
      ) {
    this._onSubmitted = onSubmitted;
  }

  _CozysealTextInputState createState() => _CozysealTextInputState(_hintText, _controller, _inputType, _onSubmitted);

}

class _CozysealTextInputState extends State<CozysealTextInput> {
  final String _hintText;
  final TextEditingController _controller;
  final TextInputType _inputType;
  ValueChanged<String> _onSubmitted;

  _CozysealTextInputState(
      this._hintText,
      this._controller,
      this._inputType,
      this._onSubmitted
      );

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            border: Border.all(
                color: Theme
                    .of(context)
                    .accentColor
            ),
            borderRadius: BorderRadius.all(Radius.circular(15))
        ),
        child: Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                  border: null,
                  hintText: _hintText,
                  hintStyle: TextStyle(
                      color: Theme
                          .of(context)
                          .accentColor
                  )
              ),
              keyboardType: _inputType,
              controller: _controller,
              onSubmitted: _onSubmitted,
            )
        )
    );
  }
}

class Validated<type> {
  final bool isValid;
  final type text;

  Validated(
      this.isValid,
      this.text
      );
}

abstract class ScopedTextEditingController extends TextEditingController {
  bool isValid();

  Validated<String> get() {
    return Validated(
        isValid(),
        text
    );
  }
}

abstract class NumberInputController extends ScopedTextEditingController {
  bool _isNumber() {
    return double.tryParse(text) != null;
  }

  bool _isInt() {
    return _isNumber() && (int.tryParse(text) == double.tryParse(text));
  }
}

class IntegerInputController extends NumberInputController {
  bool isValid() => _isInt();
}

class DecimalInputController extends NumberInputController {
  bool isValid() => _isNumber();
}

class TextInputController extends ScopedTextEditingController {
  bool isValid() => true;
}