

import 'dart:convert';

import 'package:expressions/expressions.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalculatorModelProvider with ChangeNotifier {
  String _output = ''; // The current output of the calculator
  String _history = ''; // Stores the history of calculations
  String _equation = ''; // Stores the equation for the red section
  bool _isEqualPressed = false; // Flag for checking if "=" was pressed
  List<Map<String, String>> _historyList = [];
  List<Map<String, String>> get historyList => _historyList;

  String get output => _output;
  String get history => _history;
  String get equation => _equation;

  bool get isEqualPressed => _isEqualPressed; // Getter for checking if '=' was pressed

  final List<String> _buttons = [
    'AC', '%', 'x', '/', '7', '8', '9', '*', '4', '5', '6', '-',
    '1', '2', '3', '+', '00', '0', '.', '='
  ];

  List<String> get buttons => _buttons;

  void buttonPressed(String buttonText) async{
    if (buttonText == 'AC') {
      // Clear all values
      _output = '';
      _history = '';
      _isEqualPressed = false;
    } else if (buttonText == 'x') {
      // Remove the last character
      if (_output.isNotEmpty) {
        _output = _output.substring(0, _output.length - 1);
      }
    } else if (buttonText == '=') {
      // Evaluate the current equation
      if (_output.isNotEmpty && !_isLastCharOperator()) {
        try {
          String result = _calculateExpression(_output);
          // Add to history
          _historyList.add({
            'equation': _output,
            'result': result,
          });
          _history = _output; // Store the current equation in history
          _output = result;  // Display the result
          _isEqualPressed = true;
          await _saveHistory();
        // Notify listeners to update the UI

        } catch (e) {
          _output = '';
        }
      } else {
        _output = '';
      }
    } else if (['/', '*', '+', '-'].contains(buttonText)) {
      // Handle operator input
      if (_isEqualPressed) {
        // Continue calculation from the current result
        _isEqualPressed = false;
        _output = _output; // Keep the result as the base
      }
      if (_output.isNotEmpty && !_isLastCharOperator()) {
        _output += buttonText;
      } else if (buttonText == '-' && _output.isEmpty) {
        // Allow '-' as the first character
        _output += buttonText;
      }
    } else if (buttonText == '.') {
      // Handle decimal input
      if (_output.isEmpty || _isLastCharOperator()) {
        _output += '0.';
      } else if (!_getLastNumber().contains('.')) {
        _output += buttonText;
      }
    } else {
      // Handle number input
      if (_isEqualPressed) {
        // Reset output if '=' was pressed earlier
        _output = '';
        _isEqualPressed = false;
      }
      _output += buttonText;
    }

    notifyListeners();
  }
  void setOutput(String value) {
    _output = value;
    notifyListeners();
  }
  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedHistory = jsonEncode(_historyList); // Convert history to JSON string
    await prefs.setString('calculatorHistory', encodedHistory);
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final savedHistory = prefs.getString('calculatorHistory');
    if (savedHistory != null) {
      try {
        // Decode the saved JSON string
        final decodedData = jsonDecode(savedHistory) as List<dynamic>;

        // Safely convert to List<Map<String, String>>
        _historyList = decodedData.map((item) {
          return Map<String, String>.from(
            item.map((key, value) => MapEntry(key.toString(), value.toString())),
          );
        }).toList();

        notifyListeners(); // Notify listeners to update the UI
      } catch (e) {
        print('Error loading history: $e');
        _historyList = []; // Fallback to an empty list
      }
    }
  }

  CalculatorModelProvider() {
    _loadHistory();
  }

  void clearHistory() {
    _historyList.clear();
    notifyListeners();
  }


  // Load history from local storage

  bool _isLastCharOperator() {
    if (_output.isEmpty) return false;
    final operators = ['/', '*', '-', '+', '%'];
    return operators.contains(_output[_output.length - 1]);
  }

  String _getLastNumber() {
    final regex = RegExp(r'[\d\.]+$');
    final match = regex.firstMatch(_output);
    return match?.group(0) ?? '';
  }

  String _calculateExpression(String expression) {
    try {
      // Handle percentage and modulo logic
      expression = expression.replaceAllMapped(RegExp(r'(\d+)\%'), (match) {
        double num = double.parse(match.group(1)!);
        return (num / 100).toString();
      });

      final expressionToEvaluate = Expression.parse(expression);
      final evaluator = ExpressionEvaluator();
      final result = evaluator.eval(expressionToEvaluate, {});
      return result.toString();
    } catch (e) {
      return '';
    }
  }
}

