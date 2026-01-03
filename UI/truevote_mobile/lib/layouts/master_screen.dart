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

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return widget.child;
      case 1:
        return const Placeholder(key: ValueKey('Historija')); // Zamijeni stvarnim ekranom
      case 2:
        return FAQScreen(key: ValueKey(DateTime.now().millisecondsSinceEpoch)); // NOVI FAQScreen svaki put!
      case 3:
        return ProfilScreen();
      default:
        return widget.child;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getScreen(_selectedIndex),
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