import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import 'task_repository.dart';
import 'dart:developer' as dev;

class TaskApiService {
  static const String baseUrl = "https://dummyjson.com";

  static Future<List<Task>> fetchTasks() async {
    final response = await http.get(
      Uri.parse("$baseUrl/todos"),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List todos = data["todos"];

      dev.log("status code: ${response.statusCode}\n ${todos}", name:"TaskApiService");
      final random = Random();

      final priorities = ["niski", "sredni", "wysoki"];

      return todos.map<Task>((todo) {
        final priority =
        priorities[random.nextInt(priorities.length)];

        return Task(
          id: todo["id"],
          title: todo["todo"],
          deadline: "brak deadline",
          priority: priority,
          done: todo["completed"] ?? false,
        );
      }).toList();
    } else {
      // i tutaj dev.log z bledem elo :v:
      throw Exception("Blad pobierania danych");
    }
  }
}