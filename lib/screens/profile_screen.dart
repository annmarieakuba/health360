import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'splash_login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh user data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.refreshUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF3A5A98),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3A5A98), Color(0xFF4FC3F7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final user = authProvider.user;

            return SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 20),
                  // Profile Picture Section
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: Color(0xFF3A5A98),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user?.displayName.isNotEmpty == true
                              ? user!.displayName
                              : 'User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user?.email ?? 'No email',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Profile Information Card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 8,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Profile Information',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3A5A98),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _ProfileInfoItem(
                            icon: Icons.email,
                            label: 'Email',
                            value: user?.email ?? 'Not available',
                          ),
                          const Divider(),
                          _ProfileInfoItem(
                            icon: Icons.person,
                            label: 'Username',
                            value: user?.username.isNotEmpty == true
                                ? user!.username
                                : 'Not set',
                          ),
                          const Divider(),
                          _ProfileInfoItem(
                            icon: Icons.badge,
                            label: 'Display Name',
                            value: user?.displayName.isNotEmpty == true
                                ? user!.displayName
                                : 'Not set',
                          ),
                          const Divider(),
                          _ProfileInfoItem(
                            icon: Icons.fingerprint,
                            label: 'User ID',
                            value: user?.uid ?? 'Not available',
                            isLongText: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Account Actions Card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 8,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Account Actions',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3A5A98),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _ActionItem(
                            icon: Icons.delete_forever,
                            title: 'Delete Account',
                            subtitle:
                                'Permanently delete your account and all data',
                            onTap: () =>
                                _showDeleteAccountDialog(context, authProvider),
                            isDestructive: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Shows a comprehensive delete account dialog with multiple confirmation steps
  /// This method implements a two-step confirmation process to prevent accidental deletions
  void _showDeleteAccountDialog(
      BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently lost.',
        ),
        actions: [
          // Cancel button - closes the dialog without any action
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          // Delete button - initiates the deletion process
          TextButton(
            onPressed: () async {
              // Close the first confirmation dialog
              Navigator.pop(context);

              // Step 1: Show a second, more detailed confirmation dialog
              // This provides a final warning with specific details about what will be deleted
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Final Confirmation'),
                  content: const Text(
                    'This is your final warning. Deleting your account will:\n\n'
                    '• Remove all your health data\n'
                    '• Delete your profile information\n'
                    '• Sign you out permanently\n'
                    '• This action cannot be undone\n\n'
                    'Are you absolutely sure?',
                  ),
                  actions: [
                    // Cancel button for final confirmation
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    // Final delete confirmation button
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Yes, Delete My Account'),
                    ),
                  ],
                ),
              );

              // Step 2: If user confirmed, proceed with account deletion
              if (confirmed == true && context.mounted) {
                try {
                  // Step 3: Show loading indicator while deletion is in progress
                  // This prevents user interaction during the deletion process
                  showDialog(
                    context: context,
                    barrierDismissible:
                        false, // User cannot dismiss this dialog
                    builder: (context) => const AlertDialog(
                      content: Row(
                        children: [
                          CircularProgressIndicator(), // Loading spinner
                          SizedBox(width: 16),
                          Text('Deleting account...'), // Loading message
                        ],
                      ),
                    ),
                  );

                  // Step 4: Perform the actual account deletion
                  // This calls the AuthProvider method which handles all data cleanup
                  await authProvider.deleteAccount();

                  // Step 5: Handle successful deletion
                  if (context.mounted) {
                    Navigator.pop(context); // Close the loading dialog

                    // Show success message to user
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Account deleted successfully. All data has been cleared.'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 3), // Show for 3 seconds
                      ),
                    );

                    // Step 6: Navigate to login screen
                    // Clear all navigation routes and go to root
                    // The AuthWrapper will automatically detect the user is logged out
                    // and show the login/signup screen
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const SplashLoginScreen(),
                      ),
                      (route) => false, // Remove all previous routes
                    );
                  }
                } catch (e) {
                  // Step 7: Handle any errors during deletion
                  if (context.mounted) {
                    Navigator.pop(context); // Close the loading dialog

                    // Show error message to user
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete account: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLongText;

  const _ProfileInfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.isLongText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF3A5A98), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: isLongText ? TextOverflow.ellipsis : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _ActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon,
          color: isDestructive ? Colors.red : const Color(0xFF3A5A98),
          size: 28),
      title: Text(title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDestructive ? Colors.red : null,
          )),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}
