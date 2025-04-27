import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoalert/presentation/screens/home/pages/alerts_page.dart';
import 'package:geoalert/presentation/screens/home/pages/profile_page.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [AlertsPage(), ProfilePage()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromRGBO(255, 0, 0, 1),
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, fontFamily: 'SpaceGrotesk'),
        unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, fontFamily: 'SpaceGrotesk'),
        // unselectedItemColor: const Color.fromRGBO(0, 0, 0, 1),
        onTap: _onItemTapped,
        items: [BottomNavigationBarItem(icon: Icon(Icons.warning_amber_rounded, size: 24), label: 'Alerts'), BottomNavigationBarItem(icon: Icon(Icons.person_2_outlined, size: 24), label: 'Profile')],
      ),
    );
  }
}
