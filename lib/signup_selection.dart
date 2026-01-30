import 'package:flutter/material.dart';
import 'firebase_service.dart';
import 'manual_signup.dart';
import 'user_details.dart';

class SignupSelection extends StatefulWidget {
  const SignupSelection({super.key});

  @override
  State<SignupSelection> createState() => _SignupSelectionState();
}

class _SignupSelectionState extends State<SignupSelection> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;

  void _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    final user = await _firebaseService.signInWithGoogle();
    setState(() => _isLoading = false);

    if (user != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UserDetailsPage()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google Sign In failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.rocket_launch_rounded,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      "Get Started",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Choose your signup method",
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                    const Spacer(),
                    if (_isLoading)
                      const CircularProgressIndicator(color: Colors.white)
                    else ...[
                      _buildButton(
                        onPressed: _handleGoogleSignIn,
                        icon: const Icon(Icons.g_mobiledata_rounded, size: 40, color: Colors.redAccent),
                        label: "Sign up with Google",
                        backgroundColor: Colors.white,
                        textColor: Colors.black87,
                      ),
                      const SizedBox(height: 16),
                      _buildButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ManualSignupPage()),
                          );
                        },
                        icon: const Icon(Icons.email_outlined, color: Colors.white),
                        label: "Manual Sign Up",
                        backgroundColor: Colors.white.withOpacity(0.2),
                        textColor: Colors.white,
                        isOutlined: true,
                      ),
                    ],
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.white38)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text("Already have an account?", style: TextStyle(color: Colors.white70)),
                        ),
                        Expanded(child: Divider(color: Colors.white38)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ManualSignupPage(isLogin: true)),
                        );
                      },
                      label: "Login",
                      backgroundColor: Colors.transparent,
                      textColor: Colors.white,
                      isOutlined: true,
                      borderColor: Colors.white,
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required VoidCallback onPressed,
    Widget? icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    bool isOutlined = false,
    Color? borderColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: isOutlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: borderColor ?? Colors.white.withOpacity(0.5), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[icon, const SizedBox(width: 12)],
                  Text(label, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: textColor)),
                ],
              ),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: textColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[icon, const SizedBox(width: 12)],
                  Text(label, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textColor)),
                ],
              ),
            ),
    );
  }
}
