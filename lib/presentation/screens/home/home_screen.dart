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
  late final List<Widget> _pages; // Make this final and initialize in initState

  @override
  void initState() {
    super.initState();
    _pages = const [AlertsPage(), ProfilePage()];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 88),
          Center(child: Text(_selectedIndex == 0 ? 'Alerts' : 'Profile', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, fontFamily: 'TittilumWeb'))),
          const Divider(color: Color.fromRGBO(208, 213, 221, 1), thickness: 1, height: 40),
          Expanded(child: IndexedStack(index: _selectedIndex, children: _pages)),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromRGBO(255, 0, 0, 1),
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, fontFamily: 'SpaceGrotesk'),
        unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, fontFamily: 'SpaceGrotesk'),
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.warning_amber_rounded, size: 24), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.person_2_outlined, size: 24), label: 'Profile'),
        ],
      ),
    );
  }
}
