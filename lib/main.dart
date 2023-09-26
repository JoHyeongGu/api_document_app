// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:api_document/detail/main.dart';
import 'package:api_document/lobby/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

void main() async {
  await initFirebase();
  return runApp(MyApp(router: initRouter()));
}

Future initFirebase() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

initRouter() {
  FluroRouter router = FluroRouter();
  router.define(
    '/project',
    handler: Handler(
      handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
        return Detail(argument: params);
      },
    ),
    transitionType: TransitionType.cupertinoFullScreenDialog,
  );
  return router;
}

class MyApp extends StatelessWidget {
  MyApp({super.key, required this.router});
  FluroRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API Document',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
      ),
      onGenerateRoute: router.generator,
      routes: {
        '/': (context) => Lobby(router),
      },
    );
  }
}
