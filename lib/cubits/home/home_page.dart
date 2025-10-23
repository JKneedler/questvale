import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/character/character_page.dart';
import 'package:questvale/cubits/home/character_data_cubit.dart';
import 'package:questvale/cubits/home/character_data_state.dart';
import 'package:questvale/cubits/home/nav_cubit.dart';
import 'package:questvale/cubits/home/nav_state.dart';
import 'package:questvale/cubits/quest/quest_page.dart';
import 'package:questvale/cubits/todos_overview/todos_overview_page.dart';
import 'package:questvale/cubits/settings/settings_page.dart';
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
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CharacterDataCubit, CharacterDataState>(
        builder: (context, characterDataState) {
      if (characterDataState.character == null) {
        return const Center(child: CircularProgressIndicator());
      }
      return BlocBuilder<NavCubit, NavState>(builder: (context, navState) {
        return Scaffold(
          body: [
            CharacterPage(),
            QuestPage(),
            TodosOverviewPage(),
            TodosOverviewPage(),
            SettingsPage(),
          ][navState.tab],
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
                label: 'Quest',
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
