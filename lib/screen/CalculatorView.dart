import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/CalculatorProvider.dart';
import '../provider/ThemeProvider.dart';

class CalculatorView extends StatelessWidget {
  const CalculatorView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    // Fetch device screen size
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final isPortrait = mediaQuery.orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return IconButton(
              onPressed: () {
                final newThemeMode = themeProvider.themeMode == ThemeMode.light
                    ? ThemeMode.dark
                    : ThemeMode.light;
                themeProvider.ChangeTheme(newThemeMode);
              },
              icon: Icon(
                themeProvider.themeMode == ThemeMode.light
                    ? Icons.dark_mode
                    : Icons.light_mode,
                size: 23,
                color: Colors.blueAccent,
              ),
            );
          },
        ),
        actions: [
          Consumer2<ThemeProvider, CalculatorModelProvider>(
            builder: (context, themeProvider, calculatorModelProvider, _) {
              return
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.history,
                    color: themeProvider.themeMode == ThemeMode.light
                        ? Colors.black
                        : Colors.white,
                  ),
                  itemBuilder: (context) {
                    // Add the Clear History option at the top
                    final menuItems = [
                      PopupMenuItem<String>(
                        value: 'clearHistory',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Clear History'),
                        ),
                      ),
                    ];

                    // Add the history items below the Clear History option
                    menuItems.addAll(
                      calculatorModelProvider.historyList.map(
                            (historyItem) {
                          // Detect the operator in the equation
                          String equation = historyItem['equation']!;
                          String operator = '';
                          if (equation.contains('+')) {
                            operator = '+';
                          } else if (equation.contains('-')) {
                            operator = '-';
                          } else if (equation.contains('*')) {
                            operator = '*';
                          } else if (equation.contains('/')) {
                            operator = '/';
                          }

                          // Set the color based on the operator
                          Color resultColor;
                          switch (operator) {
                            case '+':
                            case '*':
                              resultColor = Colors.green;
                              break;
                            case '-':
                            case '/':
                              resultColor = Colors.red;
                              break;
                            default:
                              resultColor = themeProvider.themeMode == ThemeMode.light
                                  ? Colors.black
                                  : Colors.white;
                          }

                          return PopupMenuItem<String>(
                            value: historyItem['result']!,
                            child: Card(
                              color: themeProvider.themeMode == ThemeMode.light
                                  ? Colors.white
                                  : Colors.grey[900],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 4,
                              child: Container(
                                width: 200,
                                height: 80,
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      historyItem['equation']!,
                                      style: TextStyle(
                                        color: themeProvider.themeMode == ThemeMode.light
                                            ? Colors.black
                                            : Colors.white,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      historyItem['result']!,
                                      style: TextStyle(
                                        color: resultColor,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );

                    return menuItems;
                  },
                  onSelected: (selectedValue) {
                    if (selectedValue == 'clearHistory') {
                      // Show confirmation dialog
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Clear History'),
                            content: Text('Do you want to clear all history?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close the dialog
                                },
                                child: Text('No'),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Clear history logic
                                  calculatorModelProvider.clearHistory();
                                  Navigator.of(context).pop(); // Close the dialog
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('History cleared')),
                                  );
                                },
                                child: Text('Yes'),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      print('Selected equation: $selectedValue');
                      calculatorModelProvider.setOutput(selectedValue);
                    }
                  },
                  color: themeProvider.themeMode == ThemeMode.light
                      ? Colors.white
                      : Colors.black,
                );


            },
          ),
        ],
      ),

      body: Column(
        children: [
          SizedBox(height: screenHeight * 0.05),

          // Display Area for History and Calculation Output
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Container(
              alignment: Alignment(1, 1),
              height: screenHeight * 0.2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Consumer<CalculatorModelProvider>(
                    builder: (ctx, calculatorModelProvider, _) {
                      return Text(
                        calculatorModelProvider.history,
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          color: themeProvider.themeMode == ThemeMode.light
                              ? Colors.black
                              : Colors.grey,
                        ),
                      );
                    },
                  ),
                  Consumer<CalculatorModelProvider>(
                    builder: (ctx, calculatorModelProvider, _) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          calculatorModelProvider.output,
                          style: TextStyle(
                            fontSize: screenWidth * 0.08,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.themeMode == ThemeMode.light
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),

          // Calculator Buttons Grid
          Expanded(
            child: Consumer<CalculatorModelProvider>(
              builder: (context, calculatorModelProvider, child) {
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isPortrait ? 4 : 6,
                    crossAxisSpacing: screenWidth * 0.02,
                    mainAxisSpacing: screenHeight * 0.02,
                  ),
                  itemCount: calculatorModelProvider.buttons.length,
                  itemBuilder: (context, index) {
                    final buttonLabel = calculatorModelProvider.buttons[index];
                    final isLastButton = index == calculatorModelProvider.buttons.length - 1;

                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                      child: ElevatedButton(
                        onPressed: () {
                          calculatorModelProvider.buttonPressed(buttonLabel);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(screenWidth * 0.02),
                          backgroundColor: _getButtonColor(index, isLastButton),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.05),
                          ),
                        ),
                        child: _getButtonChild(buttonLabel, screenWidth, themeProvider),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getButtonColor(int index, bool isLastButton) {
    if (isLastButton) {
      return Colors.deepPurpleAccent;
    } else if (index < 4 || (index + 1) % 4 == 0) {
      return Colors.blueGrey;
    } else {
      return Colors.grey;
    }
  }

  Widget _getButtonChild(String buttonLabel, double screenWidth, ThemeProvider themeProvider) {
    final textColor = themeProvider.themeMode == ThemeMode.light
        ? Colors.black
        : Colors.white;

    if (buttonLabel == 'x') {
      return Icon(
        Icons.cancel_presentation_outlined,
        color: textColor,
        size: screenWidth * 0.07,
      );
    } else {
      return Text(
        buttonLabel,
        style: TextStyle(color: textColor, fontSize: 24),
      );
    }
  }
}
