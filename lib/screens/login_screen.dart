import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _isLoading = false;
  bool _isFarmer = true; // Default user type selection
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE5F0E7), // top
              Color(0xFFEDF2E5), // middle
              Color.fromARGB(255, 246, 246, 226) // bottom
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 40),
                    Text(
                      'AgriRoute',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _isSignUp ? 'Sign Up' : 'Login',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 48,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _isSignUp ? 'Create a new account' : 'Sign in to continue',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 40),
                    
                    // Name field - only shown in signup mode
                    if (_isSignUp)
                      Container(
                        margin: EdgeInsets.only(bottom: 16, left: 50, right: 50),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'NAME',
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            border: InputBorder.none,
                            hintStyle: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: Colors.black45,
                            ),
                          ),
                          validator: _isSignUp 
                            ? (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              }
                            : null,
                        ),
                      ),
                    
                    // Email field
                    Container(
                      margin: EdgeInsets.only(bottom: 16, left: 50, right: 50),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'EMAIL',
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          border: InputBorder.none,
                          hintStyle: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: Colors.black45,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                    ),
                    
                    // Password field
                    Container(
                      margin: EdgeInsets.only(left: 50, right: 50),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'PASSWORD',
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          border: InputBorder.none,
                          hintStyle: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: Colors.black45,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (_isSignUp && value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                    
                    // User Type Selection - only shown in signup mode
                    if (_isSignUp) 
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center, // 👈 This helps
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Checkbox(
                                  value: _isFarmer,
                                  activeColor: Color(0xFF5F8F58),
                                  onChanged: (value) {
                                    setState(() {
                                      _isFarmer = true;
                                    });
                                  },
                                ),
                                Text(
                                  'Farmer',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 16),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Checkbox(
                                  value: !_isFarmer,
                                  activeColor: Color(0xFF5F8F58),
                                  onChanged: (value) {
                                    setState(() {
                                      _isFarmer = false;
                                    });
                                  },
                                ),
                                Text(
                                  'Hobbyist',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    if (!_isSignUp) SizedBox(height: 32),
                                        
                    // Login/Signup Button
                    _isLoading ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B9A68)),
                    ) : 
                    Container(
                      margin: EdgeInsets.only(left: 50, right: 50),
                      width: double.infinity,
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF5F8F58), // Green button
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            _isSignUp ? 'SIGN UP' : 'LOG IN',
                            style: GoogleFonts.dmSerifDisplay(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Toggle between sign in and sign up
                    if (!_isSignUp) 
                      TextButton(
                        onPressed: () {
                          // Handle forgot password action
                        },
                        child: Text(
                          'Forgot Password?',
                          style: GoogleFonts.dmSans(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isSignUp = !_isSignUp;
                        });
                      },
                      child: Text(
                        _isSignUp
                            ? 'Already have an account? Log In'
                            : 'Sign Up Instead!',
                        style: GoogleFonts.dmSans(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (!mounted) return; // 👈 Check before setState
      setState(() {
        _isLoading = true;
      });

      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        if (_isSignUp) {
          await authService.signUp(
            _nameController.text,
            _emailController.text,
            _passwordController.text,
            _isFarmer ? 'farmer' : 'hobbyist',
          );
        } else {
          await authService.signIn(
            _emailController.text,
            _passwordController.text,
          );
        }
      } catch (e) {
        if (!mounted) return; // 👈 Check before showing a SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        if (!mounted) return; // 👈 Check before final setState
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

}