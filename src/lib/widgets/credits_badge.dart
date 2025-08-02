import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// CreditsBadge
/// -------------
/// Lightweight widget that listens to `/users/{uid}` document and displays
/// the current `credits_left` and daily `streak` counters. Intended for use
/// inside an AppBar `actions` slot.
class CreditsBadge extends StatelessWidget {
  const CreditsBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    final docStream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: docStream,
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final credits = data?['credits_left'] ?? 0;
        final streak = data?['streak'] ?? 0;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_balance_wallet_outlined, size: 18),
            const SizedBox(width: 4),
            Text('$credits'),
            const SizedBox(width: 12),
            const Icon(Icons.local_fire_department_outlined, size: 18),
            const SizedBox(width: 4),
            Text('$streak'),
          ],
        );
      },
    );
  }
}
