import 'package:flutter/material.dart';
import 'package:flutter_app/screen/login/login_screen.dart';
import 'package:flutter_app/widgets/common/custom_app_bar.dart';
import 'package:flutter_app/widgets/widgets.dart';
import 'package:openid_client/openid_client.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Name',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: CustomAppBar(
          onHomePressed: () {
            print("Home tapped");
          },
          onProfilePressed: () {
            print("Profile tapped");
          },
          onLoginLogoutPressed: () async {
              print('Sign in/out error');
          },
        ),
        body: Column(
          children: [
            const CustomSearchBar(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
