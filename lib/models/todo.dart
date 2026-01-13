// lib/models/todo.dart
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'todo.g.dart'; // Ini akan dibuat secara otomatis oleh build_runner

@HiveType(typeId: 0) // typeId harus unik di seluruh model Hive Anda
class Todo extends HiveObject {
  @HiveField(0)
  String id; // Menggunakan String UUID untuk ID unik

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description; // Deskripsi bisa null

  @HiveField(3)
  DateTime? scheduledTime; // Simpan sebagai DateTime, bukan string "11:30 AM"

  @HiveField(4)
  DateTime? scheduledDate; // Simpan sebagai DateTime, bukan string "26/11/24"

  @HiveField(5)
  bool hasNotification;

  @HiveField(6)
  String? repeatRule; // e.g., "Daily", "Weekly", "Monthly", "Weekly:[1,2,4]"

  @HiveField(7)
  bool completed;

  @HiveField(8)
  DateTime creationTime;

  @HiveField(9)
  DateTime? lastUpdate; // Menambahkan ini untuk pengurutan/debug

  Todo({
    String? id,
    required this.title,
    this.description,
    this.scheduledTime,
    this.scheduledDate,
    this.hasNotification = false,
    this.repeatRule,
    this.completed = false,
    DateTime? creationTime,
    this.lastUpdate,
  })  : id = id ?? const Uuid().v4(),
        creationTime = creationTime ?? DateTime.now();

  // Method untuk mengubah status todo
  void toggleDone() {
    completed = !completed;
    lastUpdate = DateTime.now();
    save(); // Simpan perubahan ke Box Hive
  }

  // Method untuk update data
  Todo copyWith({
    String? title,
    String? description,
    DateTime? scheduledTime,
    DateTime? scheduledDate,
    bool? hasNotification,
    String? repeatRule,
    bool? completed,
    DateTime? lastUpdate,
  }) {
    return Todo(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      hasNotification: hasNotification ?? this.hasNotification,
      repeatRule: repeatRule ?? this.repeatRule,
      completed: completed ?? this.completed,
      creationTime: creationTime, // Biasanya tidak berubah
      lastUpdate: lastUpdate ?? DateTime.now(),
    );
  }
}