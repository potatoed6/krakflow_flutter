class Task {
  final String title;
  final String deadline;
  final bool done;

  Task({required this.title, required this.deadline, this.done=false});
}

class TaskRepository {
  static List<Task> tasks = [
    Task(
      title: "Projekt Flutter",
      deadline: "jutro",
      done: false,
    ),
    Task(
      title: "Oddać raport",
      deadline: "dzisiaj",
      done: true,
    ),
    Task(
      title: "Powtórzyć widgety",
      deadline: "w piątek",
      done: true,
    ),
    Task(title: "Przyjsc do lekarza", deadline:"jutro", done: true,),
    Task(title: "Zjesc kolacje", deadline:"wczoraj", done: true,),
    Task(title: "Przyniejsc smieci", deadline: "pojutrze", done: true,),
    Task(title: "Umyc pralke", deadline: "po pojutrze", done: true,),
  ];
}

