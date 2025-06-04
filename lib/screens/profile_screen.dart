import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser;
  DocumentSnapshot<Map<String, dynamic>>? _userDoc;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    if (_currentUser == null) {
      setState(() {
        _errorMessage = 'No user signed in.';
        _isLoading = false;
      });
      return;
    }

    final uid = _currentUser!.uid;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (!doc.exists) {
        setState(() {
          _errorMessage = 'User record not found in database.';
          _isLoading = false;
        });
        return;
      }
      setState(() {
        _userDoc = doc;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Your Profile',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.amber,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            )
          : _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    final data = _userDoc!.data()!;
    final displayName = data['displayName'] as String? ?? 'No name';
    final email = data['email'] as String? ?? 'No email';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Name:\n$displayName',
            style: const TextStyle(color: Colors.amber, fontSize: 20),
          ),
          const SizedBox(height: 12),
          Text(
            'Email:\n$email',
            style: const TextStyle(color: Colors.amber, fontSize: 20),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: _logout,
            child: const Text('Log Out', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
