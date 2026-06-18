part of '../main.dart';

class GameHeader extends StatelessWidget {
  final int currentRound;
  final int totalRound;
  final int remainingSeconds;

  const GameHeader({
    super.key,
    required this.currentRound,
    required this.totalRound,
    required this.remainingSeconds,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatusBox(
            title: '라운드',
            value: '$currentRound / $totalRound',
            icon: Icons.flag,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatusBox(
            title: '남은 시간',
            value: '$remainingSeconds초',
            icon: Icons.timer,
          ),
        ),
      ],
    );
  }
}