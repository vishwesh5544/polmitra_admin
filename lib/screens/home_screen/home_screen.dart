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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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

  void _toggleEndDrawer () {
    if (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
      Navigator.of(context).pop(); // Close the drawer if it is open
    } else {
      _scaffoldKey.currentState?.openEndDrawer(); // Open the drawer if it is closed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: _screens[_selectedIndex],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: ColorProvider.deepSaffron,
        title: const Text('Polmitra Admin'),
      ),
      endDrawerEnableOpenDragGesture: true,
      endDrawer: Drawer(
        child: ListView(
          children: [
            _getDrawerHeader(),
            ListTile(
              title: const Text('Events'),
              onTap: () {
                _onItemTapped(0);
                _toggleEndDrawer();
              },
            ),
            ListTile(
              title: const Text('Polls'),
              onTap: () {
                _onItemTapped(1);
                _toggleEndDrawer();
              },
            ),
            ListTile(
              title: const Text('Users'),
              onTap: () {
                _onItemTapped(2);
                _toggleEndDrawer();
              },
            ),
            ListTile(
              title: const Text('Account'),
              onTap: () {
                _onItemTapped(3);
                _toggleEndDrawer();
              },
            ),
            ],
        ),
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

  DrawerHeader _getDrawerHeader() {
    return const DrawerHeader(
      decoration: BoxDecoration(
        color: ColorProvider.deepSaffron,
      ),
      child: Text('Admin'),
    );
  }
}
