import "dart:io";
import "../models/Task.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";

class TaskDetail extends StatelessWidget {
  final Task task;

  const TaskDetail({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        title: Text('Chi tiết công việc', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Tiêu đề', task.title),
                    Divider(),
                    _buildDetailRow('Mô tả', task.description),
                    Divider(),
                    _buildDetailRow('Trạng thái', task.status),
                    Divider(),
                    _buildDetailRow('Độ ưu tiên', task.priority.toString()),
                    Divider(),
                    _buildDetailRow('Hạn hoàn thành', DateFormat('dd/MM/yyyy').format(task.duaDate ?? DateTime.now())),
                    Divider(),
                    _buildDetailRow('Thời gian tạo', DateFormat('dd/MM/yyyy').format(task.createdAt)),
                    Divider(),
                    _buildDetailRow('Thời gian cập nhật', DateFormat('dd/MM/yyyy').format(task.updateAt)),
                    Divider(),
                    _buildDetailRow('ID người được giao', task.assignedTo.toString()),
                    Divider(),
                    _buildDetailRow('ID người tạo', task.createdBy),
                    Divider(),
                    _buildDetailRow('Phân loại' , task.category.toString()),
                    Divider(),

                    Text('Đính kèm', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.cyan.shade600,
                      fontSize: 14,
                    ),),
                    SizedBox(height: 4),

                    if (task.attachment != null && task.attachment!.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        children: task.attachment!.map((attachment) => Chip(label: Text(attachment),)).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.cyan.shade600,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}