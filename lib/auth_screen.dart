import 'package:flutter/material.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  String _selectedRole = 'inspector';

  void _authenticate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(Duration(seconds: 1));

    final email = _emailController.text.trim();
    String userRole = 'user';
    
    if (_isLogin) {
      if (email == 'inspector@qrail.com') userRole = 'inspector';
      if (email == 'vendor@qrail.com') userRole = 'vendor';
    } else {
      userRole = _selectedRole;
    }
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => HomeScreen(userRole: userRole)),
    );
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[900]!, Colors.blue[600]!, Colors.blue[400]!],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Card(
                elevation: 20,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Container(
                  padding: EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey[50]!],
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Colors.blue[600]!, Colors.blue[800]!]),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(Icons.train_rounded, size: 48, color: Colors.white),
                        ),
                        SizedBox(height: 24),
                        Text('QRail', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue[800])),
                        Text('Railway Inspection System', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                        SizedBox(height: 32),
                        
                        // Login/Register Toggle
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _isLogin = true),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    decoration: BoxDecoration(
                                      color: _isLogin ? Colors.blue[600] : Colors.transparent,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      'Login',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: _isLogin ? Colors.white : Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _isLogin = false),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    decoration: BoxDecoration(
                                      color: !_isLogin ? Colors.blue[600] : Colors.transparent,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      'Register',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: !_isLogin ? Colors.white : Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),
                        
                        // Role Selection for Registration
                        if (!_isLogin)
                          Container(
                            margin: EdgeInsets.only(bottom: 24),
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [Colors.blue[50]!, Colors.indigo[50]!]),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.blue[200]!, width: 1),
                            ),
                            child: Column(
                              children: [
                                Text('Select Your Role', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue[800])),
                                SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() => _selectedRole = 'inspector'),
                                        child: Container(
                                          padding: EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: _selectedRole == 'inspector' ? Colors.blue[100] : Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: _selectedRole == 'inspector' ? Colors.blue : Colors.grey[300]!,
                                              width: 2,
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              Icon(Icons.search_rounded, color: _selectedRole == 'inspector' ? Colors.blue : Colors.grey, size: 32),
                                              SizedBox(height: 8),
                                              Text('Inspector', style: TextStyle(fontWeight: FontWeight.w600)),
                                              Text('Quality inspection', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() => _selectedRole = 'vendor'),
                                        child: Container(
                                          padding: EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: _selectedRole == 'vendor' ? Colors.teal[100] : Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: _selectedRole == 'vendor' ? Colors.teal : Colors.grey[300]!,
                                              width: 2,
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              Icon(Icons.qr_code_2_rounded, color: _selectedRole == 'vendor' ? Colors.teal : Colors.grey, size: 32),
                                              SizedBox(height: 8),
                                              Text('Vendor', style: TextStyle(fontWeight: FontWeight.w600)),
                                              Text('QR generation', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        
                        // Name Field for Registration
                        if (!_isLogin)
                          Container(
                            margin: EdgeInsets.only(bottom: 16),
                            child: TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                prefixIcon: Icon(Icons.person_outline),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.blue, width: 2),
                                ),
                              ),
                              validator: (value) => value?.isEmpty == true ? 'Name is required' : null,
                            ),
                          ),
                        
                        // Email Field
                        Container(
                          margin: EdgeInsets.only(bottom: 16),
                          child: TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.blue, width: 2),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value?.isEmpty == true) return 'Email is required';
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) return 'Enter valid email';
                              return null;
                            },
                          ),
                        ),
                        
                        // Password Field
                        Container(
                          margin: EdgeInsets.only(bottom: 24),
                          child: TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock_outline),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.blue, width: 2),
                              ),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value?.isEmpty == true) return 'Password is required';
                              if (value!.length < 6) return 'Password must be at least 6 characters';
                              return null;
                            },
                          ),
                        ),
                        
                        // Submit Button
                        Container(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _authenticate,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              foregroundColor: Colors.white,
                              elevation: 8,
                              shadowColor: Colors.blue.withOpacity(0.4),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(_isLogin ? 'Login' : 'Register', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        
                        // Demo Credentials
                        if (_isLogin)
                          Container(
                            margin: EdgeInsets.only(top: 24),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [Colors.amber[50]!, Colors.orange[50]!]),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.orange[200]!, width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                                    SizedBox(width: 8),
                                    Text('Demo Credentials', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.orange[800])),
                                  ],
                                ),
                                SizedBox(height: 12),
                                _buildCredentialRow('Inspector', 'inspector@qrail.com', 'inspector123', Icons.search),
                                _buildCredentialRow('Vendor', 'vendor@qrail.com', 'vendor123', Icons.qr_code_2),
                                _buildCredentialRow('User', 'user@qrail.com', 'user123', Icons.person),
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
      ),
    );
  }

  Widget _buildCredentialRow(String role, String email, String password, IconData icon) {
    return GestureDetector(
      onTap: () {
        _emailController.text = email;
        _passwordController.text = password;
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(role, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                  Text('$email / $password', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                ],
              ),
            ),
            Icon(Icons.touch_app, size: 16, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}