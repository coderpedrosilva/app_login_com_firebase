import 'package:flutter/material.dart';

enum TabItem { jobs, entries, account }

class TabItemData {
  const TabItemData({@required this.title, @required this.icon});

  final String title;
  final IconData icon;

  static const Map<TabItem, TabItemData> allTabs = {
    TabItem.jobs: TabItemData(title: 'Atividade', icon: Icons.work),
    TabItem.entries:
        TabItemData(title: 'Informações', icon: Icons.view_headline),
    TabItem.account: TabItemData(title: 'Perfil', icon: Icons.person),
  };
}
