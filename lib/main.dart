import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/cubit/task_cubit.dart';
import 'package:frontend/services/dependency_injection.dart' as di;
import 'package:frontend/views/task_list_view.dart';

void main() {
  di.init();

  runApp(MaterialApp(
    theme: ThemeData(
      iconTheme: const IconThemeData(
        size: 40.0,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontSize: 25),
        headlineLarge: TextStyle(fontSize: 40),
        displayMedium: TextStyle(fontSize: 80),
      ),
    ),
    home: BlocProvider(
      create: (context) => TaskCubit()..loadTasks(),
      child: const MainApp(),
    ),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: TaskListView(),
        ),
      ),
    );
  }
}
