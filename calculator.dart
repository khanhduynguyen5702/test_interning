import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String input = '';
  String output = '';
  List<String> calculationHistory = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Calculator'),
        actions: [
          IconButton(
            onPressed: onHistoryPressed,
            icon: const Icon(Icons.history_rounded),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // Input Display
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.bottomRight,
              child: Text(
                input,
                style: const TextStyle(fontSize: 24.0),
              ),
            ),
          ),

          // Output Display
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.bottomRight,
              child: Text(
                output,
                style: const TextStyle(
                  fontSize: 36.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Keyboard Layout
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              buildButton("("),
              buildButton(")"),
              buildButton("%"),
              buildButton("C"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              buildButton("7"),
              buildButton("8"),
              buildButton("9"),
              buildButton("/"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              buildButton("4"),
              buildButton("5"),
              buildButton("6"),
              buildButton("*"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              buildButton("1"),
              buildButton("2"),
              buildButton("3"),
              buildButton("-"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              buildButton("0"),
              buildButton("."),
              buildButton("="),
              buildButton("+"),
            ],
          ),

          Expanded(
            child: Container(),
          ),
        ],
      ),
    );
  }

  Widget buildButton(String buttonText) {
    return ElevatedButton(
      onPressed: () {
        onButtonPressed(buttonText);
      },
      child: SizedBox(
        width: 40,
        height: 40,
        child: Center(
          child: Text(
            buttonText,
            style: const TextStyle(fontSize: 20.0),
          ),
        ),
      ),
    );
  }

  void onButtonPressed(String value) {
    if (value == '=') {
      // Calculate and update the result
      final result = calculate(input);
      saveHistory(input, result); // Save to history
      setState(() {
        output = result;
      });
    } else if (value == 'C') {
      // Clear the input and output
      setState(() {
        input = '';
        output = '';
      });
    } else if (canAppendValue(input, value)) {
      // Append the value to the input
      setState(() {
        input += value;
      });
    }
  }

  void onHistoryPressed() {
    // Show calculation history
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Calculation History'),
          // ignore: sized_box_for_whitespace
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: calculationHistory.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(calculationHistory[index]),
                  onTap: () {
                    // Replace input and output with the selected history entry
                    final selectedHistory = calculationHistory[index];
                    final parts = selectedHistory.split('=');
                    setState(() {
                      input = parts[0];
                      output = parts[1];
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void saveHistory(String expression, String result) async {
    final prefs = await SharedPreferences.getInstance();
    calculationHistory.add('$expression = $result');
    prefs.setStringList('calculationHistory', calculationHistory);
  }

  void loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('calculationHistory') ?? [];
    setState(() {
      calculationHistory = history;
    });
  }

  bool canAppendValue(String currentInput, String nextValue) {
    // Define your logic to check if the next value or operation can be added
    if (currentInput.isEmpty) {
      // The input is empty, so allow starting with any valid value or operation
      return nextValue != '=';
    }

    // Implement your custom logic here
    // You can add checks for valid input here based on your requirements.

    return true; // Default to allowing all inputs
  }

  String calculate(String input) {
    // Implement your calculation logic here
    // For a simple calculator, you can use an expression parser library.
    // Here's a basic example using Dart's built-in 'eval' function:
    try {
      final result = evaluateExpression(input);
      return result.toString();
    } catch (e) {
      return 'Error';
    }
  }

  double evaluateExpression(String expression) {
    // A basic expression evaluator for simple calculations
    // You can replace this with a more advanced library for complex expressions.
    // This code handles +, -, *, and / operators.
    final parts = expression.split(RegExp(r'(\+|-|\*|/)'));
    final operators = expression.replaceAll(RegExp(r'[0-9. ]'), '');

    //Function
    double result = double.parse(parts[0]);
    for (int i = 1; i < parts.length; i++) {
      final operand = double.parse(parts[i]);
      final operator = operators[i - 1];
      if (operator == '+') {
        result += operand;
      } else if (operator == '-') {
        result -= operand;
      } else if (operator == '*') {
        result *= operand;
      } else if (operator == '/') {
        if (operand != 0) {
          result /= operand;
        } else {
          return double.infinity; // Division by zero
        }
      }
    }
    return result;
  }
}

