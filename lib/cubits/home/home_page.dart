import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/character_tab/character/character_page.dart';
import 'package:questvale/cubits/home/character_data_cubit.dart';
import 'package:questvale/cubits/home/character_data_state.dart';
import 'package:questvale/cubits/home/nav_cubit.dart';
import 'package:questvale/cubits/home/nav_state.dart';
import 'package:questvale/cubits/todo_tab/todos_overview/todos_overview_page.dart';
import 'package:questvale/cubits/settings/settings_page.dart';
import 'package:questvale/cubits/town_tab/town/town_page.dart';
import 'package:questvale/widgets/qv_nav_bar.dart';
import 'package:sqflite/sqflite.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => NavCubit(),
        ),
        BlocProvider(
          create: (context) => CharacterDataCubit(
            db: context.read<Database>(),
          ),
        ),
      ],
      child: HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CharacterDataCubit, CharacterDataState>(
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
                rootPage: CharacterPage(),
              ),
              _TabNavigator(
                navigatorKey: _navigatorKeys[1],
                rootPage: TownPage(),
              ),
              _TabNavigator(
                navigatorKey: _navigatorKeys[2],
                rootPage: TodosOverviewPage(),
              ),
              _TabNavigator(
                navigatorKey: _navigatorKeys[3],
                rootPage: TodosOverviewPage(),
              ),
              _TabNavigator(
                navigatorKey: _navigatorKeys[4],
                rootPage: SettingsPage(),
              ),
            ],
          ),
          bottomNavigationBar: QVNavBar(
            items: [
              QVNavBarItem(
                icon: Image.asset(
                  'images/pixel-icons/helmet.png',
                  filterQuality: FilterQuality.none,
                ),
                label: 'Character',
              ),
              QVNavBarItem(
                icon: Image.asset(
                  'images/pixel-icons/sword.png',
                  filterQuality: FilterQuality.none,
                ),
                label: 'World',
              ),
              QVNavBarItem(
                icon: Image.asset(
                  'images/pixel-icons/quill.png',
                  filterQuality: FilterQuality.none,
                ),
                label: 'Tasks',
              ),
              QVNavBarItem(
                icon: Image.asset(
                  'images/pixel-icons/book.png',
                  filterQuality: FilterQuality.none,
                ),
                label: 'Calendar',
              ),
              QVNavBarItem(
                icon: Image.asset(
                  'images/pixel-icons/settings-gear.png',
                  filterQuality: FilterQuality.none,
                ),
                label: 'Settings',
              ),
            ],
            showCharacterAP: navState.tab == 1 ? false : true,
            showCharacterResources: navState.tab == 0 ? false : true,
            // showSelectedLabels: false,
            // showUnselectedLabels: false,
            // type: BottomNavigationBarType.fixed,
            currentIndex: navState.tab,
            // backgroundColor: colorScheme.primary,
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
