class Task {
  String? id;
  String title;
  String description;
  String status;
  int priority;
  DateTime? duaDate;
  DateTime createdAt;
  DateTime updateAt;
  String? assignedTo; // Nullable
  String createdBy;
  String? category; // Nullable
  List<String>? attachment; // Nullable
  bool completed;



  Task({
    this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.duaDate,
    required this.createdAt,
    required this.updateAt,
    this.assignedTo,
    required this.createdBy,
    this.category,
    this.attachment,
    required this.completed,
  });

  // Chuyển đối tượng Tasks thành Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'duaDate': duaDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updateAt': updateAt.toIso8601String(),
      'assignedTo': assignedTo,
      'createdBy': createdBy,
      'category': category,
      'attachment': attachment?.join(','),
      'completed': completed ? 1 : 0,
    };
  }

  // Tạo đối tượng User từ Map
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String?,
      title: map['title'] as String,
      description: map['description'] as String,
      status: map['status'] as String,
      priority: map['priority'] as int,
      duaDate: DateTime.parse(map['duaDate'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updateAt: DateTime.parse(map['updateAt'] as String),
      assignedTo: map['assignedTo'] as String?,
      createdBy: map['createdBy'] as String,
      category: map['category'] as String?,
      attachment: map['attachment'] != null ? (map['attachment'] as String).split(',') : null,
      completed: map['completed'] == 1,
    );
  }

  // Phương thức copy để tạo bản sao với một số thuộc tính được cập nhật
  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    int? priority,
    DateTime? duaDate,
    DateTime? createdAt,
    DateTime? updateAt,
    String? assignedTo,
    String? createdBy,
    String? category,
    List<String>? attachment,
    bool? completed,

  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      duaDate: duaDate ?? this.duaDate,
      createdAt: createdAt ?? this.createdAt,
      updateAt: updateAt ?? this.updateAt,
      assignedTo: assignedTo ?? this.assignedTo,
      createdBy: createdBy ?? this.createdBy,
      category: category ?? this.category,
      attachment: attachment ?? this.attachment,
      completed: completed ?? this.completed,

    );
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, description: $description, status: $status, priority: $priority, duaDate: $duaDate, createdAt: $createdAt, updateAt: $updateAt, assignedTo: $assignedTo, createdBy: $createdBy, category: $category, attachment: $attachment, completed: $completed)';
  }

}