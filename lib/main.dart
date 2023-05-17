import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase/supabase.dart';

import 'package:chatsupabase/const/helpers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'const/data.dart';

// screens
import 'screens/login.dart';
import 'screens/welcome.dart';
import 'screens/friends.dart';
import 'screens/chat.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GetIt locator = GetIt.instance;
  locator.registerSingleton<SupabaseClient>(SupabaseClient(URL, API));

  await Supabase.initialize(
    // TODO: Replace credentials with your own
    url: URL,
    anonKey: API,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'A supabase auth test app',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => WelcomeScreen(),
        '/login': (_) => const LoginScreen(),
        '/friends': (_) => const FriendsScreen(),
      },
    );
  }
}
