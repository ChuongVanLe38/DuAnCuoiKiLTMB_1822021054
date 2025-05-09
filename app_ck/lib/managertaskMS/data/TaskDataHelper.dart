import '../models/Task.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class TaskDatabaseHelper {
  static final TaskDatabaseHelper instance = TaskDatabaseHelper._init();
  static Database? _database;

  TaskDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('apptaskmanager_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 7, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('DROP TABLE IF EXISTS tasks');
    await db.execute('''
        CREATE TABLE tasks (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          status TEXT NOT NULL,
          priority INTEGER NOT NULL,
          duaDate TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          updateAt TEXT NOT NULL,
          assignedTo TEXT,
          createdBy TEXT NOT NULL,
          category TEXT,
          attachment TEXT,
          completed BOOLEAN NOT NULL
        )
      ''');

    // Tạo sẵn dữ liệu mẫu
    await _insertSampleData(db);
  }
  // Phương thức chèn dữ liệu mẫu
  Future _insertSampleData(Database db) async {
    // Danh sách dữ liệu mẫu
    final List<Map<String, dynamic>> sampleTasks = [
      {
        'id': 'T002',
        'title': 'Nhiệm vụ 2',
        'description': 'Mô tả nhiệm vụ 2',
        'status': 'To do',
        'priority': 1,
        'duaDate': DateTime(2025, 5, 10).toIso8601String(),
        'createdAt': DateTime(2025, 5, 1).toIso8601String(),
        'updateAt': DateTime(2025, 5, 1).toIso8601String(),
        'assignedTo': 'NV005',
        'createdBy': 'NV001',
        'category': 'Công việc',
        'attachment': ['Ghi chú, Giới thiệu'].join(','),
        'completed': 1,
      },
      {
        'id': 'T003',
        'title': 'Nhiệm vụ 3',
        'description': 'Mô tả nhiệm vụ 3',
        'status': 'In progress',
        'priority': 2,
        'duaDate': DateTime(2025, 5, 12).toIso8601String(),
        'createdAt': DateTime(2025, 5, 2).toIso8601String(),
        'updateAt': DateTime(2025, 5, 3).toIso8601String(),
        'assignedTo': 'NV006',
        'createdBy': 'NV001',
        'category': 'Công việc',
        'attachment': ['Ghi chú, Giới thiệu'].join(','),
        'completed': 0,
      }
    ];

    // Chèn từng người dùng vào cơ sở dữ liệu
    for (final taskData in sampleTasks) {
      await db.insert('Tasks', taskData);
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }


  /*
  instance: Singleton pattern đảm bảo chỉ có một instance của DatabaseHelper
  database: Getter trả về instance của Database, tạo mới nếu chưa tồn tại
  _initDB: Khởi tạo database với đường dẫn cụ thể
  _createDB: Tạo các bảng khi database được tạo lần đầu
  close: Đóng kết nối database
   */

  Future<String> _generateTaskId() async {
    final db = await instance.database;
    final result = await db.query('tasks', orderBy: 'id DESC', limit: 1);

    int nextIdNumber = 1; // Mặc định bắt đầu từ 1 nếu không có dữ liệu
    if (result.isNotEmpty) {
      final lastId = result.first['id'] as String;
      final lastIdNumber = int.parse(lastId.replaceFirst('T', '')); // Lấy số từ ID (ví dụ: T001 -> 1)
      nextIdNumber = lastIdNumber + 1;
    }

    // Định dạng ID mới: T + số thứ tự (3 chữ số)
    return 'T${nextIdNumber.toString().padLeft(3, '0')}'; // Ví dụ: T001, T002, ...
  }

  // Create - Thêm task mới
  Future<int> createTask(Task task) async {
    final db = await instance.database;

    // Sinh ID tự động nếu task không có ID
    String taskId;
    if (task.id == null || task.id!.isEmpty) {
    taskId = await _generateTaskId(); // Tách logic await ra riêng
    } else {
    taskId = task.id!;
    }

    Task newTask = Task(
      id: taskId,
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
      duaDate: task.duaDate,
      createdAt: task.createdAt,
      updateAt: task.updateAt,
      assignedTo: task.assignedTo,
      createdBy: task.createdBy,
      category: task.category,
      attachment: task.attachment,
      completed: task.completed,
    );

    return await db.insert('tasks', newTask.toMap());
  }

  // Read - Đọc tất cả tasks
  Future<List<Task>> getAllTask() async {
    final db = await instance.database;
    final result = await db.query('tasks');

    return result.map((map) {
      print(map); // In ra để kiểm tra giá trị
      return Task.fromMap(map);
    }).toList();
  }

  // Read - Đọc task theo id
  Future<Task?> getTaskById(String id) async {
    final db = await instance.database;
    final maps = await db.query('tasks', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Task.fromMap(maps.first);
    }
    return null;
  }

  // Update - Cập nhật Task
  Future<int> updateTask(Task task) async {
    final db = await instance.database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // Delete - Xoá task
  Future<int> deleteTask(String id) async {
    final db = await instance.database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // Delete - Xoá tất cả task
  Future<int> deleteAllTasks() async {
    final db = await instance.database;
    return await db.delete('tasks');
  }

  // Read - Lấy task theo mức độ ưu tiên
  Future<List<Task>> getTasksByPriority(int priority) async {
    final db = await instance.database;
    final result = await db.query(
      'tasks',
      where: 'priority = ?',
      whereArgs: [priority],
    );

    return result.map((map) => Task.fromMap(map)).toList();
  }

  // Search - Tìm kiếm Task theo từ khóa
  Future<List<Task>> searchTasks(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'Tasks',
      where: 'title LIKE ? ',
      whereArgs: ['%$query%'],
    );

    return result.map((map) => Task.fromMap(map)).toList();
  }



}