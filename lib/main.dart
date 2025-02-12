import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:questvale/data/questvale_db.dart';
import 'package:sqflite/sqflite.dart';
import 'cubits/tasks_overview/tasks_overview_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final Database dbConn = await QuestvaleDB.initializeDB();

  runApp(MyApp(
    questvaleDB: dbConn,
  ));
}

class MyApp extends StatelessWidget {
  final Database questvaleDB;

  const MyApp({super.key, required this.questvaleDB});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => questvaleDB,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or simply save your changes to "hot reload" in a Flutter IDE).
            // Notice that the counter didn't reset back to zero; the application
            // is not restarted.
            colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.orange, contrastLevel: -0.5),
            useMaterial3: true),
        initialRoute: '/',
        routes: {
          '/': (context) => TasksOverviewPage(),
        },
      ),
    );
  }
}
