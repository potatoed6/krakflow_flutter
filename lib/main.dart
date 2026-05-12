import 'package:flutter/material.dart';
import 'task_repository.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KrakFlow',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'KrakFlow'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Zadanie 4: zmienna filtra
  String selectedFilter = "wszystkie";

  // Zadanie 4: logika filtrowania
  List<Task> get filteredTasks {
    if (selectedFilter == "wykonane") {
      return TaskRepository.tasks.where((task) => task.done).toList();
    } else if (selectedFilter == "do zrobienia") {
      return TaskRepository.tasks.where((task) => !task.done).toList();
    }
    return TaskRepository.tasks;
  }

  // Zadanie 5: AlertDialog + usuwanie wszystkich zadań
  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Potwierdzenie"),
          content: const Text("Czy na pewno chcesz usunąć wszystkie zadania?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Anuluj"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  TaskRepository.tasks.clear();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Usunięto wszystkie zadania")),
                );
              },
              child: const Text(
                "Usuń",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = filteredTasks;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        // Zadanie 5: ikona kosza w AppBar
        actions: [
          IconButton(
            icon: Icon(
              Icons.delete,
              // Opcjonalne: wyszarz ikonę gdy lista jest pusta
              color: TaskRepository.tasks.isEmpty ? Colors.grey : null,
            ),
            onPressed: TaskRepository.tasks.isEmpty
                ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Lista zadań jest już pusta")),
              );
            }
                : _showDeleteAllDialog,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 25, bottom: 5, left: 35),
            child: Text(
              "Masz dziś ${TaskRepository.tasks.length} zadania",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          // Zadanie 4: FilterBar jako osobny widget (rozszerzenie opcjonalne)
          FilterBar(
            selectedFilter: selectedFilter,
            onFilterChanged: (filter) {
              setState(() {
                selectedFilter = filter;
              });
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                // Zadanie 1: Dismissible do usuwania zadań
                return Dismissible(
                  key: ValueKey(task.title + task.deadline),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    final removedTitle = task.title;
                    setState(() {
                      TaskRepository.tasks.remove(task);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Usunięto: $removedTitle"),
                      ),
                    );
                  },
                  child: TaskCard(
                    title: task.title,
                    subtitle: "termin: ${task.deadline}",
                    done: task.done,
                    // Zadanie 3: zmiana checkboxa
                    onChanged: (value) {
                      setState(() {
                        task.done = value!;
                      });
                    },
                    // Zadanie 2: kliknięcie otwiera ekran edycji
                    onTap: () async {
                      final Task? updatedTask = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditTaskScreen(task: task),
                        ),
                      );
                      if (updatedTask != null) {
                        setState(() {
                          final realIndex = TaskRepository.tasks.indexOf(task);
                          if (realIndex != -1) {
                            TaskRepository.tasks[realIndex] = updatedTask;
                          }
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final Task? newTask = await Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  AddTaskScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(0.5, 1.0),
                  end: Offset.zero,
                ).animate(animation);
                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
            ),
          );
          if (newTask != null) {
            setState(() {
              TaskRepository.tasks.add(newTask);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Zadanie 4 (rozszerzenie): osobny widget FilterBar
class FilterBar extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const FilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = ["wszystkie", "do zrobienia", "wykonane"];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: filters.map((filter) {
          final isActive = selectedFilter == filter;
          return TextButton(
            onPressed: () => onFilterChanged(filter),
            style: TextButton.styleFrom(
              // Zadanie 4: wyróżnij aktywny filtr kolorem
              foregroundColor: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
              textStyle: TextStyle(
                fontWeight:
                isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            child: Text(
              filter[0].toUpperCase() + filter.substring(1),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Zadanie 3: TaskCard z Checkbox
class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool done;
  final ValueChanged<bool?>? onChanged;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.done,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(
          value: done,
          onChanged: onChanged,
        ),
        title: Text(
          title,
          style: TextStyle(
            // Zadanie 3: przekreślenie dla wykonanych zadań
            decoration: done ? TextDecoration.lineThrough : TextDecoration.none,
            // Zadanie 3: jaśniejszy kolor dla wykonanych
            color: done ? Colors.grey : null,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: done ? Colors.grey[400] : null,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class AddTaskScreen extends StatelessWidget {
  AddTaskScreen({super.key});
  final TextEditingController titleController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nowe zadanie"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Tytuł zadania",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: deadlineController,
              decoration: const InputDecoration(
                labelText: "Deadline zadania",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final newTask = Task(
                  title: titleController.text,
                  deadline: deadlineController.text,
                );
                Navigator.pop(context, newTask);
              },
              child: const Text("Zapisz"),
            ),
          ],
        ),
      ),
    );
  }
}

// Zadanie 2: ekran edycji zadania
class EditTaskScreen extends StatefulWidget {
  final Task task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController titleController;
  late TextEditingController deadlineController;

  @override
  void initState() {
    super.initState();
    // Wypełniamy pola danymi istniejącego zadania
    titleController = TextEditingController(text: widget.task.title);
    deadlineController = TextEditingController(text: widget.task.deadline);
  }

  @override
  void dispose() {
    titleController.dispose();
    deadlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edytuj zadanie"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Tytuł zadania",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: deadlineController,
              decoration: const InputDecoration(
                labelText: "Deadline zadania",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Zwracamy zaktualizowane zadanie zachowując stan done
                final updatedTask = Task(
                  title: titleController.text,
                  deadline: deadlineController.text,
                  done: widget.task.done,
                );
                Navigator.pop(context, updatedTask);
              },
              child: const Text("Zapisz zmiany"),
            ),
          ],
        ),
      ),
    );
  }
}