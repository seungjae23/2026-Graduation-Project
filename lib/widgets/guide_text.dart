part of '../main.dart';

class _GuideText extends StatelessWidget {
  final String text;

  const _GuideText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: Color(0xFF6C63FF), size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Color(0xFF77778A)),
          ),
        ),
      ],
    );
  }
}