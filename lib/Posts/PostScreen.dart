import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../Models/Post.dart';


// CreatePostScreen Widget
class CreatePostScreen extends StatefulWidget {
  final String userId;

  CreatePostScreen({required this.userId});

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController contentController = TextEditingController();
  String? imageBase64;

  void selectImage() async {
    final selectedImage = await pickImageAndConvertToBase64();
    if (selectedImage != null) {
      setState(() {
        imageBase64 = selectedImage;
      });
    }
  }

  void submitPost() async {
    final content = contentController.text.trim();
    if (content.isNotEmpty || imageBase64 != null) {
      await createPost(widget.userId, content, imageBase64);
      Navigator.pop(context);
    } else {
      // Handle empty content case
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Post")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: contentController,
              decoration: InputDecoration(labelText: 'Content'),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            imageBase64 != null
                ? Image.memory(base64Decode(imageBase64!))
                : Container(),
            ElevatedButton(
              onPressed: selectImage,
              child: Text("Pick Image"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: submitPost,
              child: Text("Post"),
            ),
          ],
        ),
      ),
    );
  }
}
