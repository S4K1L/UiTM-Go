import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPress;
  final String title;

  const CustomButton({
    super.key,
    required this.onPress,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width / 2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: Colors.white,
        ),
        child: TextButton(
          onPressed: onPress,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
