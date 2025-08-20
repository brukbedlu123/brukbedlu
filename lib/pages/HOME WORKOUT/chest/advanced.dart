import 'package:etsport/pages/HOME%20WORKOUT/chest/beginner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:etsport/widgets/gender.dart';

class Advancedchest extends StatelessWidget {
  const Advancedchest({super.key});

  @override
  Widget build(BuildContext context) {
    final gender = Provider.of<GenderProvider>(context).selectedGender;

    final backgroundimage = gender == 'female'
        ? 'images/home workout/girl/chest.webp'
        : 'images/home workout/boy/chest.webp';

    return ReusableWorkoutPage(
      title: 'Advanced chest',
      subtitle: '15 mins - 9 Workouts',
      backgroundImage: backgroundimage,
      workouts: [
        // Day 1 — Chest

        {
          'name': 'Jumping Jacks',
          'image': 'images/workouts/jumping-jack.gif',
          'sec': '30 sec'
        },
        // 6 from Intermediate Chest
        {
          'name': 'Standard Push-Ups',
          'image': 'images/workouts/push-up.gif',
          'rep': '15'
        },
        {
          'name': 'Wide Push-Ups',
          'image': 'images/workouts/wide-push-up.gif',
          'rep': '12'
        },
        {
          'name': 'Incline Push-Ups',
          'image': 'images/workouts/incline-push-up.gif',
          'rep': '15'
        },
        {
          'name': 'Decline Push-Ups',
          'image': 'images/workouts/decline-push-up.gif',
          'rep': '12'
        },
        {
          'name': 'Diamond Push-Ups',
          'image': 'images/workouts/diamond-push-up.gif',
          'rep': '12'
        },
        {
          'name': 'Pseudo Push-ups (lean)',
          'image': 'images/workouts/pseudo-planche-push-up.gif',
          'sec': '60 sec hold'
        }, // Adjusted
        // 2 new advanced
        {
          'name': 'Clapping Push-Ups',
          'image': 'images/workouts/Clapping Push-Ups.gif',
          'rep': '12'
        }, // Adjusted for Advanced
        {
          'name': 'Archer Push-Ups',
          'image': 'images/workouts/archer-push-up.gif',
          'rep': '10 each side'
        },
      ],
    );
  }
}
