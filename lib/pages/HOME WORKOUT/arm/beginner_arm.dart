import 'package:etsport/pages/HOME%20WORKOUT/chest/beginner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:etsport/widgets/gender.dart';

class beginner_armworkout extends StatelessWidget {
  const beginner_armworkout({super.key});

  @override
  Widget build(BuildContext context) {
    final gender = Provider.of<GenderProvider>(context).selectedGender;

    final backgroundimage = gender == 'female'
        ? 'images/home workout/girl/arm.webp'
        : 'images/home workout/boy/arm.webp';

    return ReusableWorkoutPage(
      title: 'Beginner Arm',
      subtitle: '7 mins - 5 Workouts',
      backgroundImage: backgroundimage,
      workouts: [
        {
          'name': 'Jumping Jacks',
          'image': 'images/workouts/jumping-jack.gif',
          'sec': '30 sec'
        },
        {
          'name': 'Wall Push-Ups',
          'image': 'images/workouts/wall-push-up.gif',
          'rep': '5'
        },
        {
          'name': 'Triceps Dips (Chair)',
          'image': 'images/workouts/triceps-dips.gif',
          'rep': '8'
        }, // Adjusted
        {
          'name': 'Standard Push-Ups',
          'image': 'images/workouts/push-up.gif',
          'rep': '5'
        }, // Adjusted
        {
          'name': 'Arm Circles',
          'image': 'images/workouts/arm-circles.gif',
          'sec': '20 sec forward'
        }, // Adjusted
      ],
    );
  }
}
