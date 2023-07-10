import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/cubit/task_cubit.dart';
import 'package:frontend/models/task.dart';

class TaskListView extends StatefulWidget {
  const TaskListView({super.key});

  @override
  State<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .9,
      width: MediaQuery.of(context).size.width * .8,
      child: BlocBuilder<TaskCubit, TaskState>(
        builder: (context, state) {
          if (state is TasksLoaded) {
            var doneTaskList =
                state.taskList.where((element) => element.isDone).toList();
            var ongoingTaskList =
                state.taskList.where((element) => !element.isDone).toList();
            return Column(
              children: [
                Text(
                  'Tasks',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * .1),
                Expanded(
                  child: ListView(
                    children: [
                      Text(
                        'Ongoing',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * .05),
                      for (var task in ongoingTaskList)
                        getTaskTile(
                          task,
                          context,
                          BlocProvider.of<TaskCubit>(context),
                          state.taskList.indexOf(task),
                        ),
                      SizedBox(height: MediaQuery.of(context).size.height * .1),
                      Text(
                        'Done',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * .05),
                      for (var task in doneTaskList)
                        getTaskTile(
                          task,
                          context,
                          BlocProvider.of<TaskCubit>(context),
                          state.taskList.indexOf(task),
                        ),
                    ],
                  ),
                ),
                MaterialButton(
                    onPressed: () async {
                      await showCreateTaskDialog(
                              context, BlocProvider.of<TaskCubit>(context))
                          .then((value) async {
                        await BlocProvider.of<TaskCubit>(context).loadTasks();
                      });
                    },
                    height: 70.0,
                    color: Colors.black87,
                    shape: const CircleBorder(),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                    )),
              ],
            );
          } else if (state is TaskLoading) {
            return const SizedBox(
              child: CircularProgressIndicator(),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget getTaskTile(
      Task task, BuildContext context, TaskCubit taskCubit, int index) {
    late AnimationController slideRightAnimationController;
    late Animation slideRightAnimation;

    slideRightAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    slideRightAnimation = Tween<double>(begin: 0.0, end: 350.0)
        .animate(slideRightAnimationController);

    late AnimationController slideLeftAnimationController;
    late Animation slideLeftAnimation;

    slideLeftAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    slideLeftAnimation = Tween<double>(begin: 350.0, end: 0.0)
        .animate(slideLeftAnimationController);

    return AnimatedBuilder(
      animation: slideLeftAnimation,
      builder: (context, child) {
        if (task.animate) {
          slideLeftAnimationController
              .forward()
              .then((value) => task.animate = false);
        } else {
          slideLeftAnimationController.value = 350;
        }
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..translate(slideLeftAnimation.value),
          child: AnimatedBuilder(
            animation: slideRightAnimation,
            builder: (context, child) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..translate(slideRightAnimation.value),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        child: Icon(!task.isDone
                            ? Icons.circle_outlined
                            : Icons.check_circle_outline),
                        onTap: () async {
                          task.animate = true;
                          await slideRightAnimationController.forward();
                          await taskCubit.toggleTask(task, index);
                          await taskCubit.loadTasks();
                        },
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * .05),
                      Expanded(
                        child: Text(
                          task.title,
                          style: task.isDone
                              ? Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(
                                    color: Colors.grey.shade700,
                                  )
                              : Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(
                                    color: Colors.black87,
                                  ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return SimpleDialog(
                                title: Text(
                                  'Are you sure?',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                children: [
                                  TextButton(
                                    onPressed: () async {
                                      await slideRightAnimationController
                                          .forward();
                                      await taskCubit.deleteTask(task, index);
                                      await taskCubit.loadTasks().then(
                                          (value) =>
                                              Navigator.of(context).pop());
                                    },
                                    child: const Text('Delete'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

Future<dynamic> showCreateTaskDialog(
    BuildContext context, TaskCubit cubit) async {
  final TextEditingController textController = TextEditingController();
  return await showDialog(
    context: context,
    builder: (context) {
      return AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 900),
        child: SimpleDialog(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 50,
            vertical: 25,
          ),
          title: const Text(
            'Create a task',
            style: TextStyle(fontSize: 30),
          ),
          children: [
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                  hintText: 'Enter the task title',
                  hintStyle: TextStyle(fontSize: 15)),
            ),
            const SizedBox(height: 10),
            TextButton(
              child: const Text(
                'Create',
                style: TextStyle(fontSize: 20, color: Colors.black87),
              ),
              onPressed: () async {
                if (textController.value.text.isNotEmpty) {
                  await cubit.addTask({
                    'title': textController.value.text,
                    'isDone': 'false'
                  }).then((value) => Navigator.of(context).pop());
                }
              },
            ),
            const SizedBox(height: 10),
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 20, color: Colors.black87),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}
