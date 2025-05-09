import 'package:app_ck/managertaskMS/view/TaskListScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../service/database.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:app_ck/managertaskMS/models/user.dart';

class AuthMethods {
  final firebase_auth.FirebaseAuth auth = firebase_auth.FirebaseAuth.instance;

  Future<firebase_auth.User?> getCurrentUser() async {
    return auth.currentUser;
  }

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

  signInWithGoogle(BuildContext context) async {
    final firebase_auth.FirebaseAuth firebaseAuth = firebase_auth.FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

      if (googleSignInAccount == null) {
        // Người dùng hủy đăng nhập
        return;
      }

      final GoogleSignInAuthentication? googleSignInAuthentication =
      await googleSignInAccount.authentication;

      final firebase_auth.AuthCredential credential = firebase_auth.GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication?.idToken,
        accessToken: googleSignInAuthentication?.accessToken,
      );

      firebase_auth.UserCredential result = await firebaseAuth.signInWithCredential(credential);

      firebase_auth.User? userDetails = result.user;

      if (userDetails != null) {
        // Tạo id mới
        String newId = await generateUserId();
        // Tạo đối tượng User
        User user = User(
          id: newId,
          username: userDetails.displayName ?? "Google User",
          password: "", // Không lưu mật khẩu cho Google Sign-In
          email: userDetails.email ?? "",
          avatar: userDetails.photoURL,
          createdAt: DateTime.now(),
          lastActive: DateTime.now(),
          isAdmin: false,
        );

        // Lưu thông tin người dùng vào Firestore
        await DatabaseMethods().addUser(userDetails.uid, user.toMap());

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TaskListScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text(
            "Đã xảy ra lỗi khi đăng nhập với Google: $e",
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      );
    }
  }
}