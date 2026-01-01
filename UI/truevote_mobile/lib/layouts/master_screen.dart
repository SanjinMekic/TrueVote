import 'package:flutter/material.dart';
import 'package:truevote_mobile/screens/faq_screen.dart';
import 'package:truevote_mobile/screens/profil_screen.dart';

class MasterScreen extends StatefulWidget {
  final Widget child;
  final int initialIndex;

  const MasterScreen({super.key, required this.child, this.initialIndex = 0});

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    // Ovdje zamijenite sa stvarnim screenovima
    Placeholder(key: ValueKey('Pocetna')),
    Placeholder(key: ValueKey('Historija')),
    FAQScreen(),
    ProfilScreen()
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          if (_selectedIndex == 0) widget.child else _screens[0],
          _screens[1],
          _screens[2],
          _screens[3],
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Početna',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historija',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.question_answer),
            label: 'Q&A',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}