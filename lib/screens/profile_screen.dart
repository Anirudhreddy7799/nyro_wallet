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

  bool _biometricEnabled = false;
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  String _language = 'English';

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

  Stream<List<CardModel>> _cardsStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('cards')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => CardModel.fromDoc(doc)).toList();
        });
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

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.amber,
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.black, fontSize: 24),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(color: Colors.amber, fontSize: 20),
                ),
                Text(
                  email,
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          ],
        ),
        const Divider(color: Colors.grey),
        const SizedBox(height: 12),
        Text(
          'Wallet & Accounts',
          style: const TextStyle(color: Colors.amber, fontSize: 18),
        ),
        StreamBuilder<List<CardModel>>(
          stream: _cardsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final cards = snapshot.data ?? [];
            return Column(
              children: cards
                  .map(
                    (card) => ListTile(
                      title: Text(
                        '•••• ${card.last4}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        card.type,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.add_circle_outline, color: Colors.amber),
          title: const Text(
            'Add Card/Account',
            style: TextStyle(color: Colors.amber),
          ),
          onTap: () {
            // TODO: Navigate to Add Card/Account screen
          },
        ),
        const Divider(color: Colors.grey),
        Text(
          'Preferences',
          style: const TextStyle(color: Colors.amber, fontSize: 18),
        ),
        SwitchListTile(
          value: _darkMode,
          onChanged: (value) {
            setState(() => _darkMode = value);
          },
          title: const Text('Dark Mode', style: TextStyle(color: Colors.amber)),
        ),
        ListTile(
          leading: const Icon(Icons.language, color: Colors.amber),
          title: const Text('Language', style: TextStyle(color: Colors.amber)),
          subtitle: Text(_language, style: const TextStyle(color: Colors.grey)),
          onTap: () {
            // TODO: Show language selection dialog
          },
        ),
        const Divider(color: Colors.grey),
        Text(
          'Security',
          style: const TextStyle(color: Colors.amber, fontSize: 18),
        ),
        SwitchListTile(
          value: _biometricEnabled,
          onChanged: (value) {
            setState(() => _biometricEnabled = value);
          },
          title: const Text(
            'Biometric Login',
            style: TextStyle(color: Colors.amber),
          ),
        ),
        SwitchListTile(
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() => _notificationsEnabled = value);
          },
          title: const Text(
            'App Notifications',
            style: TextStyle(color: Colors.amber),
          ),
        ),
        const Divider(color: Colors.grey),
        Text(
          'Support & About',
          style: const TextStyle(color: Colors.amber, fontSize: 18),
        ),
        ListTile(
          leading: const Icon(Icons.policy, color: Colors.amber),
          title: const Text(
            'Privacy Policy',
            style: TextStyle(color: Colors.amber),
          ),
          onTap: () {
            // TODO: Open Privacy Policy
          },
        ),
        ListTile(
          leading: const Icon(Icons.description, color: Colors.amber),
          title: const Text(
            'Terms of Service',
            style: TextStyle(color: Colors.amber),
          ),
          onTap: () {
            // TODO: Open Terms of Service
          },
        ),
        ListTile(
          leading: const Icon(Icons.info_outline, color: Colors.amber),
          title: const Text(
            'About Nyro Wallet',
            style: TextStyle(color: Colors.amber),
          ),
          subtitle: const Text(
            'Version 1.0.0',
            style: TextStyle(color: Colors.grey),
          ),
          onTap: () {
            // TODO: Show About dialog
          },
        ),
        const Divider(color: Colors.grey),
        ListTile(
          title: const Text(
            'Help & Support',
            style: TextStyle(color: Colors.amber),
          ),
          onTap: () {},
        ),
        ElevatedButton(
          onPressed: _logout,
          child: const Text('Log Out', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}

class CardModel {
  final String id;
  final String last4;
  final String type;
  final String expiry;
  final String nickname;

  CardModel({
    required this.id,
    required this.last4,
    required this.type,
    required this.expiry,
    required this.nickname,
  });

  factory CardModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CardModel(
      id: doc.id,
      last4: data['last4'] ?? '0000',
      type: data['type'] ?? 'Unknown',
      expiry: data['expiry'] ?? '',
      nickname: data['nickname'] ?? '',
    );
  }
}
