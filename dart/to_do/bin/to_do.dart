import 'package:to_do/to_do.dart' as todo;

void main() async {
  todo.Task task1 = todo.Task(1, 'Spülen', 'Spülen des Toiletten', false, false, DateTime.now());
  todo.Task task2 = todo.Task(2, 'Putzen', 'Putzen des Hauses', false, false, DateTime.now());
  todo.Task task3 = todo.Task(3, 'Kochen', 'Kochen der Suppe', false, false, DateTime.now());
  todo.tasks.add(task1);
  todo.tasks.add(task2);
  todo.tasks.add(task3);
  
  todo.loadTasks();
  todo.mainMenue();
  todo.saveTasks(); 
}
