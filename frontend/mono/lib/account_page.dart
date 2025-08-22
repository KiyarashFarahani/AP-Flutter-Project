import 'package:flutter/material.dart';
import 'package:mono/models/user.dart';
import 'package:mono/services/account_service.dart';
import 'package:mono/login.dart';
import 'package:file_picker/file_picker.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final AccountService accountService = AccountService();
  User? currentUser;
  Map<String, int> userStats = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    setState(() => isLoading = true);

    final user = await accountService.getCurrentUser();
    final stats = await accountService.getUserStats();

    setState(() {
      currentUser = user;
      userStats = stats;
      isLoading = false;
    });
  }

  Future<void> pickProfilePicture() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final success = await accountService.updateProfilePicture(result.files.single.path!);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated successfully!')),
          );
          loadUserData();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile picture: $e')),
        );
      }
    }
  }

  Future<void> handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await accountService.logout();
      if (success && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Login()),
              (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Account', style: textTheme.titleLarge),
          backgroundColor: colorScheme.surface,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Account', style: textTheme.titleLarge),
          backgroundColor: colorScheme.surface,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text('Unable to load user data', style: textTheme.titleMedium),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: loadUserData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.primaryContainer,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      GestureDetector(
                        onTap: pickProfilePicture,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: colorScheme.onPrimary.withOpacity(0.1),
                              backgroundImage: currentUser!.profilePictureUrl != null
                                  ? NetworkImage(currentUser!.profilePictureUrl!)
                                  : null,
                              child: currentUser!.profilePictureUrl == null
                                  ? Text(
                                currentUser!.initials,
                                style: textTheme.headlineMedium?.copyWith(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: colorScheme.secondary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: colorScheme.onSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currentUser!.displayName,
                            style: textTheme.headlineSmall?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (currentUser!.isVerified == true) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.verified,
                              color: colorScheme.tertiary,
                              size: 20,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${currentUser!.username}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimary.withOpacity(0.8),
                        ),
                      ),
                      if (currentUser!.bio != null) ...[
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            currentUser!.bio!,
                            textAlign: TextAlign.center,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onPrimary.withOpacity(0.9),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildStatsSection(colorScheme, textTheme),
                  const SizedBox(height: 24),

                  buildQuickActionsSection(colorScheme, textTheme),
                  const SizedBox(height: 24),

                  buildSettingsSection(colorScheme, textTheme),
                  const SizedBox(height: 24),

                  buildAccountSection(colorScheme, textTheme),
                  const SizedBox(height: 32),

                  buildLogoutButton(colorScheme, textTheme),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatsSection(ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics_outlined, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Your Music Stats',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: buildStatItem(
                    'Songs Played',
                    userStats['songsPlayed']?.toString() ?? '0',
                    Icons.music_note,
                    colorScheme,
                    textTheme,
                  ),
                ),
                Expanded(
                  child: buildStatItem(
                    'Playlists',
                    userStats['playlistsCreated']?.toString() ?? '0',
                    Icons.playlist_play,
                    colorScheme,
                    textTheme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: buildStatItem(
                    'Hours Listened',
                    userStats['hoursListened']?.toString() ?? '0',
                    Icons.access_time,
                    colorScheme,
                    textTheme,
                  ),
                ),
                Expanded(
                  child: buildStatItem(
                    'Liked Songs',
                    userStats['totalLikes']?.toString() ?? '0',
                    Icons.favorite,
                    colorScheme,
                    textTheme,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStatItem(String label, String value, IconData icon,
      ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: colorScheme.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget buildQuickActionsSection(ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flash_on_outlined, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Quick Actions',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: buildActionButton(
                    'Edit Profile',
                    Icons.edit_outlined,
                        () => showEditProfileDialog(),
                    colorScheme,
                    textTheme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: buildActionButton(
                    'Liked Songs',
                    Icons.favorite_outline,
                        () => {},
                    colorScheme,
                    textTheme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: buildActionButton(
                    'My Playlists',
                    Icons.playlist_play_outlined,
                        () => {},
                    colorScheme,
                    textTheme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: buildActionButton(
                    'Download',
                    Icons.download_outlined,
                        () => {},
                    colorScheme,
                    textTheme,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildActionButton(String label, IconData icon, VoidCallback onTap,
      ColorScheme colorScheme, TextTheme textTheme) {
    return Material(
      color: colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, color: colorScheme.onSecondaryContainer, size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSettingsSection(ColorScheme colorScheme, TextTheme textTheme) {
    final prefs = currentUser?.preferences ?? {};

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings_outlined, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Settings',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            buildSettingsTile(
              'Notifications',
              'Get notified about new releases and updates',
              Icons.notifications_outlined,
              prefs['notifications'] ?? true,
                  (value) => updatePreference('notifications', value),
              colorScheme,
              textTheme,
            ),
            buildSettingsTile(
              'Auto-Play',
              'Automatically play similar songs when queue ends',
              Icons.play_circle_outline,
              prefs['autoPlay'] ?? true,
                  (value) => updatePreference('autoPlay', value),
              colorScheme,
              textTheme,
            ),
            buildSettingsTile(
              'High Quality Audio',
              'Stream music in high quality (uses more data)',
              Icons.high_quality_outlined,
              prefs['highQuality'] ?? true,
                  (value) => updatePreference('highQuality', value),
              colorScheme,
              textTheme,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.palette_outlined, color: colorScheme.primary),
              title: Text('Theme', style: textTheme.bodyLarge),
              subtitle: Text('Choose your preferred theme', style: textTheme.bodySmall),
              trailing: Icon(Icons.chevron_right, color: colorScheme.onSurface),
              onTap: () => showThemeDialog(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSettingsTile(String title, String subtitle, IconData icon,
      bool value, Function(bool) onChanged,
      ColorScheme colorScheme, TextTheme textTheme) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: colorScheme.primary),
      title: Text(title, style: textTheme.bodyLarge),
      subtitle: Text(subtitle, style: textTheme.bodySmall),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: colorScheme.primary,
      ),
    );
  }

  Widget buildAccountSection(ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_circle_outlined, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Account',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.email_outlined, color: colorScheme.primary),
              title: Text('Email', style: textTheme.bodyLarge),
              subtitle: Text(currentUser!.email ?? 'No email', style: textTheme.bodySmall),
              trailing: Icon(Icons.chevron_right, color: colorScheme.onSurface),
              onTap: () => showEditEmailDialog(),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.lock_outline, color: colorScheme.primary),
              title: Text('Change Password', style: textTheme.bodyLarge),
              subtitle: Text('Update your account password', style: textTheme.bodySmall),
              trailing: Icon(Icons.chevron_right, color: colorScheme.onSurface),
              onTap: () => showChangePasswordDialog(),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.privacy_tip_outlined, color: colorScheme.primary),
              title: Text('Privacy & Security', style: textTheme.bodyLarge),
              subtitle: Text('Manage your privacy settings', style: textTheme.bodySmall),
              trailing: Icon(Icons.chevron_right, color: colorScheme.onSurface),
              onTap: () => showPrivacyDialog(),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.help_outline, color: colorScheme.primary),
              title: Text('Help & Support', style: textTheme.bodyLarge),
              subtitle: Text('Get help or contact support', style: textTheme.bodySmall),
              trailing: Icon(Icons.chevron_right, color: colorScheme.onSurface),
              onTap: () => showHelpDialog(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLogoutButton(ColorScheme colorScheme, TextTheme textTheme) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: handleLogout,
        icon: Icon(Icons.logout, color: colorScheme.error),
        label: Text(
          'Logout',
          style: textTheme.labelLarge?.copyWith(color: colorScheme.error),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: colorScheme.error),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  void updatePreference(String key, bool value) {
    if (currentUser != null) {
      final updatedPrefs = Map<String, dynamic>.from(currentUser!.preferences ?? {});
      updatedPrefs[key] = value;

      final updatedUser = currentUser!.copyWith(preferences: updatedPrefs);
      accountService.updateUser(updatedUser);

      setState(() {
        currentUser = updatedUser;
      });
    }
  }

  void showEditProfileDialog() {
    final nameController = TextEditingController(text: currentUser?.firstName);
    final lastNameController = TextEditingController(text: currentUser?.lastName);
    final bioController = TextEditingController(text: currentUser?.bio);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bioController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final updatedUser = currentUser!.copyWith(
                firstName: nameController.text,
                lastName: lastNameController.text,
                bio: bioController.text,
              );
              accountService.updateUser(updatedUser);
              setState(() => currentUser = updatedUser);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void showEditEmailDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Email'),
        content: const Text('This feature will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: const Text('This feature will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy & Security'),
        content: const Text('Privacy settings will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mono Music Streaming App'),
            SizedBox(height: 8),
            Text('Version: 1.0.0'),
            SizedBox(height: 16),
            Text('For support, please contact:'),
            Text('support@mono.app'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.light_mode),
              title: Text('Light'),
              trailing: Radio(value: 'light', groupValue: 'light', onChanged: null),
            ),
            ListTile(
              leading: Icon(Icons.dark_mode),
              title: Text('Dark'),
              trailing: Radio(value: 'dark', groupValue: 'light', onChanged: null),
            ),
            ListTile(
              leading: Icon(Icons.auto_mode),
              title: Text('System'),
              trailing: Radio(value: 'system', groupValue: 'light', onChanged: null),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Theme preferences saved!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}