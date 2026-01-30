import 'package:flutter/material.dart';
import 'firebase_service.dart';
import 'signup_selection.dart';

class UserDetailsPage extends StatefulWidget {
  const UserDetailsPage({super.key});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  final FirebaseService _firebaseService = FirebaseService();
  Map<dynamic, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    final user = _firebaseService.currentUser;
    if (user != null) {
      final data = await _firebaseService.getUserData(user.uid);
      setState(() {
        _userData = data;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _handleSignOut() async {
    await _firebaseService.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SignupSelection()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Profile Details", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _handleSignOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userData == null
              ? const Center(child: Text("No user data found"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: const Color(0xFF6A11CB),
                              backgroundImage: (_userData!['profilePic'] != null && _userData!['profilePic'] != '')
                                  ? NetworkImage(_userData!['profilePic'])
                                  : null,
                              child: (_userData!['profilePic'] == null || _userData!['profilePic'] == '')
                                  ? const Icon(Icons.person, size: 60, color: Colors.white)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      
                      _buildHeader("Personal Information"),
                      _buildInfoTile("Full Name", _userData!['name'], Icons.person_outline),
                      _buildInfoTile("Username", _userData!['username'], Icons.alternate_email),
                      _buildInfoTile("Email", _userData!['email'], Icons.email_outlined),
                      _buildInfoTile("Date of Birth", _userData!['dob'], Icons.cake_outlined),
                      _buildInfoTile("Gender", _userData!['gender'], Icons.people_outline),
                      
                      const SizedBox(height: 20),
                      _buildHeader("Social Channels"),
                      _buildInfoTile("Instagram", _userData!['instagram'], Icons.camera_alt_outlined),
                      _buildInfoTile("YouTube", _userData!['youtube'], Icons.play_circle_outline),
                      
                      const SizedBox(height: 20),
                      _buildHeader("Account Status"),
                      _buildInfoTile("Signup Type", _userData!['authMethod'], Icons.security_outlined),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple[700],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, dynamic value, IconData icon) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple[400]),
        title: Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        subtitle: Text(
          value?.toString() ?? "Not provided",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ),
    );
  }
}
