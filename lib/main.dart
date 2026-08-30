import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:questvale/cubits/home/home_page.dart';
import 'package:questvale/cubits/theme/character_theme_persistence.dart';
import 'package:questvale/data/questvale_db.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/services/notification_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:jk_pixel_ui/jk_pixel_ui.dart';

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
    return BlocProvider(
      create: (_) => ThemeCubit(
        persistence: CharacterThemePersistence(
          characterRepository: CharacterRepository(db: questvaleDB),
        ),
      ),
      child: Provider(
        create: (_) => questvaleDB,
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) => MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              colorScheme: themeState.theme.colorScheme,
              useMaterial3: true,
              splashColor: Colors.transparent,
              fontFamily: 'Pixel1',
            ),
            home: HomePage(),
          ),
        ),
      ),
    );
  }
}
