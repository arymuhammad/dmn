import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // const Icon(Icons.play_circle_fill, color: Colors.red, size: 28),
          Container(
            height: 35,
            width: 35,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/icon/icon.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 8),

          const Text(
            'DMN Play',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),

          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: Colors.white),
          ),

          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
