import 'package:app_ck/service/auth.dart';

import '../login.dart';
import 'package:app_ck/managertaskMS/view/TaskListScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:app_ck/managertaskMS/models/user.dart'; // Lớp User tùy chỉnh
import '../service/database.dart'; // Import DatabaseMethods

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String email = "", password = "", username = "";
  bool _isLoading = false;

  TextEditingController usernamecontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController mailcontroller = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  // Hàm tạo id với định dạng NVxxx
  Future<String> generateUserId() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection("Users").get();
      int maxNumber = 0;
      for (var doc in snapshot.docs) {
        String id = doc['id'];
        if (id.startsWith('NV')) {
          int number = int.parse(id.substring(2));
          if (number > maxNumber) maxNumber = number;
        }
      }
      // Tăng số thứ tự và định dạng
      return 'NV${(maxNumber + 1).toString().padLeft(3, '0')}';
    } catch (e) {
      // Nếu có lỗi, bắt đầu từ NV001
      return 'NV001';
    }
  }

  registration() async {
    setState(() {
      _isLoading = true;
    });
    try {
      firebase_auth.UserCredential userCredential = await firebase_auth.FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Tạo id mới
      String newId = await generateUserId();

      // Cập nhật displayName trong Firebase Authentication
      await userCredential.user!.updateDisplayName(username);

      // Tạo đối tượng User
      User user = User(
        id: newId,
        username: username,
        password: password,
        email: email,
        avatar: null,
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
        isAdmin: false,
      );

      // Lưu thông tin người dùng vào Firestore
      await DatabaseMethods().addUser(userCredential.user!.uid, user.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text(
            "Đăng kí thành công",
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      );
      Navigator.push(context, MaterialPageRoute(builder: (context) => TaskListScreen()));
    } on firebase_auth.FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = "Mật khẩu cung cấp quá yếu";
          break;
        case 'email-already-in-use':
          message = "Tài khoản đã tồn tại";
          break;
        case 'invalid-email':
          message = "Email không hợp lệ";
          break;
        case 'operation-not-allowed':
          message = "Tài khoản email bị vô hiệu hóa";
          break;
        case 'too-many-requests':
          message = "Quá nhiều yêu cầu, vui lòng thử lại sau";
          break;
        default:
          message = "Đã xảy ra lỗi: ${e.message}";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text(
            message,
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text(
            "Đã xảy ra lỗi không xác định",
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              child: Image.asset(
                "assets/images/tasks.jpg",
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 30.0),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Form(
                key: _formkey,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 30.0),
                      decoration: BoxDecoration(
                        color: Color(0xFFedf0f8),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập tên';
                          }
                          return null;
                        },
                        controller: usernamecontroller,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Tên người dùng",
                          hintStyle: TextStyle(color: Color(0xFFb2b7bf), fontSize: 18.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 30.0),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 30.0),
                      decoration: BoxDecoration(
                        color: Color(0xFFedf0f8),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập Email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Email không hợp lệ';
                          }
                          return null;
                        },
                        controller: mailcontroller,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Email",
                          hintStyle: TextStyle(color: Color(0xFFb2b7bf), fontSize: 18.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 30.0),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 30.0),
                      decoration: BoxDecoration(
                        color: Color(0xFFedf0f8),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mật khẩu';
                          }
                          if (value.length < 6) {
                            return 'Mật khẩu phải có ít nhất 6 ký tự';
                          }
                          return null;
                        },
                        controller: passwordcontroller,
                        obscureText: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Mật khẩu",
                          hintStyle: TextStyle(color: Color(0xFFb2b7bf), fontSize: 18.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 30.0),
                    GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () {
                        if (_formkey.currentState!.validate()) {
                          setState(() {
                            email = mailcontroller.text;
                            username = usernamecontroller.text;
                            password = passwordcontroller.text;
                          });
                          registration();
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(vertical: 13.0, horizontal: 30.0),
                        decoration: BoxDecoration(
                          color: Color(0xFF273671),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                            "Đăng kí",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 40.0),
            Text(
              "Hoặc đăng nhập với",
              style: TextStyle(
                color: Color(0xFF273671),
                fontSize: 22.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 30.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    AuthMethods().signInWithGoogle(context);
                  },
                  child: Image.asset(
                    "assets/images/google.png",
                    height: 45,
                    width: 45,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 30.0),
              ],
            ),
            SizedBox(height: 40.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Bạn đã có tài khoản?",
                  style: TextStyle(
                    color: Color(0xFF8c8e98),
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 5.0),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LogIn()));
                  },
                  child: Text(
                    "Đăng nhập",
                    style: TextStyle(
                      color: Color(0xFF273671),
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}