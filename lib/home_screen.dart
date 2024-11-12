import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userName;
  String? userPhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
    final List<Map<String, String>> users = [
    {
      'image': 'https://randomuser.me/api/portraits/men/1.jpg',
      'name': 'John Doe',
    },
    {
      'image': 'https://randomuser.me/api/portraits/men/2.jpg',
      'name': 'James Smith',
    },
    {
      'image': 'https://randomuser.me/api/portraits/men/3.jpg',
      'name': 'Robert Johnson',
    },
    {
      'image': 'https://randomuser.me/api/portraits/men/4.jpg',
      'name': 'Michael Brown',
    },
    {
      'image': 'https://randomuser.me/api/portraits/men/5.jpg',
      'name': 'William Lee',
    },
  ];



  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName');
      userPhotoUrl = prefs.getString('userPhotoUrl');
    });
  }

  final _databaseRef = FirebaseDatabase.instance.ref("posts");
Future<void> _addPost() async {
  String? postText = await _showTextInputDialog(context);

  if (postText != null && postText.isNotEmpty) {
    // Include the user's name and photo URL when saving the post
    await _databaseRef.push().set({
      "text": postText,
      "timestamp": DateTime.now().toIso8601String(),
      "userName": userName ?? "Anonymous", // Default to "Anonymous" if userName is null
      "userPhotoUrl": userPhotoUrl, // Add the user's profile photo URL
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Post added successfully!")),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Post text cannot be empty.")),
    );
  }
}

  Future<String?> _showTextInputDialog(BuildContext context) async {
    String inputText = "";
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Post Text"),
          content: TextField(
            onChanged: (value) {
              inputText = value;
            },
            decoration: InputDecoration(hintText: "Enter post text"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(inputText),
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00897B),
        title: Row(
          children: [
            if (userPhotoUrl != null)
              CircleAvatar(
                backgroundImage: NetworkImage(userPhotoUrl!),
                radius: 15,
              ),
            if (userName != null) ...[
              SizedBox(width: 8),
              Text(
                userName!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              height: 100,
              child:ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: users.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(users[index]['image']!),
                ),
                SizedBox(height: 5),
                Text(
                  users[index]['name']!,
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          );
        },
      ),
            ),
            SizedBox(height: 10),
            Expanded(
  child: StreamBuilder(
    stream: _databaseRef.orderByChild("timestamp").onValue,
    builder: (context, snapshot) {
      if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
        return Center(child: Text("No posts available."));
      }

      final posts = Map<String, dynamic>.from(
        snapshot.data?.snapshot.value as Map<dynamic, dynamic>
      );

      final postWidgets = posts.values.map((post) {
        return Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        post["userPhotoUrl"] ?? 'https://via.placeholder.com/150'
                      ),
                      radius: 25,
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post["userName"] ?? "User",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          "Just now",
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Text(
                  post["text"] ?? "",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.thumb_up_alt_outlined, color: Colors.teal[700]),
                        SizedBox(width: 5),
                        Text("Like", style: TextStyle(color: Colors.teal[700])),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.comment_outlined, color: Colors.teal[700]),
                        SizedBox(width: 5),
                        Text("Comment", style: TextStyle(color: Colors.teal[700])),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.share_outlined, color: Colors.teal[700]),
                        SizedBox(width: 5),
                        Text("Share", style: TextStyle(color: Colors.teal[700])),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      }).toList();

      return ListView(children: postWidgets);
    },
  ),
),

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPost,
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF00695C),
      ),
    );
  }
}
