// --- START OF FILE lib/main.dart (Asumsi) ---
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:doable_todo_list_app/models/todo.dart';
import 'package:doable_todo_list_app/providers/todo_provider.dart';
import 'package:doable_todo_list_app/screens/home_page.dart';
import 'package:doable_todo_list_app/screens/add_task_page.dart';
import 'package:doable_todo_list_app/screens/edit_task_page.dart';
import 'package:doable_todo_list_app/screens/settings_page.dart';
import 'package:doable_todo_list_app/services/notification_service.dart';

// Import tema dari lokasi yang sudah ditentukan
import 'package:doable_todo_list_app/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TodoAdapter());
  await Hive.openBox<Todo>('todos');
  await NotificationService.initializeNotifications();

  runApp(
    ChangeNotifierProvider(
      create: (context) => TodoProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doable Todo List',
      theme: ThemeData(
        // Gunakan warna utama dari tema Anda
        primaryColor: primaryBlue,
        colorScheme: ColorScheme.light(
          primary: primaryBlue,
          secondary: darkGrey,
          error: accentRed,
          background: Colors.white,
          onBackground: darkGrey,
          surface: Colors.white,
          onSurface: darkGrey,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.white,
          iconTheme: IconThemeData(color: darkGrey),
          titleTextStyle: headline1Style,
        ),
        textTheme: TextTheme(
          displayLarge: headline1Style,
          displayMedium: headline1Style.copyWith(fontSize: 24),
          headlineMedium: subtitle1Style,
          titleLarge: body1Style,
          bodyLarge: body1Style,
          bodyMedium: body2Style,
          labelLarge: chipTextStyle,
          labelMedium: metaStyle,
          // Anda dapat menambahkan lebih banyak gaya teks sesuai kebutuhan
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: body2Style.copyWith(color: mediumGrey),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          filled: true,
          fillColor: lightGrey,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderGrey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryBlue, width: 2),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primaryBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: chipTextStyle.copyWith(fontSize: 16, color: Colors.white),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: darkGrey,
            textStyle: chipTextStyle,
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return primaryBlue;
            }
            return darkGrey;
          }),
          trackColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return primaryBlue.withOpacity(0.5);
            }
            return lightGrey;
          }),
        ),
        // Tambahkan properti tema lainnya jika diperlukan
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        'add_task': (context) => const AddTaskPage(),
        'edit_task': (context) => const EditTaskPage(),
        'settings': (context) => const SettingsPage(),
      },
    );
  }
}