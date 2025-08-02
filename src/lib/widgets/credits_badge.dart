import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

/// CreditsBadge
/// -------------
/// Lightweight widget that listens to `/users/{uid}` document and displays
/// the current `credits_left` and daily `streak` counters. Intended for use
/// inside an AppBar `actions` slot.
class CreditsBadge extends StatefulWidget {
  const CreditsBadge({super.key});

  @override
  State<CreditsBadge> createState() => _CreditsBadgeState();
}

class _CreditsBadgeState extends State<CreditsBadge> {
  int _prevStreak = 0;
  final _confettiController = ConfettiController(duration: const Duration(seconds: 2));

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    final docStream = FirebaseFirestore.instance.collection('users').doc(uid).snapshots();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: docStream,
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final credits = data?['credits_left'] ?? 0;
        final streak = data?['streak'] ?? 0;

        // Trigger confetti if streak increased.
        if (streak > _prevStreak) {
          _confettiController.play();
          _prevStreak = streak;
        }

        return Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_balance_wallet_outlined, size: 18),
                const SizedBox(width: 4),
                Text('$credits'),
                const SizedBox(width: 12),
                const Icon(Icons.local_fire_department_outlined, size: 18, color: Colors.orange),
                const SizedBox(width: 4),
                Text('$streak'),
              ],
            ),
            // Confetti blasts upwards from badge center
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: -1.55, // up
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.orange, Colors.red, Colors.yellow],
              emissionFrequency: 0.2,
              numberOfParticles: 20,
              maxBlastForce: 8,
              minBlastForce: 5,
            ),
          ],
        );
      },
    );
  }
}
