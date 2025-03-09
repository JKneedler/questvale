import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:questvale/cubits/skills_overview/skills_overview_page.dart';
import 'package:questvale/cubits/home/home_cubit.dart';
import 'package:questvale/cubits/home/home_state.dart';
import 'package:questvale/cubits/inventory_overview/inventory_overview_page.dart';
import 'package:questvale/cubits/quest_overview/quest_overview_page.dart';
import 'package:questvale/cubits/tasks_overview/tasks_overview_page.dart';
import 'package:questvale/pages/settings_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<HomeCubit, HomeState>(builder: (context, homeState) {
      return Scaffold(
        body: [
          SkillsOverviewPage(),
          QuestOverviewPage(),
          TasksOverviewPage(),
          InventoryOverviewPage(),
          SettingsPage(),
        ][homeState.tab],
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Symbols.book_2,
                fill: 1,
              ),
              label: 'Character',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Symbols.swords,
                fill: 1,
              ),
              label: 'Quest',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Symbols.home,
                fill: 1,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Symbols.shield,
                fill: 1,
              ),
              label: 'Inventory',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Symbols.settings,
                fill: 1,
              ),
              label: 'Settings',
            ),
          ],
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          currentIndex: homeState.tab,
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: colorScheme.onSurfaceVariant,
          backgroundColor: colorScheme.surface,
          onTap: (index) => context.read<HomeCubit>().changeTab(index),
        ),
      );
    });
  }
}
