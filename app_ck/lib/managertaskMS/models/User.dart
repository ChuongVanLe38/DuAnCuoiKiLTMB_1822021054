class User {
  String id;
  String username;
  String password;
  String email;
  String? avatar;
  DateTime createdAt;
  DateTime lastActive;
  bool isAdmin;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.email,
    this.avatar,
    required this.createdAt,
    required this.lastActive,
    required this.isAdmin,
  });

  // Chuyển đối tượng User thành Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'email': email,
      'avatar': avatar,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
      'isAdmin': isAdmin ? 1 : 0,
    };
  }

  // Tạo đối tượng User từ Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      email: map['email'],
      avatar: map['avatar'],
      createdAt: DateTime.parse(map['createdAt']),
      lastActive: DateTime.parse(map['lastActive']),
      isAdmin:  map['isAdmin'] == 1,
    );
  }

  // Phương thức copy để tạo bản sao với một số thuộc tính được cập nhật
  User copyWith({
    String? id,
    String? username,
    String? password,
    String? email,
    String? avatar,
    DateTime? createdAt,
    DateTime? lastActive,
    bool? isAdmin,

  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, password: $password, email: $email, createdAt: $createdAt, lastActive: $lastActive, isAdmin: $isAdmin)';
  }

}