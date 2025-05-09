import "package:intl/intl.dart";

import "../data/TaskDataHelper.dart";
import "dart:io";
import "../models/Task.dart";
import "../view/TaskDetail.dart";
import "package:flutter/material.dart";

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TaskItem({
    Key? key,
    required this.task,
    required this.onDelete,
    required this.onEdit,
    //required this.onFinish,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: _getColorByPriority(task.priority),
        child: ListTile(
          title: Text(task.title ?? 'Chưa xác định', style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task.description ?? 'Chưa xác định', maxLines: 2, overflow: TextOverflow.ellipsis),
              SizedBox(height: 4),
              Text(
                'Thời hạn: ${DateFormat('dd/MM/yyyy').format(task.duaDate ?? DateTime.now())}',
                style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              Text(
                'Tạo lúc: ${DateFormat('dd/MM/yyyy').format(task.createdAt)}',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                'Cập nhật: ${DateFormat('dd/MM/yyyy').format(task.updateAt)}',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 4),
              Text('Trạng thái: ${task.status ?? 'Chưa xác định'  }', style: TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold,)),
              SizedBox(height: 4),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: onEdit,
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Xác nhận xoá'),
                      content: Text('Bạn có chắc chắn muốn xoá công việc này?'),
                      actions: [
                        TextButton(
                          child: Text('Huỷ'),
                          onPressed: () => Navigator.pop(context),
                        ),
                        TextButton(
                          child: Text('Xoá'),
                          onPressed: () {
                            onDelete();
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              Checkbox(
                checkColor: Colors.green,
                value: task.completed, // Trạng thái checkbox dựa trên completed
                onChanged: (bool? newValue) async {
                  if (newValue != null) {
                    try {
                      // Tạo bản sao của task với completed được cập nhật
                      Task updatedTask = task.copyWith(
                        completed: newValue,
                        updateAt: DateTime.now(), // Cập nhật thời gian updateAt
                      );
                      // Cập nhật task trong cơ sở dữ liệu
                      await TaskDatabaseHelper.instance.updateTask(updatedTask);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Cập nhật trạng thái hoàn thành thành công'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Lỗi khi cập nhật trạng thái: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskDetail(task: task),
              ),
            );
          },
        ),
    );
  }

  // Hàm để lấy màu sắc theo mức độ ưu tiên
  Color _getColorByPriority(int priority) {
    switch (priority) {
      case 3:
        return Colors.red.shade100;
      case 2:
        return Colors.yellow.shade100;
      case 1:
        return Colors.green.shade100;
      default:
        return Colors.white;
    }
  }
}