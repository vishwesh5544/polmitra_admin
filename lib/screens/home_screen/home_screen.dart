import 'package:flutter/material.dart';
import 'package:polmitra_admin/screens/account_screen/account_screen.dart';
import 'package:polmitra_admin/screens/events_screen/events_screen.dart';
import 'package:polmitra_admin/screens/polls_screen/polls_screen.dart';
import 'package:polmitra_admin/screens/users_screen/users_screen.dart';
import 'package:polmitra_admin/utils/color_provider.dart';

typedef LabelsMap = Map<String, IconData>;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const EventsScreen(),
    const PollsScreen(),
    const UsersScreen(),
    const AccountScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final LabelsMap _labels = {
    'Events': Icons.event,
    'Polls': Icons.poll,
    'Users': Icons.people,
    'Account': Icons.account_circle,
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: ColorProvider.deepSaffron,
        title: const Text('Polmitra Admin'),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: ColorProvider.deepSaffron,
        ),
        child: BottomNavigationBar(
            selectedIconTheme: const IconThemeData(color: ColorProvider.normalWhite),
            selectedItemColor: ColorProvider.normalWhite,
            landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
            unselectedIconTheme: const IconThemeData(color: ColorProvider.softSaffron),
            unselectedItemColor: ColorProvider.softSaffron,
            backgroundColor: ColorProvider.deepSaffron,
            items: _labels.entries
                .map((entry) => BottomNavigationBarItem(icon: Icon(entry.value), label: entry.key))
                .toList(),
            currentIndex: _selectedIndex,
            onTap: _onItemTapped),
      ),
    );
  }
}
