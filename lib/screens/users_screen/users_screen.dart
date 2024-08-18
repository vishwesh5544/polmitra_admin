import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polmitra_admin/bloc/users/user_bloc.dart';
import 'package:polmitra_admin/bloc/users/user_event.dart';
import 'package:polmitra_admin/bloc/users/user_state.dart';
import 'package:polmitra_admin/enums/filter_options.dart';
import 'package:polmitra_admin/enums/user_enums.dart';
import 'package:polmitra_admin/models/user.dart';
import 'package:polmitra_admin/screens/users_screen/user_details_screen.dart';
import 'package:polmitra_admin/utils/text_builder.dart';

// Stateful widget for the Users Screen
class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  // Initial filter options for role and active status
  FilterRoleOption _filterRoleOption = FilterRoleOption.all;
  FilterActiveOption _filterActive = FilterActiveOption.all;

  // Controller for the search field
  final TextEditingController _searchController = TextEditingController();

  PersistentBottomSheetController? _userDetailsBottomSheetController;

  // List of all users and the filtered list
  List<PolmitraUser> users = [];
  List<PolmitraUser> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _loadUsers(); // Load users at startup
    _searchController.addListener(_filterUsers); // Listen to changes in the search field to filter users
  }

  // Method to load users via the UserBloc
  void _loadUsers() {
    BlocProvider.of<UserBloc>(context).add(LoadUsers());
  }

  // Method to filter users based on search query, role, and active status
  void _filterUsers() {
    setState(() {
      filteredUsers = _applyFilters();
    });
  }

  // Method to filter the list of users based on search, role, and active status
  List<PolmitraUser> _applyFilters() {
    String searchQuery = _searchController.text.trim().toLowerCase(); // Convert search query to lowercase for case-insensitive matching

    return users.where((user) {
      // Check if the user's name or email matches the search query
      bool searchMatches = user.name.toLowerCase().contains(searchQuery) ||
          user.email.toLowerCase().contains(searchQuery);

      var role = user.role.split('.')[1];
      // Role filter based on string comparison
      bool roleMatches = _filterRoleOption == FilterRoleOption.all ||
          (_filterRoleOption == FilterRoleOption.superadmin && role == 'superadmin') ||
          (_filterRoleOption == FilterRoleOption.neta && role == 'neta') ||
          (_filterRoleOption == FilterRoleOption.karyakarta && role == 'karyakarta');

      // Debugging output to verify role matching
      print("User: ${user.name}, Role: ${user.role}, Role Matches: $roleMatches");

      // Active status filter
      bool activeMatches = _filterActive == FilterActiveOption.all ||
          (_filterActive == FilterActiveOption.active && user.isActive) ||
          (_filterActive == FilterActiveOption.inactive && !user.isActive);

      // Return true if all conditions are met
      return searchMatches && roleMatches && activeMatches;
    }).toList();
  }

  // Widget for the search field
  Widget _searchField() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          labelText: 'Search by name or email', // Label for the search field
          labelStyle: TextStyle(fontSize: 14),
          suffixIcon: Icon(Icons.search), // Search icon
          border: UnderlineInputBorder(), // Underline border
        ),
      ),
    );
  }

  // Widget for the filter dropdowns (Role and Active status)
  Widget _filterWidgetsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        /// active status dropdown
        DropdownButton<FilterActiveOption>(
          value: _filterActive,
          onChanged: (value) {
            setState(() {
              _filterActive = value ?? FilterActiveOption.all; // Update active status filter
            });
            _filterUsers(); // Apply filters after changing
          },
          items: FilterActiveOption.values.map((option) {
            String text = option == FilterActiveOption.all
                ? 'All Users'
                : option == FilterActiveOption.active
                ? 'Active Users'
                : 'Inactive Users';
            return DropdownMenuItem(
              value: option,
              child: Text(text), // Display text for each option
            );
          }).toList(),
        ),
        const SizedBox(width: 20), // Space between the dropdowns

        /// user role dropdown
        DropdownButton<FilterRoleOption>(
          value: _filterRoleOption,
          onChanged: (value) {
            setState(() {
              _filterRoleOption = value ?? FilterRoleOption.all; // Update role filter
            });
            _filterUsers(); // Apply filters after changing
          },
          items: FilterRoleOption.values.map((option) {
            // Map enum to user-friendly string
            String text;
            switch (option) {
              case FilterRoleOption.superadmin:
                text = 'Superadmin';
                break;
              case FilterRoleOption.neta:
                text = 'Neta';
                break;
              case FilterRoleOption.karyakarta:
                text = 'Karyakarta';
                break;
              case FilterRoleOption.all:
              default:
                text = 'All';
            }
            return DropdownMenuItem(
              value: option,
              child: Text(text), // Display text for each option
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<UserBloc, UserState>(
        buildWhen: (previous, current) {
          return current is UserLoading || current is UsersLoaded || current is UserError;
        },
        listener: (context, state) {
          if (state is UserError) {
            // Display error message if there is an error
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text("Error loading users: ${state.message}")));
          } else if (state is UsersLoaded) {
            // Update the users list and apply filters when users are loaded
            setState(() {
              users = state.users;
              filteredUsers = _applyFilters();
            });
          }
        },
        builder: (context, state) {
          if (state is UserLoading) {
            // Display a loading spinner while users are loading
            return const Center(child: CircularProgressIndicator());
          } else if (state is UsersLoaded) {
            // Display the filtered list of users
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _searchField(), // Search field
                  _filterWidgetsRow(), // Filter dropdowns
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        PolmitraUser user = filteredUsers[index];
                        return ListTile(
                          title: TextBuilder.getText(
                              text: user.name, fontWeight: FontWeight.bold, fontSize: 16),
                          subtitle: Text(user.email),
                          leading: const CircleAvatar(
                            backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Placeholder image
                          ),
                          trailing: Switch(
                            activeColor: Colors.blue,
                            trackColor: MaterialStateColor.resolveWith((states) => Colors.grey),
                            value: user.isActive,
                            onChanged: (value) {
                              // Update user's active status
                              BlocProvider.of<UserBloc>(context)
                                  .add(UpdateUserActiveStatus(user.uid, value));
                            },
                          ),
                          onTap: () => _showUserDetailsBottomSheet(user), // Show user details on tap
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          } else if (state is UserError) {
            // Display error message when users fail to load
            return Center(child: Text("Error loading users: ${state.message}"));
          } else {
            // Display message when there is no specific state
            return const Center(child: Text("No data available"));
          }
        },
      ),
    );
  }

  // Show the user details in a bottom sheet
  void _showUserDetailsBottomSheet(PolmitraUser user) {
    _userDetailsBottomSheetController = showBottomSheet(
      context: context,
      builder: (context) {
        return UserDetailsScreen(user: user); // Pass the user object to the details screen
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose the search controller when the widget is disposed
    _userDetailsBottomSheetController?.close(); // Close the bottom sheet if it's open
    super.dispose();
  }
}
