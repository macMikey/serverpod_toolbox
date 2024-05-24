import 'package:flutter/material.dart';

///
/// User admin for a serverpod project
///
class UserAdminTab extends StatefulWidget {
    const UserAdminTab({super.key});

    @override
    State<UserAdminTab> createState() => _UserAdminTabState();
}

class _UserAdminTabState extends State<UserAdminTab> {
    final _users = <User>[]; // List to store fetched users
    bool _isLoading = false;

    @override
    void initState() {
        super.initState();
        _fetchUsers(); // Fetch users on initialization
    }

    Future<void> _fetchUsers() async {
        // Replace with your actual logic to fetch users from Serverpod
        setState(() {
                _isLoading = true;
                _users.clear(); // Clear existing user data
                // Add logic to fetch users from Serverpod and populate the _users list
                _isLoading = false;
            });
    }

    Future<void> _deleteUser(User user) async {
        // Replace with your actual logic to delete a user from Serverpod
        setState(() {
                _isLoading = true;
                _users.remove(user); // Optimistic UI update (remove from list)
                // Add logic to delete user from Serverpod
                _isLoading = false;
            });
    }

    Future<void> _updateUser(User user) async {
        // Replace with your actual logic to open a user update dialog or navigate to an update screen
        // You can pass the user object to the update functionality
    }

    Future<void> _unblockUser(User user) async {
        // Replace with your actual logic to unblock a user from Serverpod
        setState(() {
                _isLoading = true;
                // Update user object to reflect unblocked state
                user.isBlocked = false; // Example, update user object
                _isLoading = false;
            });
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: Center(
                child: _isLoading
                ? const CircularProgressIndicator() // Show progress indicator while loading
                : SingleChildScrollView(
                    child: DataTable(
                        columns: const [
                            DataColumn(label: Text('Email')),
                            DataColumn(label: Text('ID')),
                            DataColumn(label: Text('Blocked')),
                            DataColumn(label: Text('Actions')),
                        ],
                        rows: _users.map((user) => _buildUserRow(user)).toList(),
                    ),
                ),
            ),
        );
    }

    DataRow _buildUserRow(User user) {
        return DataRow(
            cells: [
                DataCell(Text(user.email)),
                DataCell(Text(user.id)),
                DataCell(Text(user.isBlocked ? 'Yes' : 'No')),
                DataCell(
                    Row(
                        children: [
                            IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _updateUser(user),
                            ),
                            IconButton(
                                icon: Icon(user.isBlocked ? Icons.lock_open : Icons.lock),
                                onPressed: () => _unblockUser(user),
                            ),
                            IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteUser(user),
                            ),
                        ],
                    ),
                ),
            ],
        );
    }
}

class User {
    final String email;
    final String id;
    bool isBlocked;

    User({required this.email, required this.id, this.isBlocked = false});
}
