import 'package:flutter/material.dart';

import 'recruiter_postings_screen.dart';
import 'recruiter_profile_screen.dart';

/// The signed-in recruiter home: a bottom nav between their postings and their
/// company profile.
class RecruiterHomeShell extends StatefulWidget {
  const RecruiterHomeShell({super.key});

  @override
  State<RecruiterHomeShell> createState() => _RecruiterHomeShellState();
}

class _RecruiterHomeShellState extends State<RecruiterHomeShell> {
  int _index = 0;

  static const List<Widget> _pages = <Widget>[
    RecruiterPostingsScreen(),
    RecruiterProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int i) => setState(() => _index = i),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work),
            label: 'Postings',
          ),
          NavigationDestination(
            icon: Icon(Icons.business_outlined),
            selectedIcon: Icon(Icons.business),
            label: 'Company',
          ),
        ],
      ),
    );
  }
}
