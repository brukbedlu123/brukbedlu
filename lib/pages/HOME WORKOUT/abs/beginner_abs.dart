import 'package:etsport/pages/HOME%20WORKOUT/chest/beginner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:etsport/widgets/gender.dart';

class beginner_absworkout extends StatelessWidget {
  const beginner_absworkout({super.key});

  @override
  Widget build(BuildContext context) {
    final gender = Provider.of<GenderProvider>(context).selectedGender;

    final backgroundimage = gender == 'female'
        ? 'images/home workout/girl/abs.webp'
        : 'images/home workout/boy/abs.webp';

    return ReusableWorkoutPage(
      title: 'Beginner ABS',
      subtitle: '7 mins - 5 Workouts',
      backgroundImage: backgroundimage,
      workouts: [
        {
          'name': 'Jumping Jacks',
          'image': 'images/workouts/jumping-jack.gif',
          'sec': '30 sec'
        },
        {
          'name': 'Crunches',
          'image': 'images/workouts/crunches.gif',
          'rep': '15'
        }, // Adjusted
        {
          'name': 'Cross Crunch',
          'image': 'images/workouts/Cross Crunch.gif',
          'rep': '20'
        },
        {
          'name': 'Russian Twists',
          'image': 'images/workouts/russian-twists.gif',
          'rep': '15'
        }, // Adjusted
        {
          'name': 'Plank',
          'image': 'images/workouts/plank.gif',
          'sec': '45 sec'
        }, // Adjusted for Beginner
      ],
    );
  }
}
