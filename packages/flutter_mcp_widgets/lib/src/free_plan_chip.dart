import 'package:flutter/material.dart';

class FreePlanChip extends StatelessWidget {
  const FreePlanChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: Color(0xFF141414), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Text(
            'Free plan',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w100, fontSize: 13.5),
          ),
          SizedBox(width: 8),
          CircleAvatar(radius: 1.5, backgroundColor: Colors.white24),
          SizedBox(width: 8),
          Text('Upgrade',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w300, fontSize: 13.5))
        ],
      ),
    );
  }
}
