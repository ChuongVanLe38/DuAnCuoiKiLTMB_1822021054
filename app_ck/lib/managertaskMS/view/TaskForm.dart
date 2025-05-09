import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/Task.dart';


class TaskForm extends StatefulWidget {
  final Task? task;
  final Function(Task task) onSave;

  const TaskForm({
    Key? key,
    this.task,
    required this.onSave,
  }) : super(key: key);

  @override
  _TaskFormState createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _duaDateController = TextEditingController();
  int _selectedPriority = 1;
  DateTime _duaDate = DateTime.now();
  DateTime _createdAt = DateTime.now();
  DateTime _updateAt = DateTime.now();
  final _asignedToController = TextEditingController();
  final _createdByController = TextEditingController();
  final _categoryByController = TextEditingController();
  List<String> _attachment = [];
  bool _completed = false;
  bool _isLoading = false;

  // Danh sách trạng thái cố định
  final List<String> _statusOptions = ['To do', 'In progress', 'Done', 'Cancelled'];
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    // If editing, populate form with task data
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _selectedStatus = widget.task!.status;
      _selectedPriority = widget.task!.priority;
      _duaDate = widget.task!.duaDate!;
      _duaDateController.text = DateFormat('dd/MM/yyyy').format(widget.task!.duaDate!);
      _createdAt = widget.task!.createdAt;
      _updateAt = DateTime.now();
      _asignedToController.text = widget.task!.assignedTo!;
      _createdByController.text = widget.task!.createdBy;
      _categoryByController.text = widget.task!.category!;
      _attachment = widget.task!.attachment ?? [];
      _completed = widget.task!.completed;
    }else{
      _selectedStatus = 'To do';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _duaDateController.dispose();
    _asignedToController.dispose();
    _createdByController.dispose();
    _categoryByController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final task = Task(
        title: _titleController.text,
        description: _descriptionController.text,
        status: _selectedStatus!,
        priority: _selectedPriority,
        duaDate: _duaDate,
        createdAt: _createdAt,
        updateAt: DateTime.now(),
        assignedTo: _asignedToController.text,
        createdBy: _createdByController.text,
        category: _categoryByController.text,
        attachment: _attachment,
        completed: _completed,
      );

      widget.onSave(task);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _duaDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _duaDate) {
      setState(() {
        _duaDate = picked;
        _duaDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _addattAchment(String attachment) {
    setState(() {
      _attachment.add(attachment);
    });
  }

  void _removeAttachment(String attachment) {
    setState(() {
      _attachment.remove(attachment);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        title: Text(isEditing ? 'Cập nhật công việc' : 'Thêm công việc mới',style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// Tiêu đề
              TextFormField(

                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Tiêu đề',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tiêu đề';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              /// Mô tả
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Miêu tả',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mô tả';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              /// Trạng thái
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Trạng thái',
                  border: OutlineInputBorder(),
                ),
                items: _statusOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedStatus = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Vui lòng chọn trạng thái';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              /// Ngày đến hạn (duaDate)
              TextFormField(
                controller: _duaDateController,
                decoration: InputDecoration(
                  labelText: 'Ngày đến hạn',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true, // Ngăn người dùng nhập trực tiếp
                validator: (value) {
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Mức độ ưu tiên
              Text('Mức độ ưu tiên:'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Radio(
                        value: 1,
                        groupValue: _selectedPriority,
                        onChanged: (value) {
                          setState(() {
                            _selectedPriority = value as int;
                          });
                        },
                      ),
                      Text('1'),
                    ],
                  ),
                  Row(
                    children: [
                      Radio(
                        value: 2,
                        groupValue: _selectedPriority,
                        onChanged: (value) {
                          setState(() {
                            _selectedPriority = value as int;
                          });
                        },
                      ),
                      Text('2'),
                    ],
                  ),
                  Row(
                    children: [
                      Radio(
                        value: 3,
                        groupValue: _selectedPriority,
                        onChanged: (value) {
                          setState(() {
                            _selectedPriority = value as int;
                          });
                        },
                      ),
                      Text('3'),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),

              /// ID người được giao
              TextFormField(
                controller: _asignedToController,
                decoration: InputDecoration(
                  labelText: 'ID người được giao',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {

                  return null;
                },
              ),
              SizedBox(height: 16),

              /// ID người tạo
              TextFormField(
                controller: _createdByController,
                decoration: InputDecoration(
                  labelText: 'ID người tạo',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập ID người tạo';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              /// Phân loại
              TextFormField(
                controller: _categoryByController,
                decoration: InputDecoration(
                  labelText: 'Phân loại',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Nhập các đính kèm
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Đính kèm',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      // Mở hộp thoại để nhập nhãn
                      showDialog<String>(
                        context: context,
                        builder: (context) {
                          final TextEditingController attachmentController =
                          TextEditingController();
                          return AlertDialog(
                            title: Text('Thêm đính kèm'),
                            content: TextField(
                              controller: attachmentController,
                              decoration: InputDecoration(
                                labelText: 'Nhập đính kèm',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  if (attachmentController.text.isNotEmpty) {
                                    _addattAchment(attachmentController.text);
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: Text('Thêm'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Hiển thị nhãn đã thêm
              Wrap(
                children: _attachment.map((attachment) {
                  return Chip(
                    label: Text(attachment),
                    onDeleted: () => _removeAttachment(attachment),
                  );
                }).toList(),
              ),
              SizedBox(height: 24),

              // Nút lưu
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: Text(
                    isEditing ? 'CẬP NHẬT' : 'THÊM MỚI',
                    style: TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}