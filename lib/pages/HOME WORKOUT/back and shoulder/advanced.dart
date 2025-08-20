import 'package:etsport/pages/HOME%20WORKOUT/chest/beginner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:etsport/widgets/gender.dart';

class Advancedbackandshoulder extends StatelessWidget {
  const Advancedbackandshoulder({super.key});

  @override
  Widget build(BuildContext context) {
    final gender = Provider.of<GenderProvider>(context).selectedGender;

    final backgroundimage = gender == 'female'
        ? 'images/home workout/girl/back and shoulder.webp'
        : 'images/home workout/boy/back and shoulder.webp';

    return ReusableWorkoutPage(
      title: 'Adv Back and Shoulder',
      subtitle: '15 mins - 9 Workouts',
      backgroundImage: backgroundimage,
      workouts: [
        {
          'name': 'Jumping Jacks',
          'image': 'images/workouts/jumping-jack.gif',
          'sec': '30 sec'
        },
        {
          'name': 'Standard Push-Ups',
          'image': 'images/workouts/push-up.gif',
          'rep': '20 '
        }, // Adjusted
        {
          'name': 'Pike Push-ups',
          'image': 'images/workouts/pike-push-up.gif',
          'rep': '20'
        },
        {
          'name': 'Wide Push-Ups',
          'image': 'images/workouts/wide-push-up.gif',
          'rep': '15'
        }, // Adjusted
        // Adjusted
        // 2 new intermediate
        {
          'name': 'Hindu Push-up',
          'image': 'images/workouts/Modified-Hindu-Push-up.gif',
          'rep': 'x 15'
        }, // Adjusted

        {
          'name': 'Pike Push-ups',
          'image': 'images/workouts/pike-push-up.gif',
          'rep': '25'
        },
        {
          'name': 'Handstand Push-ups (wall assisted)',
          'image': 'images/workouts/handstand-push-up.gif',
          'rep': '8'
        },
        {
          'name': 'Lean Planche',
          'image': 'images/workouts/lean-planche.png',
          'rep': '25'
        }, // Adjusted
      ],
    );
  }
}
