import '../data/TaskDataHelper.dart';
import '../models/Task.dart';
import '../view/TaskForm.dart';
import 'package:flutter/material.dart';

class EditTaskScreen extends StatelessWidget {
  final Task task;

  const EditTaskScreen({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TaskForm(
      task: task,
      onSave: (Task updateTask) async {
        try {

          // Tạo Task mới với ID giữ nguyên
          Task taskToUpdate = Task(
            id: task.id, // Giữ nguyên ID
            title: updateTask.title,
            description: updateTask.description,
            status: updateTask.status,
            priority: updateTask.priority,
            duaDate: updateTask.duaDate,
            createdAt: updateTask.createdAt,
            updateAt: DateTime.now(),
            assignedTo: updateTask.assignedTo,
            createdBy: updateTask.createdBy,
            category: updateTask.category,
            attachment: updateTask.attachment,
            completed: updateTask.completed,
          );

          await TaskDatabaseHelper.instance.updateTask(taskToUpdate);
          Navigator.pop(context, true); // Return true to indicate the user was updated

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cập nhật công việc thành công'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi cập nhật công việc: $e'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pop(context, false);
        }
      },
    );
  }
}