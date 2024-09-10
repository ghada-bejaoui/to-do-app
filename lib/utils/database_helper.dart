import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'todo_database.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, isCompleted INTEGER, position INTEGER, color INTEGER)",
        );
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 2) {
          db.execute("ALTER TABLE tasks ADD COLUMN color INTEGER");
        }
      },
    );
  }

Future<void> insertTask(String name, bool isCompleted, int color) async {
  final db = await database;

  // Obtenez la position maximale existante
  final result = await db.rawQuery('SELECT MAX(position) AS max_position FROM tasks');
  int newPosition = result.first['max_position'] as int? ?? -1;
  newPosition += 1;

  await db.insert(
    'tasks',
    {'name': name, 'isCompleted': isCompleted ? 1 : 0, 'position': newPosition, 'color': color},
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}


  Future<List<Map<String, dynamic>>> getTasks() async {
    final db = await database;
    return await db.query('tasks', orderBy: 'position ASC'); // Assurez-vous de trier par position
  }

  Future<void> updateTask(int id, bool isCompleted) async {
    final db = await database;
    await db.update(
      'tasks',
      {'isCompleted': isCompleted ? 1 : 0},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete(
      'tasks',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<void> updateTaskPosition(int id, int position) async {
    final db = await database;
    await db.update(
      'tasks',
      {'position': position},
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
