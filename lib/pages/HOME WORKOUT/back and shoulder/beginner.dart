import 'package:etsport/pages/HOME%20WORKOUT/chest/beginner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:etsport/widgets/gender.dart';

class beginnerbackandshoulder extends StatelessWidget {
  const beginnerbackandshoulder({super.key});

  @override
  Widget build(BuildContext context) {
    final gender = Provider.of<GenderProvider>(context).selectedGender;

    final backgroundimage = gender == 'female'
        ? 'images/home workout/girl/back and shoulder.webp'
        : 'images/home workout/boy/back and shoulder.webp';

    return ReusableWorkoutPage(
      title: 'Beg Back and Shoulder',
      subtitle: '7 mins - 5 Workouts',
      backgroundImage: backgroundimage,
      workouts: [
        {
          'name': 'Jumping Jacks',
          'image': 'images/workouts/jumping-jack.gif',
          'sec': '30 sec'
        },
        {
          'name': 'Decline Push-Ups',
          'image': 'images/workouts/decline-push-up.gif',
          'rep': '6'
        }, // Adjusted
        {
          'name': 'Wall Push-up',
          'image': 'images/workouts/wall-push-up.gif',
          'rep': '10'
        }, // Adjusted
        {
          'name': 'Wide Push-Ups',
          'image': 'images/workouts/wide-push-up.gif',
          'rep': '6'
        }, // Adjusted
        {
          'name': 'Pike Push-ups (modified)',
          'image': 'images/workouts/pike-push-up.gif',
          'rep': '5'
        },
      ],
    );
  }
}
