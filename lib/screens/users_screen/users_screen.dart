import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polmitra_admin/bloc/users/user_bloc.dart';
import 'package:polmitra_admin/bloc/users/user_event.dart';
import 'package:polmitra_admin/bloc/users/user_state.dart';
import 'package:polmitra_admin/enums/filter_options.dart';
import 'package:polmitra_admin/enums/user_enums.dart';
import 'package:polmitra_admin/models/user.dart';
import 'package:polmitra_admin/utils/text_builder.dart';
import 'package:url_launcher/url_launcher.dart';

// Stateful widget for the Users Screen
class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  // Initial filter options
  FilterRoleOption _filterRoleOption = FilterRoleOption.all;
  FilterActiveOption _filterActive = FilterActiveOption.all;

  @override
  void initState() {
    super.initState();
    _loadUsers(); // Load users at startup
  }

  // Method to load users via the UserBloc
  void _loadUsers() {
    BlocProvider.of<UserBloc>(context).add(LoadUsers());
  }

  // Method to filter the list of users based on role and active status
  List<PolmitraUser> _applyFilters(List<PolmitraUser> users) {
    return users.where((user) {
      bool roleMatches;
      switch (_filterRoleOption) {
        case FilterRoleOption.superadmin:
          roleMatches = user.role == UserRole.superadmin.toString();
          break;
        case FilterRoleOption.neta:
          roleMatches = user.role == UserRole.neta.toString();
          break;
        case FilterRoleOption.karyakarta:
          roleMatches = user.role == UserRole.karyakarta.toString();
          break;
        case FilterRoleOption.all:
        default:
          roleMatches = true;
      }

      bool activeMatches;
      switch (_filterActive) {
        case FilterActiveOption.active:
          activeMatches = user.isActive;
          break;
        case FilterActiveOption.inactive:
          activeMatches = !user.isActive;
          break;
        case FilterActiveOption.all:
        default:
          activeMatches = true;
      }

      return roleMatches && activeMatches;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            // Display loading indicator while users are being fetched
            return const Center(child: CircularProgressIndicator());
          } else if (state is UsersLoaded) {
            // Filter users based on selected criteria
            var filteredUsers = _applyFilters(state.users);
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Filter dropdown menus
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DropdownButton<FilterActiveOption>(
                        value: _filterActive,
                        onChanged: (value) {
                          setState(() {
                            _filterActive = value ?? FilterActiveOption.all;
                          });
                        },
                        items: FilterActiveOption.values.map((option) {
                          String text = option == FilterActiveOption.all ? 'All Users' :
                          option == FilterActiveOption.active ? 'Active Users' : 'Inactive Users';
                          return DropdownMenuItem(
                            value: option,
                            child: Text(text),
                          );
                        }).toList(),
                      ),
                      const SizedBox(width: 20),
                      DropdownButton<FilterRoleOption>(
                        value: _filterRoleOption,
                        onChanged: (value) {
                          setState(() {
                            _filterRoleOption = value ?? FilterRoleOption.all;
                          });
                        },
                        items: FilterRoleOption.values.map((option) {
                          String text = option.toString().split('.').last.capitalize();
                          return DropdownMenuItem(
                            value: option,
                            child: Text(text),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        PolmitraUser user = filteredUsers[index];
                        return ListTile(
                          title: TextBuilder.getText(text: user.name, fontWeight: FontWeight.bold, fontSize: 16),
                          subtitle: Text(user.email),
                          leading: const CircleAvatar(
                            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                          ),
                          trailing: Switch(
                            activeColor: Colors.blue,
                            trackColor: MaterialStateColor.resolveWith((states) => Colors.grey),
                            value: user.isActive,
                            onChanged: (value) {
                              // Update user's active status
                              BlocProvider.of<UserBloc>(context).add(UpdateUserActiveStatus(user.uid, value));
                            },
                          ),
                          onTap: () {
                            // Show user details in an alert dialog
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: TextBuilder.getText(text: user.email, fontWeight: FontWeight.bold, fontSize: 16),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: "Email: ",
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
                                            ),
                                            TextSpan(
                                              text: user.email,
                                              style: const TextStyle(fontSize: 14, color: Colors.black),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: "Role: ",
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
                                            ),
                                            TextSpan(
                                              text: user.role,
                                              style: const TextStyle(fontSize: 14, color: Colors.black),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (user.role == UserRole.karyakarta.toString()) ...[
                                        const SizedBox(height: 10),
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              const TextSpan(
                                                text: "Points: ",
                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
                                              ),
                                              TextSpan(
                                                text: '${user.points}',
                                                style: const TextStyle(fontSize: 14, color: Colors.black),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 10),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: "Contact: ",
                                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                            ),
                                            TextSpan(
                                              text: user.email,
                                              style: const TextStyle(color: Colors.blue),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () async {
                                                  final mailtourl = 'mailto:${user.email}';
                                                  final uri = Uri.parse(mailtourl);
                                                  if (await canLaunchUrl(uri)) {
                                                    launchUrl(uri);
                                                  }
                                                },
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: "Active: ",
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
                                            ),
                                            TextSpan(
                                              text: user.isActive ? "Yes" : "No",
                                              style: TextStyle(fontSize: 14, color: user.isActive ? Colors.green : Colors.red),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: TextBuilder.getText(text: "Close", fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          } else if (state is UserError) {
            // Display error message
            return Center(child: Text("Error loading users: ${state.message}"));
          } else {
            // Display message when there is no specific state
            return const Center(child: Text("No data available"));
          }
        },
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
