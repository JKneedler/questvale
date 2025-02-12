import 'package:flutter/material.dart';
import 'package:questvale/cubits/tasks_overview/tasks_overview_page.dart';
import 'package:questvale/cubits/character_overview/character_overview_page.dart';
import 'package:questvale/cubits/quest_overview/quest_overview_page.dart';
import 'package:questvale/pages/settings_page.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 250,
            child: DrawerHeader(
                decoration: BoxDecoration(color: colorScheme.primary),
                padding: EdgeInsets.only(bottom: 20, top: 20),
                child: Column(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage("images/headshot.png"),
                      radius: 50,
                    ),
                    Text('Kelsier',
                        style: TextStyle(
                            fontSize: 25, color: colorScheme.onPrimary)),
                  ],
                )),
          ),
          ListTile(
            title: Text(
              'Home',
              style: TextStyle(color: colorScheme.onSurface),
            ),
            leading: Icon(Icons.home, color: colorScheme.primary),
            contentPadding: const EdgeInsets.only(left: 30, right: 30),
            onTap: () => {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => TasksOverviewPage()),
                ModalRoute.withName('/'),
              )
            },
          ),
          ListTile(
            title: Text(
              'Quest',
              style: TextStyle(color: colorScheme.onSurface),
            ),
            leading: Icon(Icons.castle, color: colorScheme.primary),
            contentPadding: const EdgeInsets.only(left: 30, right: 30),
            onTap: () => {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => QuestOverviewPage()),
                ModalRoute.withName('/'),
              )
            },
          ),
          ListTile(
            title: Text(
              'Character',
              style: TextStyle(color: colorScheme.onSurface),
            ),
            leading: Icon(Icons.auto_stories, color: colorScheme.primary),
            contentPadding: const EdgeInsets.only(left: 30, right: 30),
            onTap: () => {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => CharacterOverviewPage()),
                ModalRoute.withName('/'),
              )
            },
          ),
          ListTile(
            title: Text(
              'Equipment',
              style: TextStyle(color: colorScheme.onSurface),
            ),
            leading: Icon(Icons.privacy_tip, color: colorScheme.primary),
            contentPadding: const EdgeInsets.only(left: 30, right: 30),
            onTap: () => {},
          ),
          ListTile(
            title: Text(
              'Settings',
              style: TextStyle(color: colorScheme.onSurface),
            ),
            leading: Icon(Icons.settings, color: colorScheme.primary),
            contentPadding: const EdgeInsets.only(left: 30, right: 30),
            onTap: () => {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
                ModalRoute.withName('/'),
              )
            },
          ),
        ],
      ),
    );
  }
}
