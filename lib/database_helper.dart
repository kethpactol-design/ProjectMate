import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB('projectmate.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 6,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          passwordHash TEXT NOT NULL,
          passwordSalt TEXT NOT NULL,
          phoneNumber TEXT
          )
      ''');


        await db.execute('''  
          CREATE TABLE tasks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT,
          dueDate TEXT,
          priority TEXT NOT NULL,
          completed INTEGER NOT NULL DEFAULT 0
        )
      ''');
        await db.execute('''
  CREATE TABLE projects (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    dueDate TEXT,
    status TEXT NOT NULL DEFAULT 'Ongoing',
    priority TEXT NOT NULL DEFAULT 'Medium',
    progress INTEGER NOT NULL DEFAULT 0
   )
''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
      CREATE TABLE IF NOT EXISTS tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        dueDate TEXT,
        priority TEXT NOT NULL,
        completed INTEGER NOT NULL DEFAULT 0
      )
    ''');
        }
        if (oldVersion < 3) {
          await db.execute('''
    CREATE TABLE IF NOT EXISTS projects (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT,
      dueDate TEXT,
      status TEXT NOT NULL DEFAULT 'Ongoing'
    )
  ''');
        }
        if (oldVersion < 4) {
          await db.execute('''
    ALTER TABLE projects
    ADD COLUMN progress INTEGER NOT NULL DEFAULT 0
  ''');
        }
        if (oldVersion < 5) {
          await db.execute(
            'ALTER TABLE users ADD COLUMN phoneNumber TEXT',
          );
        }
        if (oldVersion < 6) {
          await db.execute(
            "ALTER TABLE projects ADD COLUMN priority TEXT NOT NULL DEFAULT 'Medium'",
          );
        }
      },
    );
  }

  // Create a random salt for each account.
  String _createSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(
      16,
          (index) => random.nextInt(256),
    );
    return base64Encode(bytes);
  }

  // Derive a password hash using PBKDF2-HMAC-SHA256.
  Uint8List _hashPassword(String password, String salt) {
    const iterations = 210000;
    const keyLength = 32;

    final saltBytes = base64Decode(salt);
    final passwordBytes = utf8.encode(password);

    var u = Uint8List.fromList(
      Hmac(sha256, passwordBytes).convert(
        saltBytes + _int32(1),
      ).bytes,
    );

    final result = Uint8List.fromList(u);

    for (int i = 1; i < iterations; i++) {
      u = Uint8List.fromList(
        Hmac(sha256, passwordBytes).convert(u).bytes,
      );

      for (int j = 0; j < keyLength; j++) {
        result[j] ^= u[j];
      }
    }

    return result;
  }

  List<int> _int32(int value) {
    return [
    (value >> 24) & 255,
    (value >> 16) & 255,
    (value >> 8) & 255,
    value & 255,
    ];
  }

  Future<bool> registerUser(
      String name,
      String email,
      String password,
      ) async {
    final db = await database;

    final normalizedEmail = email.trim().toLowerCase();
    final salt = _createSalt();
    final hash = base64Encode(_hashPassword(password, salt));

    try {
      await db.insert('users', {
        'name': name.trim(),
        'email': normalizedEmail,
        'passwordHash': hash,
        'passwordSalt': salt,
      });

      return true;
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        return false;
      }
      rethrow;
    }
  }

  Future<bool> loginUser(
      String email,
      String password,
      ) async {
    final db = await database;

    final users = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );

    if (users.isEmpty) {
      return false;
    }

    final user = users.first;
    final salt = user['passwordSalt'] as String;
    final savedHash = user['passwordHash'] as String;
    final enteredHash = base64Encode(_hashPassword(password, salt));

    return savedHash == enteredHash;
  }

  Future<bool> changeUserPassword(
      String email,
      String currentPassword,
      String newPassword,
      ) async {
    final db = await database;

    final users = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );

    if (users.isEmpty) {
      return false;
    }

    final user = users.first;
    final oldSalt = user['passwordSalt'] as String;
    final savedHash = user['passwordHash'] as String;

    final enteredHash = base64Encode(
      _hashPassword(currentPassword, oldSalt),
    );

    if (enteredHash != savedHash) {
      return false;
    }

    final newSalt = DateTime.now().microsecondsSinceEpoch.toString();

    final newHash = base64Encode(
      _hashPassword(newPassword, newSalt),
    );

    await db.update(
      'users',
      {
        'passwordSalt': newSalt,
        'passwordHash': newHash,
      },
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
    );

    return true;
  }

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
    _database = null;
  }
  Future<int> saveTask(Map<String, dynamic> task) async {
    final db = await database;

    if (task['id'] != null) {
      return await db.update(
        'tasks',
        {
          'title': task['title'],
          'description': task['description'],
          'dueDate': task['dueDate']?.toString(),
          'priority': task['priority'],
          'completed': task['completed'] == true ||
              task['completed'] == 1
              ? 1
              : 0,
        },
        where: 'id = ?',
        whereArgs: [task['id']],
      );
    } else {
      return await db.insert('tasks', {
        'title': task['title'],
        'description': task['description'],
        'dueDate': task['dueDate']?.toString(),
        'priority': task['priority'],
        'completed': task['completed'] == true ||
            task['completed'] == 1
            ? 1
            : 0,
      });
    }
  }
  Future<int> deleteTask(int id) async {
    final db = await database;

    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<List<Map<String, dynamic>>> getTasks() async {
    final db = await database;
    return await db.query('tasks', orderBy: 'id DESC');
  }
  Future<Map<String, dynamic>?> getUserProfile(String email) async {
    final db = await database;

    final users = await db.query(
      'users',
      columns: ['name', 'email'],
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );

    if (users.isEmpty) {
      return null;
    }

    return users.first;
  }
  Future<String?> getPhoneNumber(String email) async {
    final db = await database;

    final users = await db.query(
      'users',
      columns: ['phoneNumber'],
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );

    if (users.isEmpty) {
      return null;
    }

    return users.first['phoneNumber'] as String?;
  }

  Future<int> updatePhoneNumber(
      String email,
      String phoneNumber,
      ) async {
    final db = await database;

    return await db.update(
      'users',
      {'phoneNumber': phoneNumber.trim()},
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
    );
  }
}