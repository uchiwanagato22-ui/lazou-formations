import 'package:flutter/material.dart';
import 'espace_tab.dart';
import 'formations_screen.dart';
import 'home_screen.dart';

/// Coquille de navigation persistante pour l'espace public/étudiant —
/// remplace la navigation en pile simple par une vraie structure d'app
/// (barre du bas toujours visible), plus lisible et plus "produit fini"
/// qu'un empilement d'écrans.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _pages = [
    HomeScreen(),
    FormationsScreen(),
    EspaceTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Formations'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Mon espace'),
        ],
      ),
    );
  }
}
