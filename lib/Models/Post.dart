import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';

// Post Model
class Post {
  String userId;
  String content;
  String imageBase64;
  String timestamp;

  Post({
    required this.userId,
    required this.content,
    required this.imageBase64,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'content': content,
      'imageBase64': imageBase64,
      'timestamp': timestamp,
    };
  }

  static Post fromMap(Map<String, dynamic> map) {
    return Post(
      userId: map['userId'],
      content: map['content'],
      imageBase64: map['imageBase64'],
      timestamp: map['timestamp'],
    );
  }
}


Future<String?> pickImageAndConvertToBase64() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    final bytes = await File(pickedFile.path).readAsBytes();
    return base64Encode(bytes);
  }
  return null;
}


final DatabaseReference databaseRef = FirebaseDatabase.instance.ref().child('posts');


Future<void> createPost(String userId, String content, String? imageBase64) async {
  final post = Post(
    userId: userId,
    content: content,
    imageBase64: imageBase64 ?? '',
    timestamp: DateTime.now().toIso8601String(),
  );

  await databaseRef.push().set(post.toMap());
}

