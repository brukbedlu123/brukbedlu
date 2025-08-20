import 'package:etsport/pages/HOME%20WORKOUT/chest/beginner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:etsport/widgets/gender.dart';

class intermediatebackandshoulder extends StatelessWidget {
  const intermediatebackandshoulder({super.key});

  @override
  Widget build(BuildContext context) {
    final gender = Provider.of<GenderProvider>(context).selectedGender;

    final backgroundimage = gender == 'female'
        ? 'images/home workout/girl/back and shoulder.webp'
        : 'images/home workout/boy/back and shoulder.webp';

    return ReusableWorkoutPage(
      title: 'Inter Back and Shoulder',
      subtitle: '10 mins - 7 Workouts',
      backgroundImage: backgroundimage,
      workouts: [
        {
          'name': 'Jumping Jacks',
          'image': 'images/workouts/jumping-jack.gif',
          'sec': '30 sec'
        },
        // 4 from Beginner Shoulders + Back
        {
          'name': 'Decline Push-Ups',
          'image': 'images/workouts/decline-push-up.gif',
          'rep': '12'
        }, // Adjusted
        {
          'name': 'Standard Push-Ups',
          'image': 'images/workouts/push-up.gif',
          'rep': '10 each side'
        }, // Adjusted
        {
          'name': 'Wide Push-Ups',
          'image': 'images/workouts/wide-push-up.gif',
          'rep': '15'
        }, // Adjusted
        {
          'name': 'Pike Push-ups (modified)',
          'image': 'images/workouts/pike-push-up.gif',
          'rep': '8'
        }, // Adjusted
        // 2 new intermediate
        {
          'name': 'Inclined Push ups',
          'image': 'images/workouts/incline-push-up.gif',
          'rep': '10'
        }, // Adjusted
        {
          'name': 'Lean Planche',
          'image': 'images/workouts/lean-planche.png',
          'rep': '20'
        }, // Adjusted
      ],
    );
  }
}
