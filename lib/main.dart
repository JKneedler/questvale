import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:questvale/cubits/home/home_page.dart';
import 'package:questvale/data/questvale_db.dart';
import 'package:sqflite/sqflite.dart';

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
    ColorScheme darkScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xfff67900),
      onPrimary: Color(0xffeeeeee),
      secondary: Color(0xff472d14),
      onSecondary: Color(0xfff67900),
      error: Color(0xffd83030),
      onError: Color(0xffeeeeee),
      surface: Color(0xff000000),
      onSurface: Color(0xfff6f6f6),
      primaryContainer: Color(0xff222222),
      surfaceContainerHigh: Color(0xff383838),
      surfaceContainer: Color(0xff242424),
      surfaceContainerLow: Color(0xff292929),
      surfaceContainerLowest: Color(0xff181818),
      onPrimaryContainer: Color(0xfff6f6f6),
      onSecondaryContainer: Color(0xffa7a7a7),
      onSurfaceVariant: Color(0xff313131),
      onPrimaryFixedVariant: Color(0xff8c8c8c),
    );

    ColorScheme gameScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffddc68c),
      onPrimary: Color(0xff554129),
      secondary: Color(0xff35220f),
      onSecondary: Color(0xffddc68c),
      error: Color(0xffd83030),
      onError: Color(0xffeeeeee),
      surface: Color(0xff554129),
      onSurface: Color(0xfffff2be),
      primaryContainer: Color(0xff222222),
      surfaceContainerHigh: Color(0xff383838),
      surfaceContainer: Color(0xffcbcbcb),
      surfaceContainerLow: Color(0xff292929),
      surfaceContainerLowest: Color(0xff181818),
      onPrimaryContainer: Color.fromARGB(255, 24, 24, 24),
      onSecondaryContainer: Color(0xffa7a7a7),
      onSurfaceVariant: Color(0xff313131),
      onPrimaryFixedVariant: Color.fromARGB(255, 75, 75, 75),
    );

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
          colorScheme: gameScheme,
          useMaterial3: true,
          splashColor: Colors.transparent,
          fontFamily: 'Pixel1',
        ),
        home: HomePage(),
      ),
    );
  }
}
