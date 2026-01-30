import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swipeable_button_view/swipeable_button_view.dart';
import 'firebase_service.dart';
import 'user_details.dart';

class ManualSignupPage extends StatefulWidget {
  final bool isLogin;
  const ManualSignupPage({super.key, this.isLogin = false});

  @override
  State<ManualSignupPage> createState() => _ManualSignupPageState();
}

class _ManualSignupPageState extends State<ManualSignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _dobController = TextEditingController();
  final _instaController = TextEditingController();
  final _youtubeController = TextEditingController();
  
  String? _selectedGender;
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;
  bool _isFormValid = false;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_updateFormValidity);
    _passwordController.addListener(_updateFormValidity);
    
    if (!widget.isLogin) {
      _nameController.addListener(_updateFormValidity);
      _usernameController.addListener(_updateFormValidity);
      _dobController.addListener(_updateFormValidity);
      _instaController.addListener(_updateFormValidity);
      _youtubeController.addListener(_updateFormValidity);
    } else {
      _updateFormValidity();
    }
  }

  bool _checkIfFormIsComplete() {
    if (widget.isLogin) {
      return _emailController.text.isNotEmpty && _passwordController.text.length >= 6;
    } else {
      if (_nameController.text.isEmpty) return false;
      if (_usernameController.text.length < 3) return false;
      if (_dobController.text.isEmpty) return false;
      if (_selectedGender == null) return false;
      if (_instaController.text.isEmpty) return false;
      if (_youtubeController.text.isEmpty) return false;
      if (_emailController.text.isEmpty) return false;
      if (_passwordController.text.length < 6) return false;

      try {
        final dob = DateFormat('yyyy-MM-dd').parse(_dobController.text);
        final today = DateTime.now();
        int age = today.year - dob.year;
        if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
          age--;
        }
        if (age < 13) return false;
      } catch (e) {
        return false;
      }
      return true;
    }
  }

  void _updateFormValidity() {
    final isComplete = _checkIfFormIsComplete();
    if (_isFormValid != isComplete) {
      setState(() {
        _isFormValid = isComplete;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _dobController.dispose();
    _instaController.dispose();
    _youtubeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(DateTime.now().year - 13),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
      _updateFormValidity();
    }
  }

  void _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    final user = await _firebaseService.signInWithGoogle();
    setState(() => _isLoading = false);

    if (user != null && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const UserDetailsPage()),
        (route) => false,
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google Sign In failed')),
      );
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
       setState(() {
         _isFinished = false;
       });
       return;
    }

    dynamic result;
    if (widget.isLogin) {
      result = await _firebaseService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    } else {
      result = await _firebaseService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        additionalData: {
          'name': _nameController.text.trim(),
          'username': _usernameController.text.trim(),
          'dob': _dobController.text,
          'gender': _selectedGender,
          'instagram': _instaController.text.trim(),
          'youtube': _youtubeController.text.trim(),
        },
      );
    }

    if (result != null && mounted) {
      setState(() {
        _isFinished = true;
      });
    } else if (mounted) {
      setState(() {
        _isFinished = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.isLogin ? 'Login failed' : 'Signup failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.isLogin ? "Login" : "Manual Sign Up"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!widget.isLogin) ...[
                  _buildTextField(_nameController, "Full Name", Icons.person, (v) => (v == null || v.isEmpty) ? "Required" : null),
                  const SizedBox(height: 16),
                  _buildTextField(_usernameController, "Username", Icons.alternate_email, (v) => (v == null || v.length < 3) ? "Min 3 characters" : null),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dobController,
                    readOnly: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      labelText: "Date of Birth",
                      prefixIcon: const Icon(Icons.cake),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onTap: () => _selectDate(context),
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Required";
                      try {
                        final dob = DateFormat('yyyy-MM-dd').parse(v);
                        final today = DateTime.now();
                        int age = today.year - dob.year;
                        if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
                          age--;
                        }
                        if (age < 13) return "Must be 13+ years old";
                      } catch (e) {
                        return "Invalid date";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      labelText: "Gender",
                      prefixIcon: const Icon(Icons.people),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: ["Male", "Female", "Other"].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedGender = newValue;
                      });
                      _updateFormValidity();
                    },
                    validator: (v) => v == null ? "Required" : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(_instaController, "Instagram Username", Icons.camera_alt, (v) => (v == null || v.isEmpty) ? "Required" : null),
                  const SizedBox(height: 16),
                  _buildTextField(_youtubeController, "YouTube Channel", Icons.play_circle_fill, (v) => (v == null || v.isEmpty) ? "Required" : null),
                  const SizedBox(height: 16),
                ],
                _buildTextField(_emailController, "Email", Icons.email, (v) => (v == null || v.isEmpty) ? "Required" : null),
                const SizedBox(height: 16),
                _buildTextField(_passwordController, "Password", Icons.lock, (v) => (v == null || v.length < 6) ? "Min 6 characters" : null, obscure: true),
                const SizedBox(height: 32),
                
                // Swipeable Button instead of normal button
                Center(
                  child: Opacity(
                    opacity: _isFormValid ? 1.0 : 0.5,
                    child: AbsorbPointer(
                      absorbing: !_isFormValid,
                      child: SwipeableButtonView(
                        buttonText: widget.isLogin ? "SWIPE TO LOGIN" : "SWIPE TO SIGN UP",
                        buttonWidget: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey),
                        activeColor: const Color(0xFF6A11CB),
                        isFinished: _isFinished,
                        onWaitingProcess: () {
                          _handleSubmit();
                        },
                        onFinish: () async {
                          await Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const UserDetailsPage()),
                            (route) => false,
                          );
                          setState(() {
                            _isFinished = false;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                
                if (widget.isLogin) ...[
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[300])),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text("OR", style: TextStyle(color: Colors.grey)),
                      ),
                      Expanded(child: Divider(color: Colors.grey[300])),
                    ],
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _handleGoogleSignIn,
                    icon: const Icon(Icons.g_mobiledata_rounded, size: 40, color: Colors.redAccent),
                    label: const Text("Sign in with Google", style: TextStyle(fontSize: 16, color: Colors.black87)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, String? Function(String?)? validator, {bool obscure = false}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: validator,
    );
  }
}
