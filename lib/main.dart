import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:questvale/cubits/home/home_page.dart';
import 'package:questvale/data/questvale_db.dart';
import 'package:questvale/services/notification_service.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final Database dbConn = await QuestvaleDB.initializeDB();
  await NotificationService().init();

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
      primary: Color(0xffe8c468),
      onPrimary: Color(0xff1b1b1e),
      secondary: Color(0xff3a3a3e),
      onSecondary: Color(0xffe8c468),
      error: Color(0xffd83030),
      onError: Color(0xffeeeeee),
      surface: Color(0xff1b1b1e),
      onSurface: Color(0xffffe99c),
      primaryContainer: Color(0xff222222),
      surfaceContainerHigh: Color(0xff383838),
      surfaceContainer: Color(0xff3c3c44),
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
