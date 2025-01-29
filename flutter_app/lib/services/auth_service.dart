import 'package:flutter/material.dart';
import 'package:openid_client/openid_client_browser.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class kc_params {
  static const String URL = "https://cinecritique.mi.hdm-stuttgart.de/auth";
  static const String REALM = "movie-app";
  static const String CLIENT = "movie-app-client-frontend";
  static const SCOPESL = ['profile'];
  static const String REDIRECT_URI = "http://localhost:54841/";
}

class AuthService {
  ValueNotifier<bool> isLoggedIn = ValueNotifier(false);
  ValueNotifier<UserInfo?> userInfo = ValueNotifier(null);

  late Client _client;
  late Authenticator _authenticator;

  Future<void> initialize() async {
    try {
      var issuer = await Issuer.discover(Uri.parse('${kc_params.URL}/realms/${kc_params.REALM}'));
      _client = Client(issuer, kc_params.CLIENT);
      _authenticator = Authenticator(_client, scopes: kc_params.SCOPESL);

      var credential = await _authenticator.credential;
      if (credential != null) {
        userInfo.value = await credential.getUserInfo();
        isLoggedIn.value = true;
      }
    } catch (e) {
      print('Fehler bei der Initialisierung: $e');
    }
  }

  Future<void> login() async {
    try {
      var issuer = await Issuer.discover(Uri.parse('${kc_params.URL}/realms/${kc_params.REALM}'));
      _client = Client(issuer, kc_params.CLIENT);
      _authenticator = Authenticator(_client, scopes: kc_params.SCOPESL);
      _authenticator.authorize();
    } catch (e) {
      print('Fehler beim Login: $e');
    }
  }

  Future<void> logout() async {
    try {
      isLoggedIn.value = false;
      userInfo.value = null;
      _authenticator.logout();
    } catch (e) {
      print('Fehler beim Logout: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      var credential = await _authenticator.credential;
      if (credential != null) {
        var tokenResponse = await credential.getTokenResponse();
        if (tokenResponse != null) {
          return tokenResponse.accessToken;
        }
      }
    } catch (e) {
      print('Fehler beim Token abrufen: $e');
    }
    return null;
  }

  Future<String?> getUserEmail() async {
    return userInfo.value?.email;
  }
}
