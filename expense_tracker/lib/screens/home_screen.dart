import 'package:flutter/material.dart';
import 'package:expense_tracker/services/auth_service.dart';
import 'package:expense_tracker/screens/add_expense_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // --- NEW: Helper method to show the logout confirmation dialog ---
  Future<void> _showLogoutDialog(BuildContext context, AuthService auth) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to dismiss
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Confirm Logout'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to log out?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                // Just close the dialog
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Make the logout button stand out
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
              onPressed: () async {
                // Close the dialog first
                Navigator.of(dialogContext).pop();
                // Then perform the sign out
                await auth.signOut();
                // The AuthGate will handle navigation to the LoginScreen
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthService auth = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            // --- MODIFIED: The onPressed callback now calls our dialog ---
            onPressed: () {
              _showLogoutDialog(context, auth);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              const TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: Icon(Icons.close),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons Grid
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildActionButton(context,
                      icon: Icons.receipt,
                      label: 'Scan Receipt',
                      onPressed: () { /* TODO: Implement Phase 6 */ }),
                  _buildActionButton(context,
                      icon: Icons.picture_as_pdf,
                      label: 'Parse PDF',
                      onPressed: () { /* TODO: Implement Phase 6 */ }),
                  _buildActionButton(context,
                      icon: Icons.mic,
                      label: 'Voice to Text',
                      onPressed: () { /* TODO: Implement Phase 4 */ }),
                  _buildActionButton(context,
                      icon: Icons.edit_note,
                      label: 'Text Entry',
                      onPressed: () {  Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
      ); }),
                ],
              ),
              const SizedBox(height: 24),

              // Reports Section
              _buildSectionHeader('Reports'),
              const SizedBox(height: 16),
              _buildActionButton(context,
                  icon: Icons.calendar_today,
                  label: 'Monthly Report',
                  onPressed: () { /* TODO: Implement Phase 5 */ },
                  isFullWidth: true),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                   _buildActionButton(context,
                      icon: Icons.calendar_view_week,
                      label: 'Yearly Report',
                      onPressed: () { /* TODO: Implement Phase 5 */ }),
                  _buildActionButton(context,
                      icon: Icons.edit_calendar,
                      label: 'Custom Report',
                      onPressed: () { /* TODO: Implement Phase 5 */ }),
                ],
              ),
               const SizedBox(height: 24),

              // Personal Section
              _buildSectionHeader('Personal'),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildActionButton(context,
                      icon: Icons.person_outline,
                      label: 'Profile',
                      onPressed: () { /* TODO: Implement */ }),
                  _buildActionButton(context,
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      onPressed: () { /* TODO: Implement */ }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for section headers (no changes)
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  // Helper widget for the reusable action buttons (no changes)
  Widget _buildActionButton(BuildContext context,
      {required IconData icon, required String label, required VoidCallback onPressed, bool isFullWidth = false}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: isFullWidth ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: isFullWidth ? TextAlign.start : TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}