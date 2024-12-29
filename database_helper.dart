import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    print('Initializing database...');
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    print('Database path: $path');

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }



  Future<void> _createDB(Database db, int version) async {
    print('Creating database tables...');
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        date INTEGER NOT NULL,
        title TEXT NOT NULL,
        time TEXT NOT NULL,
        category TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL
      )
    ''');
    print('Database tables created');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from $oldVersion to $newVersion');

    // handling users table upgrade (existing logic)
    if (oldVersion < 2) {
      var tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='users'");
      if (tables.isEmpty) {
        await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL
      );
    ''');
        print('Users table created during upgrade');
      } else {
        print('Users table already exists, skipping creation');
      }
    }


    if (oldVersion < 4) {
      // this checks if userId column exists in tasks table
      var columns = await db.rawQuery('PRAGMA table_info(tasks)');
      bool hasUserIdColumn = columns.any((column) => column['name'] == 'userId');

      if (!hasUserIdColumn) {
        // this adds userId column to existing tasks table
        await db.execute('ALTER TABLE tasks ADD COLUMN userId TEXT NOT NULL DEFAULT ""');
        print('Added userId column to tasks table');
      }
    }
  }

  // Updated user registration method with first and last name
  Future<bool> registerUser(String username, String password, String firstName, String lastName) async {
    print('Starting user registration...');
    final db = await database;
    try {
      await db.insert('users', {
        'username': username,
        'password': password,
        'firstName': firstName,
        'lastName': lastName
      });
      print('User registration successful');
      return true;
    } catch (e) {
      print('Error registering user: $e');
      return false;
    }
  }

  //to get user details
  Future<Map<String, dynamic>?> getUserDetails(String username) async {
    final db = await database;
    try {
      final result = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('Error getting user details: $e');
      return null;
    }
  }


  Future<Map<String, dynamic>?> verifyUser(String username, String password) async {
    final db = await database;
    try {
      final result = await db.query(
        'users',
        where: 'username = ? AND password = ?',
        whereArgs: [username, password],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('Error verifying user: $e');
      return null;
    }
  }



  Future<int> insertTask(Map<String, dynamic> task, String userId) async {
    final db = await database;
    final dateTime = DateTime.parse(task['date']);

    print('Inserting task for user: $userId'); // Debug print
    print('Task data: $task'); // Debug print

    final taskData = {
      'userId': userId,
      'date': dateTime.millisecondsSinceEpoch,
      'title': task['title'],
      'time': task['time'],
      'category': task['category'] ?? 'other'
    };

    print('Formatted task data to insert: $taskData'); // Debug print
    final result = await db.insert('tasks', taskData);
    print('Insert result ID: $result'); // Debug print
    return result;
  }

  // retrieve all the tasks
  Future<Map<String, List<Map<String, dynamic>>>> getAllTasks(String userId) async {
    final db = await database;
    print('Fetching tasks for user: $userId');
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    print('Found ${maps.length} tasks in database');
    print('Raw tasks from DB: $maps');
    Map<String, List<Map<String, dynamic>>> tasksByDate = {};

    for (var task in maps) {
      final date = DateTime.fromMillisecondsSinceEpoch(task['date'] as int);
      final dateString = date.toIso8601String().split('T')[0];

      if (!tasksByDate.containsKey(dateString)) {
        tasksByDate[dateString] = [];
      }

      tasksByDate[dateString]!.add({
        'title': task['title'],
        'time': task['time'],
        'category': task['category'],
        'date': dateString,
        'userId': task['userId'],
      });
    }
    print('Processed tasks by date: $tasksByDate');
    return tasksByDate;
  }


  Future<int> deleteTask(String date, String title, String time, String userId) async {
    final db = await database;
    final dateTime = DateTime.parse(date);

    return await db.delete(
      'tasks',
      where: 'date = ? AND title = ? AND time = ? AND userId = ?',
      whereArgs: [dateTime.millisecondsSinceEpoch, title, time, userId],
    );
  }

  // closes the database
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
