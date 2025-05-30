import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoalert/presentation/screens/home/pages/alerts_page.dart';
import 'package:geoalert/presentation/screens/home/pages/profile_page.dart';
import 'package:geoalert/presentation/screens/home/pages/zone_page.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  late final PageController _pageController;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _pages = const [AlertsPage(), ZonePage(), ProfilePage()];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return "Alerts";
      case 1:
        return "Map";
      case 2:
        return "Profile";
      default:
        return "";
    }
  }

  IconData _getBottomNavIcon(int index) {
    switch (index) {
      case 0:
        return Icons.warning_amber_rounded;
      case 1:
        return Icons.map_outlined;
      case 2:
        return Icons.person_2_outlined;
      default:
        return Icons.warning_amber_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 88),
          Center(child: Text(getAppBarTitle(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600, fontFamily: 'TittilumWeb'))),
          const Divider(color: Color.fromRGBO(208, 213, 221, 1), thickness: 1, height: 40),
          Expanded(child: PageView(controller: _pageController, onPageChanged: _onPageChanged, physics: const BouncingScrollPhysics(), children: _pages)),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromRGBO(255, 0, 0, 1),
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, fontFamily: 'SpaceGrotesk'),
        unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, fontFamily: 'SpaceGrotesk'),
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(_getBottomNavIcon(0), size: 24), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(_getBottomNavIcon(1), size: 24), label: 'Zones'),
          BottomNavigationBarItem(icon: Icon(_getBottomNavIcon(2), size: 24), label: 'Profile'),
        ],
      ),
    );
  }
}
