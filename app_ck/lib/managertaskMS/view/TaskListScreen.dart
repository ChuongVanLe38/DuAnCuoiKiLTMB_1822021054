import "package:app_ck/managertaskMS/view/AddTaskScreen.dart";
import "package:app_ck/managertaskMS/view/EditTaskScreen.dart";
import "../data/TaskDataHelper.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart" as firebase_auth;
import "../models/Task.dart";
import "../view/TaskItem.dart";
import "package:flutter/material.dart";
import "../models/user.dart";
import 'package:app_ck/login.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late Future<List<Task>> _tasksFuture;
  bool _isKabanView = false;
  String _searchQuery = '';
  String _filterPriority = 'All';
  User? _currentUser; // Lưu thông tin user hiện tại
  bool _isLoading = true; // Trạng thái tải user

  @override
  void initState() {
    super.initState();
    _loadCurrentUser(); // Tải thông tin user khi khởi tạo
    _refreshTask();
  }

  // Tải thông tin user hiện tại từ Firestore
  Future<void> _loadCurrentUser() async {
    try {
      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        print("Firebase User UID: ${firebaseUser.uid}"); // In UID từ Firebase Auth
        final doc = await FirebaseFirestore.instance
            .collection("Users")
            .doc(firebaseUser.uid)
            .get();
        if (doc.exists) {
          setState(() {
            _currentUser = User.fromMap(doc.data()!);
            _isLoading = false;
          });
          print("User loaded: ${_currentUser!.toString()}"); // Log thông tin user
        } else {
          print("Không tìm thấy user trong Firestore");
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        print("Không có user đăng nhập");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Lỗi khi tải user: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshTask() async {
    setState(() {
      _tasksFuture = TaskDatabaseHelper.instance.getAllTask();
    });
  }

  Future<List<Task>> _getFilteredTasks() async {
    List<Task> tasks = await _tasksFuture;

     //Lọc task dựa trên isAdmin
    if (_currentUser != null && !_currentUser!.isAdmin) {
      tasks = tasks.where((task) =>
      task.assignedTo == _currentUser!.id || task.createdBy == _currentUser!.id).toList();
    }

    if (_filterPriority != 'All') {
      int priority = int.parse(_filterPriority);
      tasks = tasks.where((task) => task.priority == priority).toList();
    }

    if (_searchQuery.isNotEmpty) {
      tasks = await TaskDatabaseHelper.instance.searchTasks(_searchQuery);
    }

    return tasks;;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentUser == null) {
      return Scaffold(
        body: Center(child: Text("Không thể tải thông tin user")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        title: Text('Task Manager', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.orange,),
            onPressed: _refreshTask,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _filterPriority = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'All', child: Text('Tất cả')),
              PopupMenuItem(value: '3', child: Text('Ưu tiên cao')),
              PopupMenuItem(value: '2', child: Text('Ưu tiên trung bình')),
              PopupMenuItem(value: '1', child: Text('Ưu tiên thấp')),
            ],
          ),
          IconButton(
            icon: Icon(_isKabanView ? Icons.list  : Icons.view_kanban, color: Colors.orange,),
            onPressed: () {
              setState(() {
                _isKabanView = !_isKabanView;
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Task>>(
        future: _getFilteredTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Không có công việc nào'));
          } else {
            final tasks = snapshot.data!;
            final todoTasks = tasks.where((task) => task.status == 'To do').toList();
            final inProgressTasks = tasks.where((task) => task.status == 'In progress').toList();
            final doneTasks = tasks.where((task) => task.status == 'Done').toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.search, color: Colors.blueAccent,),
                      labelText: 'Tìm kiếm ghi chú',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: _isKabanView
                      ? Row(
                    children: [
                      Expanded(child: _buildColumn('To do', todoTasks)),
                      Expanded(child: _buildColumn('In progress', inProgressTasks)),
                      Expanded(child: _buildColumn('Done', doneTasks)),
                    ],
                  )
                      : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return TaskItem(
                        task: task,
                        onDelete: () async {
                          await TaskDatabaseHelper.instance.deleteTask(task.id!);
                          _refreshTask();
                        },
                        onEdit: () async {
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditTaskScreen(task: task),
                            ),
                          );
                          if (updated == true) {
                            _refreshTask();
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "add_task",
            child: Icon(Icons.add, color: Colors.white),
            backgroundColor: Colors.blue,
            onPressed: () async {
              final created = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTaskScreen(),
                ),
              );
              if (created == true) {
                _refreshTask();
              }
            },
          ),

          SizedBox(height: 16),

          FloatingActionButton(
            heroTag: "out_tasks",
            child: Icon(Icons.outbond, color: Colors.white),
            backgroundColor: Colors.red,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Xác nhận thoát'),
                  content: Text('Bạn có chắc chắn muốn thoát khỏi trang công việc?'),
                  actions: [
                    TextButton(
                      child: Text('Huỷ'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    TextButton(
                      child: Text('Thoát'),
                      onPressed: () async {
                        final created = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LogIn(),
                          ),
                        );
                        if (created == true) {
                          _refreshTask();
                        }
                      },
                    ),
                  ],
                ),
              );
            }, // Gọi hàm xóa tất cả công việc
          ),
        ],
      ),
    );
  }


  Widget _buildColumn(String title, List<Task> tasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskItem(
                task: task,
                onDelete: () async {
                  await TaskDatabaseHelper.instance.deleteTask(task.id!);
                  _refreshTask();
                },
                onEdit: () async {
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditTaskScreen(task: task),
                    ),
                  );
                  if (updated == true) {
                    _refreshTask();
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}