import 'package:etsport/pages/HOME%20WORKOUT/chest/beginner.dart';
import 'package:etsport/widgets/gender.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class advanced_absworkout extends StatelessWidget {
  const advanced_absworkout({super.key});

  @override
  Widget build(BuildContext context) {
    final gender = Provider.of<GenderProvider>(context).selectedGender;

    final backgroundimage = gender == 'female'
        ? 'images/home workout/girl/abs.webp'
        : 'images/home workout/boy/abs.webp';

    return ReusableWorkoutPage(
      title: 'Advanced ABS',
      subtitle: '15 mins - 9 Workouts',
      backgroundImage: backgroundimage, // A different background image
      workouts: const [
        {
          'name': 'Jumping Jacks',
          'image': 'images/workouts/jumping-jack.gif',
          'sec': '30 sec'
        },
        // 6 from Intermediate Abs
        {
          'name': 'Crunches',
          'image': 'images/workouts/crunches.gif',
          'rep': '25'
        }, // Adjusted
        {
          'name': 'Cross Crunch',
          'image': 'images/workouts/Cross Crunch.gif',
          'rep': '20'
        }, // Adjusted
        {
          'name': 'Side Plank Right',
          'image': 'images/workouts/side-plank.gif',
          'sec': '45 sec'
        }, // Adjusted
        {
          'name': 'Side Plank Left',
          'image': 'images/workouts/side-plank.gif',
          'sec': '45 sec'
        },
        {
          'name': 'Russian Twists (faster)',
          'image': 'images/workouts/russian-twists.gif',
          'rep': '25'
        }, // Adjusted

        {
          'name': 'Plank',
          'image': 'images/workouts/plank.gif',
          'sec': '90 sec'
        }, // Adjusted
        // 2 new advanced
        {
          'name': 'Tuck Crunch',
          'image': 'images/workouts/Tuck-Crunch.gif',
          'rep': '15'
        },
        {
          'name': 'Hollow Body Hold',
          'image': 'images/workouts/hollow hold.jpg',
          'sec': '45 sec'
        },
      ],
    );
  }
}
