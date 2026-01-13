import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // ⬅️ TAMBAHKAN INI
import 'package:hive_flutter/hive_flutter.dart';
import 'package:doable_todo_list_app/models/todo.dart';


class TodoProvider extends ChangeNotifier {
  late Box<Todo> _todoBox; // Deklarasikan Box Hive

  // Getter untuk mendapatkan daftar todo yang sudah diurutkan
  // Incomplete items di atas, kemudian diurutkan berdasarkan lastUpdate terbaru
  List<Todo> get todos {
    return _todoBox.values.toList()
      ..sort((a, b) {
        if (a.completed != b.completed) {
          return a.completed ? 1 : -1; // Incomplete (false) datang lebih dulu
        }
        // Jika status completion sama, urutkan berdasarkan lastUpdate terbaru
        return (b.lastUpdate ?? b.creationTime).compareTo(a.lastUpdate ?? a.creationTime);
      });
  }

  TodoProvider() {
    _todoBox = Hive.box<Todo>('todos'); // Dapatkan instance Box yang sudah dibuka
  }

  // Menambahkan todo baru
  Future<void> addTodo(Todo todo) async {
    await _todoBox.put(todo.id, todo); // Gunakan put dengan id sebagai key
    notifyListeners(); // Beri tahu UI untuk refresh
  }

  // Mengubah status selesai/belum selesai dari todo
  Future<void> toggleTodoStatus(Todo todo) async {
    todo.toggleDone(); // Menggunakan method toggleDone di model Todo (sudah memanggil save())
    notifyListeners(); // Beri tahu UI untuk refresh
  }

  // Menghapus todo
  Future<void> deleteTodo(String id) async {
    await _todoBox.delete(id); // Menghapus dari Box Hive berdasarkan key-nya
    notifyListeners(); // Beri tahu UI untuk refresh
  }

  // Mengupdate todo
  Future<void> updateTodo(Todo updatedTodo) async {
    await _todoBox.put(updatedTodo.id, updatedTodo); // Mengganti item yang ada dengan key yang sama
    notifyListeners(); // Beri tahu UI untuk refresh
  }

  // Menghapus semua todo
  Future<void> clearAllTodos() async {
    await _todoBox.clear();
    notifyListeners();
  }

  // Mendapatkan ValueListenable untuk membangun UI secara reaktif
  ValueListenable<Box<Todo>> get listenableTodoBox => _todoBox.listenable();

  // Mendapatkan Todo berdasarkan ID
  Todo? getTodoById(String id) {
    return _todoBox.get(id);
  }
}