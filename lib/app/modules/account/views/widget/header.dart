import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.white12,
          child: Icon(
            Icons.person,
            size: 32,
            color: Colors.white,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Guest',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              SizedBox(height: 4),

              Text(
                'ID : DMN284719',
                style: TextStyle(
                  color: Colors.white54,
                ),
              ),

              SizedBox(height: 4),

              Text(
                'Login >',
                style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications_none,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}