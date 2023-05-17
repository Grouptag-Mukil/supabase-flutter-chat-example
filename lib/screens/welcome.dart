import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase/supabase.dart' as supa;

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyWelcomeScreen();
  }
}

class MyWelcomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyWelcomeScreenState();
  }
}

class _MyWelcomeScreenState extends State<MyWelcomeScreen> {
  void checkLogin() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final session = sharedPreferences.getString('user');

    if (session == null) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      final response = await GetIt.instance<supa.SupabaseClient>()
          .auth
          .recoverSession(session);

      // set the response in shared preferences
      sharedPreferences.setString(
          'user', response.session!.persistSessionString);

      Navigator.pushReplacementNamed(context, '/friends');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //checkLogin();
  }

  _logout() async {
    await GetIt.I.get<supa.SupabaseClient>().auth.signOut();

    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.clear();

    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Test'),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                style: ButtonStyle(
                  enableFeedback: true,
                  overlayColor: MaterialStateProperty.all(Colors.blueGrey),
                ),
                onPressed: () {
                  print('clicked lets go');
                  checkLogin();
                },
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Friends',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                )),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                style: ButtonStyle(
                  enableFeedback: true,
                  overlayColor: MaterialStateProperty.all(Colors.blueGrey),
                ),
                onPressed: () {
                  print('clicked logout');
                  _logout();
                },
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Logout',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
