import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/models/task.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  TaskCubit() : super(Empty());

  Future<void> toggleTask(Task task, int index) async {
    task.isDone = !task.isDone;
    await Hive.box<Task>('tasks').putAt(index, task);
  }

  Future<void> loadTasks() async {
    emit(TasksLoaded(await Hive.openBox<Task>('tasks')
        .then((value) => value.values.toList())));
  }

  Future<void> addTask(Map json) async {
    emit(TaskLoading());
    await Hive.openBox<Task>('tasks').then((value) {
      value.add(Task.fromJson(json));
    });
  }

  Future<void> deleteTask(Task task, index) async {
    await Hive.openBox<Task>('tasks').then((value) {
      value.deleteAt(index);
    });
  }
}
