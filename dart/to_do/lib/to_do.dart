import 'dart:async';
import 'dart:io';
import 'dart:convert';

class Task {
  int id;
  String title;
  String description;
  bool priority;
  bool completed;

  DateTime dueDate;

  Task(this.id, this.title, this.description, this.priority, this.completed,
      this.dueDate);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
      'dueDate': dueDate,
    };
  }

  static Task fromJson(Map<String, dynamic> json) {
    return Task(json['id'], json['title'], json['description'],
        json['priority'], json['completed'], json['dueDate']);
  }
}

List<Task> tasks = [];

void mainMenue() async {
  bool running = true;

  while (running) {
    print('---Aufgabenverwaltung---');
    print('--------------------------');
    print('1. Aufgaben hinzufügen');
    print('2. Aufgaben entfernen');
    print('3. Aufgaben anzeigen');
    print('4. Aufgaben als erledigt markieren');
    print('5. Programm beenden');
    print('--------------------------');
    stdout.write('Auswahl: ');
    String? input = stdin.readLineSync();

    switch (input) {
      case '1':
        addTask();
        break;
      case '2':
        deleteTask();
        break;
      case '3':
        showTasks();
        break;
      case '4':
        checkTask();
        break;
      case '5':
        saveTasks();
        running = false;
        print('Programm beendet!');
        break;
      default:
        print('Ungültige Auswahl!');
    }
  }
}

void addTask() {
try {
    stdout.write('Aufgabe eingeben: ');
    String? input = stdin.readLineSync();
    do {
      if (input == null || input.isEmpty) {
        print('Ungültige Eingabe!');
        print('--------------------------');
        return;
      } else {
        stdout.write('Beschreibung eingeben: ');
        String? description = stdin.readLineSync();
        if (description == null || description.isEmpty) {
          description = 'Beschreibung';
        } else {
          print('$description hinzugefügt');
        }
        DateTime? dueDate;
        while (true) {
          stdout.write('Datum der Aufgabe (YYYY-MM-DD): ');
          String? dateInput = stdin.readLineSync();
          if (dateInput == 'quit') {
            break;
          }
          try {
            dueDate = DateTime.parse(dateInput!);
            break;
          } catch (ex) {
            print(
                '$ex \n\nFalsche Datumseingabe. Bitte erneut versuchen oder "quit" eingeben zum Verlassen');
          }
        }
        tasks.add(
            Task(tasks.length + 1, input, description, false, false, dueDate!));
        print('Aufgabe $input hinzugefügt!');
        print('--------------------------');
      }
    } while (input.isEmpty);
  } catch (ex) {
    print('Fehler beim Eingeben der Aufgabe: $ex');
  }
}


void deleteTask() {
  stdout.write('Zu löschende Aufgabe eingeben: ');
  String? input = stdin.readLineSync();
  if (input == null || input.isEmpty) {
    print('Ungültige Eingabe!');
    print('--------------------------');
    return;
  }
  int index = tasks.indexWhere((task) => task.title == input);
  if (index != -1) {
    tasks.removeAt(index);
    print('Aufgabe $input gelöscht!');
    print('--------------------------');
  } else {
    print('Aufgabe nicht gefunden!');
    print('--------------------------');
  }
}

void showTasks() {
  if (tasks.isEmpty) {
    print('Keine Aufgaben vorhanden.');
    print('--------------------------');
  } else {
    for (var task in tasks) {
      print(
          '${task.id}. ${task.completed ? "[X]" : "[ ]"} ${task.title} ${task.description} ${task.priority ? "[high]" : "[low]"} ${task.dueDate}');
    }
  }
  print('--------------------------');
}

void checkTask() {
  stdout.write('Aufgabe eingeben: ');
  String? input = stdin.readLineSync();
  if (input == null || input.isEmpty) {
    print('Ungültige Eingabe!');
    print('--------------------------');
    return;
  }
  bool found = false;
  for (var task in tasks) {
    if (task.title == input) {
      task.completed = true;
      print('Aufgabe $input als erledigt markiert!');
      found = true;
      break;
    }
  }
  if (!found) {
    print('Aufgabe nicht gefunden!');
  }
  print('--------------------------');
}

void saveTasks() {
  try {
    final File file_tasks = File('files/tasks.json');
    file_tasks.writeAsStringSync(
        jsonEncode(tasks.map((task) => task.toJson()).toList()));
  } catch (ex) {
    print('Fehler beim Speichern der Aufgaben: $ex');
  }
}

void loadTasks() async {
  print('Lade Aufgaben...');
  Duration duration = Duration(seconds: 2);
  await Future.delayed(duration);
  final File file_tasks = File('files/tasks.json');
  if (file_tasks.existsSync()) {
    tasks = (jsonDecode(file_tasks.readAsStringSync()) as List)
        .map((item) => Task.fromJson(item))
        .toList();
  }
}
