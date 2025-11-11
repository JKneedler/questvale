import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:questvale/cubits/home/player_cubit.dart';
import 'package:questvale/cubits/home/player_state.dart';
import 'package:questvale/cubits/home/nav_cubit.dart';
import 'package:questvale/cubits/home/nav_state.dart';
import 'package:questvale/cubits/todo_tab/todos_overview/todos_overview_page.dart';
import 'package:questvale/cubits/settings/settings_page.dart';
import 'package:questvale/cubits/town_tab/town/town_page.dart';
import 'package:questvale/data/providers/game_data.dart';
import 'package:questvale/cubits/home/nav_bar.dart';
import 'package:sqflite/sqflite.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GameData>(
        future: GameData.load(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print(snapshot.error.toString());
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final gameData = snapshot.data!;
          return MultiProvider(
            providers: [
              Provider(create: (context) => gameData),
            ],
            child: MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => NavCubit(),
                ),
                BlocProvider(
                  create: (context) => PlayerCubit(
                    db: context.read<Database>(),
                  ),
                ),
              ],
              child: HomeView(),
            ),
          );
        });
  }
}

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, PlayerState>(
        builder: (context, characterDataState) {
      if (characterDataState.character == null) {
        return const Center(child: CircularProgressIndicator());
      }
      return BlocBuilder<NavCubit, NavState>(builder: (context, navState) {
        return Scaffold(
          body: IndexedStack(
            index: navState.tab,
            children: [
              _TabNavigator(
                navigatorKey: _navigatorKeys[0],
                rootPage: TownPage(),
              ),
              _TabNavigator(
                navigatorKey: _navigatorKeys[1],
                rootPage: TodosOverviewPage(),
              ),
              _TabNavigator(
                navigatorKey: _navigatorKeys[2],
                rootPage: SettingsPage(),
              ),
            ],
          ),
          bottomNavigationBar: NavBar(
            items: [
              NavBarItem(
                iconName: 'sword',
                label: 'World',
                selected: navState.tab == 0,
              ),
              NavBarItem(
                iconName: 'house',
                label: 'Home',
                selected: navState.tab == 1,
              ),
              NavBarItem(
                iconName: 'player',
                label: 'Player',
                selected: navState.tab == 2,
              ),
            ],
            currentIndex: navState.tab,
            onTap: (index) => context.read<NavCubit>().changeTab(index),
          ),
        );
      });
    });
  }
}

class _TabNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget rootPage;

  const _TabNavigator({
    required this.navigatorKey,
    required this.rootPage,
  });

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) {
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (_, __, ___) => rootPage,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Customize your per-tab base transition if you want.
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    );
  }
}
