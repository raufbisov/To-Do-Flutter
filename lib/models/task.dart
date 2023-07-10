import 'package:hive/hive.dart';
part 'task.g.dart';

@HiveType(typeId: 0)
class Task {
  @HiveField(0, defaultValue: 'New task')
  String title;
  @HiveField(1, defaultValue: false)
  bool isDone;
  @HiveField(2, defaultValue: false)
  bool animate;

  Task({this.title = 'New task', this.isDone = false, this.animate = false});

  Map<String, String> toJson() {
    return {
      'title': title,
      'isDone': isDone.toString(),
    };
  }

  factory Task.fromJson(Map json) {
    return Task(
      title: json['title'],
      isDone: json['isDone'] == 'true',
    );
  }
}
