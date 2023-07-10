part of 'task_cubit.dart';

abstract class TaskState {}

class Empty extends TaskState {}

class TaskLoading extends TaskState {}

class TasksLoaded extends TaskState {
  List<Task> taskList;

  TasksLoaded(this.taskList);
}

class TaskLoaded extends TaskState {
  Task task;

  TaskLoaded(this.task);
}

class TaskError extends TaskState {}
