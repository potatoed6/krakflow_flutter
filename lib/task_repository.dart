import 'dart:math';

class Task {
  int id;
  String title;
  String deadline;
  String priority;
  bool done;

  Task({
    required this.id,
    required this.title,
    required this.deadline,
    this.priority = "normal",
    this.done = false,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "deadline": deadline,
      "priority": priority,
      "done": done,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: Random().nextInt(1000000),
      title: map["title"],
      deadline: map["deadline"],
      priority: map["priority"] ?? "normal",
      done: map["done"] ?? false,
    );
  }
}

class TaskRepository {
  static List<Task> tasks = [
    Task(
      id: 1,
      title: "Projekt Flutter",
      deadline: "jutro",
    ),
    Task(
      id: 2,
      title: "Oddać raport",
      deadline: "dzisiaj",
      done: true,
    ),
    Task(
      id: 3,
      title: "Powtórzyć widgety",
      deadline: "w piątek",
      done: true,
    ),
  ];
}