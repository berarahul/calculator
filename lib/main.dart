import 'package:calculator/provider/CalculatorProvider.dart';
import 'package:calculator/provider/ThemeProvider.dart';
import 'package:calculator/screen/CalculatorView.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'config/Theme.dart';




void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(

      MultiProvider(providers: [
        ChangeNotifierProvider<CalculatorModelProvider>( create: (context) => CalculatorModelProvider()),
        ChangeNotifierProvider<ThemeProvider>( create: (context) => ThemeProvider()),


      ],child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // return  ChangeNotifierProvider(create: (context) => CounterProvider(),
    final themeProvider=Provider.of<ThemeProvider>(context,listen: true);
    return
      GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeProvider.themeMode,
        home: CalculatorView(),
      );




  }
}
