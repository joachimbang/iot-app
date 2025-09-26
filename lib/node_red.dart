import 'package:node_red_app/views/splashscreen.dart';
import 'package:flutter/material.dart';
// import 'package:node_red_app/services/routers/routes.dart';
import 'package:node_red_app/services/style.dart';
// import 'package:node_red_app/views/start/splashscreen.dart';

class NodeRedApp extends StatefulWidget {
  const NodeRedApp({super.key});

  @override
  State<NodeRedApp> createState() => _NodeRedAppState();
}

class _NodeRedAppState extends State<NodeRedApp> {
  AppStyle appStyle = AppStyle();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NodeRedApp',
      debugShowCheckedModeBanner: false,
      darkTheme: appStyle.darkTheme(context),
      theme: appStyle.lightTheme(context),
      home: const SplashScreen(),
      // home: const Login(),
    );
  }
}
