import 'package:frontend/models/task.dart';
import 'package:hive_flutter/hive_flutter.dart';

void init() async {
  await Hive.initFlutter();

  Hive.registerAdapter(TaskAdapter());

  await Hive.openBox<Task>('tasks');
}
