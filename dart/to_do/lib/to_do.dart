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
      'dueDate': dueDate.toIso8601String(),
    };
  }

  static Task fromJson(Map<String, dynamic> json) {
    return Task(json['id'], json['title'] ?? 'Unbekannt', json['description'] ?? 'Beschreibung',
        json['priority'] ?? false, json['completed'] ?? false, DateTime.parse(json['dueDate'] ?? '0000-00-00'));
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, description: $description, priority: $priority, completed: $completed, dueDate: $dueDate)';
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
    print('6. Alle Aufgaben löschen');
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
      case '6':
        deleteAlltasks();
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
    String? description;
    DateTime? dueDate;
    do {
      if (input == null || input.isEmpty) {
        print('Ungültige Eingabe!');
        print('--------------------------');
        return;
      } else {
        try {
          stdout.write('Beschreibung eingeben: ');
          description = stdin.readLineSync();
          if (description == null || description.isEmpty) {
          description = 'Beschreibung';
          } else { 
          print('$description hinzugefügt');
          } 
        } catch (ex) {
          print('Fehler beim Eingeben der Beschreibung: $ex');
        }
        DateTime? dueDate;
        while (true) {
          stdout.write('Datum der Aufgabe (YYYY-MM-DD): ');
          String? dateInput = stdin.readLineSync();
          if (dateInput == 'quit') {
            break;
          } else if (dateInput == null || dateInput.isEmpty) {
            dueDate = DateTime.parse('0000-00-00');
            break;
          } else if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateInput)) {
            try {
              dueDate = DateTime.parse(dateInput);
              break;
            } catch (e) {
              print('Ungültiges Datumsformat. Bitte versuchen Sie es erneut.');
            }
          } else {
            print('Ungültiges Datumsformat. Bitte verwenden Sie YYYY-MM-DD.');
          }
        }
        tasks.add(Task(tasks.length + 1, input, description!, false, false, dueDate!));
        print('Aufgabe $input hinzugefügt!');
        print('--------------------------');
      }
    } while (input.isEmpty);
  } catch (ex) {
    print('Fehler beim Eingeben der Aufgabe: $ex');
    }
}


void deleteAlltasks() {
  tasks.clear();
  print('Alle Aufgaben gelöscht!');
  print('--------------------------');
}

void deleteTask() {
  String? input;
  showTasks();
  print('--------------------------');
  
  stdout.write('Zu löschende Aufgaben ID eingeben: ');
  do {
    input = stdin.readLineSync();
    try {
      int index = int.parse(input!);
      tasks.removeWhere((task) => task.id == index);
      print('Aufgabe mit ID $index gelöscht!');
      print('--------------------------');
    } catch (ex) {
      print('Fehler beim Löschen der Aufgabe: $ex');
    }
  } while (input == null || input.isEmpty);
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
  String? input;

  showTasks();
  print('--------------------------');

  do {
    stdout.write('Zu erledigende Aufgabe eingeben: ');
    input = stdin.readLineSync();
    if (input == null || input.isEmpty) {
      print('Ungültige Eingabe!');
      print('--------------------------');
    } else {
      try {
        int taskId = int.parse(input); // Umwandlung in int
        tasks.firstWhere((task) => task.id == taskId).completed = true;
        print(tasks.firstWhere((task) => task.id == taskId).completed);
        print('Aufgabe $taskId als erledigt markiert!');
        print('--------------------------');
      } catch (ex) {
        print('Aufgabe mit ID $input nicht gefunden. \n\n Fehler: $ex');
      }
    }
  } while (input == null || input.isEmpty);
}

void saveTasks() {
  try {
    final File fileTasks = File('files/tasks.json');
    fileTasks.writeAsStringSync(jsonEncode(tasks.map((task) => task.toJson()).toList()));
  } catch (ex) {
    print('Fehler beim Speichern der Aufgaben: $ex');
  }
}

void loadTasks() async {
  print('Lade Aufgaben...');
  Duration duration = Duration(seconds: 2);
  await Future.delayed(duration);
  final File fileTasks = File('files/tasks.json');
  
  print('Dateipfad: ${fileTasks.path}');
  print('Datei existiert: ${fileTasks.existsSync()}');
  
  if (fileTasks.existsSync()) {
    try {
      String fileContent = fileTasks.readAsStringSync();
      print('Dateiinhalt: $fileContent');
      
      final List<dynamic> jsonData = jsonDecode(fileContent);
      print('JSON-Daten: $jsonData');
      
      tasks = jsonData.map((item) => Task.fromJson(item)).toList();
      print('Geladene Aufgaben: $tasks');
      
      print('Aufgaben geladen!');
      print('--------------------------');
    } catch (ex) {
      print('Fehler beim Laden der Aufgaben: $ex');
      print('Stacktrace: ${StackTrace.current}');
    }
  } else {
    print('Die Datei tasks.json existiert nicht.');
    print('Aktuelles Verzeichnis: ${Directory.current.path}');
  }
}
