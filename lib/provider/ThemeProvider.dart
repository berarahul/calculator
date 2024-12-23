import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier{

  //
  var themeMode=ThemeMode.light;


  void ChangeTheme(ThemeMode mode){
    themeMode=mode;
    notifyListeners();
  }

}