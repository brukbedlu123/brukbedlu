import 'package:etsport/pages/HOME%20WORKOUT/chest/beginner.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:etsport/widgets/gender.dart';

class beginner_legworkout extends StatelessWidget {
  const beginner_legworkout({super.key});

  @override
  Widget build(BuildContext context) {
    final gender = Provider.of<GenderProvider>(context).selectedGender;

    final backgroundimage = gender == 'female'
        ? 'images/home workout/girl/leg.webp'
        : 'images/home workout/boy/leg.webp';

    return ReusableWorkoutPage(
      title: 'Beginner Leg',
      subtitle: '7 mins - 5 Workouts',
      backgroundImage: backgroundimage,
      workouts: [
        {
          'name': 'Jumping Jacks',
          'image': 'images/workouts/jumping-jack.gif',
          'sec': '30 sec'
        },
        {
          'name': 'Squats',
          'image': 'images/workouts/squats.gif',
          'rep': '15'
        }, // Adjusted
        {
          'name': 'Lunges (alternating)',
          'image': 'images/workouts/lunges.gif',
          'rep': '8 each leg'
        }, // Adjusted
        {
          'name': 'Wall Sit',
          'image': 'images/workouts/wall-sit.webp',
          'sec': '30 sec'
        }, // Adjusted for Beginner
        {
          'name': 'Calf Raises',
          'image': 'images/workouts/calf-raises.gif',
          'rep': '20'
        }, // Adjusted
      ],
    );
  }
}
