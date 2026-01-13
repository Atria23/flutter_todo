// --- START OF FILE lib/screens/settings_page.dart (MODIFIED) ---

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'package:doable_todo_list_app/services/notification_service.dart';
import 'package:doable_todo_list_app/providers/todo_provider.dart';
import 'package:doable_todo_list_app/theme/app_theme.dart'; // Import tema

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const _prefsKeyNotifications = 'notifications_enabled';

  bool _notificationsEnabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_prefsKeyNotifications) ?? false;
    setState(() {
      _notificationsEnabled = enabled;
      _loading = false;
    });
  }

  Future<void> _setNotifications(bool value) async {
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);

    if (value) {
      final granted = await NotificationService.requestPermissions();
      if (!mounted) return;
      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification permission denied')),
        );
        value = false;
      } else {
        try {
          final tasks = todoProvider.todos;
          await NotificationService.rescheduleAllNotifications(tasks);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notifications enabled and scheduled')),
          );
        } catch (e) {
          // Menggunakan debugPrint alih-alih print untuk konsistensi di Flutter
          debugPrint('Error rescheduling notifications: $e');
        }
      }
    } else {
      try {
        await NotificationService.cancelAllNotifications();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All notifications cancelled')),
        );
      } catch (e) {
        debugPrint('Error cancelling notifications: $e');
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKeyNotifications, value);
    if (!mounted) return;
    setState(() => _notificationsEnabled = value);
  }

  Future<void> _confirmAndClearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all data?'),
        content: const Text('This will delete all tasks and reset the app to a fresh state. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: accentRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final todoProvider = Provider.of<TodoProvider>(context, listen: false);
    await todoProvider.clearAllTodos();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All data cleared')),
    );
  }

  // Metode _openUrl dihapus karena tidak ada lagi tautan sosial media.

  EdgeInsets get _screenHPad {
    final w = MediaQuery.of(context).size.width;
    final hpad = (w * 0.05).clamp(20.0, 24.0);
    return EdgeInsets.symmetric(horizontal: hpad);
  }

  @override
  Widget build(BuildContext context) {
    const version = '1.0.0';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: darkGrey),
          tooltip: 'Back',
        ),
        title: const Text(
          'Settings',
          style: headline1Style,
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: primaryBlue))
            : ListView(
          padding: _screenHPad.add(const EdgeInsets.only(bottom: 24, top: 16)),
          children: [
            // Section: Notifications
            Text(
              'App Preferences',
              style: subtitle1Style.copyWith(fontSize: 18, color: darkGrey),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: lightGrey,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderGrey),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Enable Notifications',
                    style: body1Style.copyWith(fontSize: 16),
                  ),
                  Switch(
                    value: _notificationsEnabled,
                    onChanged: _setNotifications,
                    activeColor: primaryBlue,
                    inactiveTrackColor: mediumGrey.withOpacity(0.3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section: Data Management
            Text(
              'Data Management',
              style: subtitle1Style.copyWith(fontSize: 18, color: darkGrey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: darkGrey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Adjusted radius
                  ),
                  textStyle: chipTextStyle.copyWith(fontSize: 16, color: Colors.white),
                ),
                onPressed: _confirmAndClearAll,
                child: const Text('Clear All Data'),
              ),
            ),

            const SizedBox(height: 32),
            const Divider(height: 1, color: borderGrey),
            const SizedBox(height: 24),

            // Section: About This App
            Text(
              'About This App',
              style: subtitle1Style.copyWith(fontSize: 18, color: darkGrey),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: lightGrey,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderGrey),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'License',
                        style: body2Style.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text('MIT', style: body2Style.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Version',
                        style: body2Style.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(version, style: body2Style.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),


            SizedBox(height: MediaQuery.of(context).size.height * 0.15), // Menyesuaikan jarak

            // Logo aplikasi di bagian bawah
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset('assets/trans_logo.svg', height: 64),
                const SizedBox(height: 12),
                Text(
                  'Your Task Management App', // Teks generik untuk aplikasi
                  style: body2Style.copyWith(fontWeight: FontWeight.w600, color: mediumGrey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Widget _SocialIconButton dihapus karena tidak digunakan lagi.
// --- END OF FILE lib/screens/settings_page.dart (MODIFIED) ---