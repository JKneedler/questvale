import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/skills_overview/skills_overview_page.dart';
import 'package:questvale/cubits/home/home_cubit.dart';
import 'package:questvale/cubits/home/home_state.dart';
import 'package:questvale/cubits/inventory_overview/inventory_overview_page.dart';
import 'package:questvale/cubits/todos_overview/todos_overview_page.dart';
import 'package:questvale/cubits/town/town_page.dart';
import 'package:questvale/pages/settings_page.dart';
import 'package:questvale/widgets/qv_nav_bar.dart';

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
    return BlocBuilder<HomeCubit, HomeState>(builder: (context, homeState) {
      return Scaffold(
        body: [
          SkillsOverviewPage(),
          TownPage(),
          TodosOverviewPage(),
          InventoryOverviewPage(),
          TodosOverviewPage(),
          SettingsPage(),
        ][homeState.tab],
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
          // showSelectedLabels: false,
          // showUnselectedLabels: false,
          // type: BottomNavigationBarType.fixed,
          currentIndex: homeState.tab,
          // backgroundColor: colorScheme.primary,
          onTap: (index) => context.read<HomeCubit>().changeTab(index),
        ),
      );
    });
  }
}
