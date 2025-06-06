import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  static const String routeName = '/profile';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    // If you store biometric setting in Firestore, fetch it here.
    // Otherwise leave _biometricEnabled=false by default.
  }

  /// Utility: safely read a String field from a DocumentSnapshot.
  String _getStringField(
    DocumentSnapshot doc,
    String key,
    String defaultValue,
  ) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    if (data.containsKey(key) && data[key] is String) {
      return data[key] as String;
    }
    return defaultValue;
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _toggleBiometric(bool newVal) {
    setState(() {
      _biometricEnabled = newVal;
      // TODO: Persist this in Firestore or Secure Storage if you need.
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      // If somehow no user is signed-in, redirect to login.
      Future.microtask(
        () => Navigator.of(context).pushReplacementNamed('/login'),
      );
      return const Scaffold(
        backgroundColor: Color(0xFF0D0D0D),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFF6C141)),
        ),
      );
    }

    final uid = currentUser.uid;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.menu, color: Color(0xFFF6C141)),
        ),
        centerTitle: true,
        title: const Text(
          'NyroWallet',
          style: TextStyle(
            color: Color(0xFFF6C141),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(0, 2),
                blurRadius: 4,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_none, color: Color(0xFFF6C141)),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('users').doc(uid).snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.hasError) {
            return _buildErrorState('Error loading profile.');
          }
          if (!userSnapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFF6C141)),
            );
          }

          final userDoc = userSnapshot.data!;
          final rawNameFromFirestore = _getStringField(
            userDoc,
            'name',
            '',
          ).trim();
          final displayName = rawNameFromFirestore.isNotEmpty
              ? rawNameFromFirestore
              : (currentUser.displayName?.trim().isNotEmpty == true
                    ? currentUser.displayName!
                    : (currentUser.email ?? 'Unknown User'));
          final email = currentUser.email ?? '—';

          return ListView(
            children: [
              const SizedBox(height: 24),

              // ===== User Header =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6C141),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // TODO: If you want an “Edit Profile” flow, push that here
                      },
                      child: const Icon(
                        Icons.edit,
                        color: Color(0xFFF6C141),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Divider(color: Colors.white24, thickness: 1),
              const SizedBox(height: 16),

              // ===== Wallet & Accounts Section =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Wallet & Accounts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // List the user’s cards from Firestore subcollection
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .doc(uid)
                    .collection('cards')
                    .orderBy('nickname')
                    .snapshots(),
                builder: (context, cardsSnapshot) {
                  if (cardsSnapshot.hasError) {
                    return _buildErrorState('Error loading cards.');
                  }
                  if (!cardsSnapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFF6C141),
                      ),
                    );
                  }

                  final cardDocs = cardsSnapshot.data!.docs;
                  if (cardDocs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: Text(
                        'No cards/accounts added yet.',
                        style: TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                    );
                  }

                  return ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                    itemCount: cardDocs.length,
                    itemBuilder: (context, index) {
                      final doc = cardDocs[index];
                      final data = doc.data()! as Map<String, dynamic>;

                      // Safely read card fields (fallback to empty string)
                      final fullNumber = (data['number'] as String?) ?? '';
                      final last4 = fullNumber.length >= 4
                          ? fullNumber.substring(fullNumber.length - 4)
                          : fullNumber;
                      final expiry = (data['expiry'] as String?) ?? '';
                      final type = (data['type'] as String?) ?? '';
                      final nickname = (data['nickname'] as String?) ?? '';

                      // Pick an icon placeholder based on type
                      IconData cardIcon;
                      switch (type.toLowerCase()) {
                        case 'visa':
                          cardIcon = Icons.credit_card;
                          break;
                        case 'mastercard':
                          cardIcon = Icons.payment;
                          break;
                        case 'amex':
                          cardIcon = Icons.credit_score;
                          break;
                        default:
                          cardIcon = Icons.credit_card;
                      }

                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1C1C),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: Icon(
                            cardIcon,
                            size: 28,
                            color: const Color(0xFFF6C141),
                          ),
                          title: Text(
                            '•••• •••• •••• $last4',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            nickname.isNotEmpty
                                ? '$nickname • Exp: $expiry'
                                : 'Exp: $expiry',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          trailing: GestureDetector(
                            onTap: () {
                              Navigator.of(
                                context,
                              ).pushNamed('/edit_card', arguments: doc.id);
                            },
                            child: const Icon(
                              Icons.chevron_right,
                              color: Color(0xFFF6C141),
                              size: 28,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

              // “Add Card/Account” button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed('/add_card');
                  },
                  child: Row(
                    children: const [
                      Icon(Icons.add_circle_outline, color: Color(0xFFF6C141)),
                      SizedBox(width: 8),
                      Text(
                        'Add Card/Account',
                        style: TextStyle(
                          color: Color(0xFFF6C141),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(color: Colors.white24, thickness: 1),
              const SizedBox(height: 16),

              // ===== Security Section =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Security',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Change Password
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed('/change_password');
                  },
                  child: Row(
                    children: const [
                      Icon(Icons.lock_outline, color: Color(0xFFF6C141)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Change Password',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Color(0xFFF6C141)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Biometric Login Toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.fingerprint, color: Color(0xFFF6C141)),
                        SizedBox(width: 12),
                        Text(
                          'Biometric Login',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                    Switch(
                      value: _biometricEnabled,
                      activeColor: const Color(0xFFF6C141),
                      onChanged: (val) => _toggleBiometric(val),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Divider(color: Colors.white24, thickness: 1),
              const SizedBox(height: 16),

              // ===== Notifications Section (optional) =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Notifications',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Toggle Push Notifications (UI only)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Push Notifications',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Switch(
                      value: true, // If you store this, bind it here
                      activeColor: const Color(0xFFF6C141),
                      onChanged: (val) {
                        // TODO: Handle push notification toggle
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ===== Log Out Button =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ElevatedButton(
                  onPressed: _signOut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.shade700,
                    elevation: 6,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Log Out',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Text(message, style: const TextStyle(color: Colors.redAccent)),
    );
  }
}
