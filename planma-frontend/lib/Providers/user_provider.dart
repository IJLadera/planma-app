import 'package:flutter/material.dart';

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
  }){
    
    _userName = userName;
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    notifyListeners();
  }
  void setName (String name){
    _userName = name;
    notifyListeners();
  }
}