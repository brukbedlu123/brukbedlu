import 'package:etsport/pages/HOME%20WORKOUT/chest/beginner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:etsport/widgets/gender.dart';

class intermediate_absworkout extends StatelessWidget {
  const intermediate_absworkout({super.key});

  @override
  Widget build(BuildContext context) {
    final gender = Provider.of<GenderProvider>(context).selectedGender;

    final backgroundimage = gender == 'female'
        ? 'images/home workout/girl/abs.webp'
        : 'images/home workout/boy/abs.webp';

    return ReusableWorkoutPage(
      title: 'Intermediate ABS',
      subtitle: '45 mins - 20 Workouts',
      backgroundImage: backgroundimage,
      workouts: [
        {
          'name': 'Jumping Jacks',
          'image': 'images/workouts/jumping-jack.gif',
          'sec': '30 sec'
        },
        // 4 from Beginner Abs
        {
          'name': 'Crunches',
          'image': 'images/workouts/crunches.gif',
          'rep': '20'
        }, // Adjusted
        {
          'name': 'Cross Crunch',
          'image': 'images/workouts/Cross Crunch.gif',
          'rep': '20'
        }, // Adjusted
        {
          'name': 'Russian Twists',
          'image': 'images/workouts/russian-twists.gif',
          'rep': '20'
        }, // Adjusted
        {
          'name': 'Side Plank Right',
          'image': 'images/workouts/side-plank.gif',
          'sec': '15 sec'
        }, // Adjusted
        // 2 new intermediate
        {
          'name': 'Side Plank Left',
          'image': 'images/workouts/side-plank.gif',
          'sec': '15 sec'
        }, // Adjusted
        {
          'name': 'Plank',
          'image': 'images/workouts/plank.gif',
          'sec': '20 sec'
        }, // Adjusted
      ],
    );
  }
}
