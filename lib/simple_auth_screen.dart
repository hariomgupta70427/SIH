import 'package:flutter/material.dart';
import 'home_screen.dart';

class SimpleAuthScreen extends StatefulWidget {
  @override
  _SimpleAuthScreenState createState() => _SimpleAuthScreenState();
}

class _SimpleAuthScreenState extends State<SimpleAuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    
    await Future.delayed(Duration(seconds: 1));
    
    final email = _emailController.text.trim();
    String userRole = 'user';
    
    if (email == 'inspector@qrail.com') userRole = 'inspector';
    if (email == 'vendor@qrail.com') userRole = 'vendor';
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => HomeScreen(userRole: userRole)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[900]!, Colors.blue[600]!],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Card(
                elevation: 20,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.train_rounded, size: 64, color: Colors.blue[700]),
                      SizedBox(height: 24),
                      Text('QRail', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                      Text('Railway Inspection System', style: TextStyle(color: Colors.grey[600])),
                      SizedBox(height: 32),
                      
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          prefixIcon: Icon(Icons.email),
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                      ),
                      SizedBox(height: 24),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _isLoading 
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text('Login', style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      ),
                      SizedBox(height: 24),
                      
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text('Demo Credentials:', style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            _buildCredRow('Inspector', 'inspector@qrail.com', 'inspector123'),
                            _buildCredRow('Vendor', 'vendor@qrail.com', 'vendor123'),
                            _buildCredRow('User', 'user@qrail.com', 'user123'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCredRow(String role, String email, String password) {
    return GestureDetector(
      onTap: () {
        _emailController.text = email;
        _passwordController.text = password;
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 4),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text('$role: ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
            Text('$email / $password', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}