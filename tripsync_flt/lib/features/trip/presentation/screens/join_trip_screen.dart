import 'package:flutter/material.dart';
import '../widgets/joinTrip/join_trip_header.dart';
import '../widgets/joinTrip/invite_code_input.dart';
import '../widgets/joinTrip/join_trip_actions.dart';

class JoinTripScreen extends StatefulWidget {
  const JoinTripScreen({super.key});

  @override
  State<JoinTripScreen> createState() => _JoinTripScreenState();
}

class _JoinTripScreenState extends State<JoinTripScreen> {
  final TextEditingController _inviteCodeController = TextEditingController();

  @override
  void dispose() {
    _inviteCodeController.dispose();
    super.dispose();
  }

  void _handleJoin() {
    final inviteCode = _inviteCodeController.text.trim();
    if (inviteCode.isNotEmpty) {
      // TODO: Implement join trip logic
      Navigator.of(context).pop(inviteCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width - 24,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: const SizedBox(
                  width: 32,
                  height: 32,
                  child: Icon(Icons.close, size: 24),
                ),
              ),
              const SizedBox(height: 30),

              const JoinTripHeader(),
              const SizedBox(height: 30),

              InviteCodeInput(controller: _inviteCodeController),
              const SizedBox(height: 30),

              JoinTripActions(
                onCancel: () => Navigator.of(context).pop(),
                onJoin: _handleJoin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showJoinTripDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (context) => const JoinTripScreen(),
  );
}
