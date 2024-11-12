import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_media_app/signup_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_screen.dart';


import 'package:firebase_auth/firebase_auth.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _errorMessage;

Future<void> _signInWithGoogle() async {
  setState(() {
    _isLoading = true;
  });

  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      setState(() {
        _isLoading = false;
      });
      return; 
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await _auth.signInWithCredential(credential);
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
       await prefs.setString('userEmail', googleUser.email);
       await prefs.setString('userName', googleUser.displayName ?? '');
       await prefs.setString('userPhotoUrl', googleUser.photoUrl ?? '');

    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Google Sign-In successful!"), backgroundColor: Colors.green),
    );

    
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
  } catch (error) {
    
     ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Google Sign-In failed: $error"), backgroundColor: Colors.red),
    );
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}



 Future<void> _loginUser() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    await _auth.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', _emailController.text.trim()); 
      await prefs.setBool('isLoggedIn', true); 
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Login successful!"),
        backgroundColor: Colors.green,
      ),
    );

     Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
  } catch (error) {
    setState(() {
      _errorMessage = error.toString();
    });

    // Show an error SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Login failed: $_errorMessage"),
        backgroundColor: Colors.red,
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade300, Colors.teal.shade800],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 80,
                    color: Colors.white,
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Welcome Back!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade800,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Log in to continue',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        SizedBox(height: 30),
                        _buildTextField(
                          hintText: 'Email',
                          icon: Icons.email_outlined,
                          obscureText: false,
                          controller: _emailController,
                        ),
                        SizedBox(height: 20),
                        _buildTextField(
                          hintText: 'Password',
                          icon: Icons.lock_outline,
                          obscureText: true,
                          controller: _passwordController,
                        ),
                        SizedBox(height: 30),
                        if (_errorMessage != null)
                          Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red),
                          ),
                        _isLoading
                            ? CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: _loginUser,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                                  backgroundColor: Colors.teal.shade700,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                        SizedBox(height: 20),
                        Text(
                          "Don't have an account?",
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
                          },
                          child: Text(
                            "Sign Up",
                            style: TextStyle(color: Colors.teal.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    '- Or sign in with -',
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 10),
                 Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialIcon(Icons.facebook, Colors.blue),
                      SizedBox(width: 16),
                      _buildSocialIcon(Icons.email, Colors.red),
                      SizedBox(width: 16),
                      GestureDetector(
                        onTap: _signInWithGoogle,
                        child: _buildSocialIcon(Icons.g_mobiledata, Colors.green),
                      ),
                    ],
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required IconData icon,
    required bool obscureText,
    required TextEditingController controller,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.teal.shade700),
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding: EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $hintText';
        }
        return null;
      },
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color) {
    return CircleAvatar(
      backgroundColor: Colors.white,
      child: Icon(icon, color: color),
    );
  }
}
