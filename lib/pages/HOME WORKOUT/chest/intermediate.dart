import 'package:etsport/pages/HOME%20WORKOUT/chest/beginner.dart';
import 'package:etsport/widgets/gender.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class intermediate extends StatelessWidget {
  const intermediate({super.key});

  @override
  Widget build(BuildContext context) {
    final gender = Provider.of<GenderProvider>(context).selectedGender;

    final backgroundimage = gender == 'female'
        ? 'images/home workout/girl/chest.webp'
        : 'images/home workout/boy/chest.webp';

    return ReusableWorkoutPage(
      title: 'Intermidate chest',
      subtitle: '10 mins - 7 Workouts',
      backgroundImage: backgroundimage, // A different background image
      workouts: const [
        {
          'name': 'Jumping Jacks',
          'image': 'images/workouts/jumping-jack.gif',
          'sec': '30 sec'
        },
        // 4 from Beginner Chest
        {
          'name': 'Standard Push-Ups',
          'image': 'images/workouts/push-up.gif',
          'rep': '5'
        },
        {
          'name': 'Archer Push-Ups',
          'image': 'images/workouts/archer-push-up.gif',
          'rep': '8 each side'
        },
        {
          'name': 'Incline Push-Ups',
          'image': 'images/workouts/incline-push-up.gif',
          'rep': '10'
        },
        {
          'name': 'Diamond Push-Ups',
          'image': 'images/workouts/diamond-push-up.gif',
          'rep': '8'
        }, // Adjusted
        // 2 new intermediate
        {
          'name': 'Wide Push-Ups',
          'image': 'images/workouts/wide-push-up.gif',
          'rep': '8'
        },
        {
          'name': 'Decline Push-Ups',
          'image': 'images/workouts/decline-push-up.gif',
          'rep': '6'
        },
      ],
    );
  }
}
