import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  String? _userName;
  String? _accessToken;
  String? _refreshToken;
 

  String? get userName => _userName;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
 

  void init({

    required String userName,
    required String accessToken,
    required String refreshToken
  })async{
    
    _userName = userName;
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString("access", accessToken);
    await sharedPreferences.setString("refresh", refreshToken);
    notifyListeners();
  }
  void setName (String name){
    _userName = name;
    notifyListeners();
  }

}