import 'package:flutter/material.dart';

class VipCard extends StatelessWidget {
  const VipCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xffF4D03F), Color(0xffF39C12)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.workspace_premium, color: Colors.black),
              SizedBox(width: 8),
              Text(
                'VIP ACCOUNT',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          const Text(
            'Become a VIP Member',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          const Benefit('Ads Free'),
          Benefit('Exclusive Drama'),
          Benefit('Anything Streaming'),
          Benefit('Unlimited Viewing'),
          Benefit('Personal Content'),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('Upgrade Now'),
            ),
          ),
        ],
      ),
    );
  }
}

class Benefit extends StatelessWidget {
  final String text;

  const Benefit(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.black87, size: 18),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}
