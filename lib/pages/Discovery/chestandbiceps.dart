import 'package:etsport/pages/Discovery/quick_pump.dart';
import 'package:flutter/material.dart';

class Bicepsandchest extends StatelessWidget {
  const Bicepsandchest({super.key});

  @override
  Widget build(BuildContext context) {
    return const QuickPump(
      title: 'Chest & Biceps',
      subtitle: 'Strength & tone in 15 moves',
      backgroundImage: 'images/discovery/chest and biceps.webp',
      workoutsByType: {
        'Bodyweight': [
          {
            'name': 'Jumping Jacks',
            'image': 'images/workouts/jumping-jack.gif',
            'sec': '30 sec'
          },
          {
            'name': 'Push-Ups',
            'image': 'images/workouts/push-up.gif',
            'rep': '8'
          },
          {
            'name': 'Wide Push-Ups',
            'image': 'images/workouts/wide-push-up.gif',
            'rep': '6'
          },
          {
            'name': 'Diamond Push-Ups',
            'image': 'images/workouts/diamond-push-up.gif',
            'rep': '6'
          },
          {
            'name': 'Incline Push-Ups',
            'image': 'images/workouts/incline-push-up.gif',
            'rep': '8'
          },
          {
            'name': 'Decline Push-Ups',
            'image': 'images/workouts/decline-push-up.gif',
            'rep': '8'
          },
          {
            'name': 'Archer Push-Ups',
            'image': 'images/workouts/archer-push-up.gif',
            'rep': '6'
          },
          {
            'name': 'Pseudo Planche Push-Ups',
            'image': 'images/workouts/pseudo-planche-push-up.gif',
            'rep': '6'
          },
          {
            'name': 'Clapping Push-Ups',
            'image': 'images/workouts/Clapping Push-Ups.gif',
            'rep': '6'
          },
          {
            'name': 'Close-Grip Push-Ups',
            'image': 'images/workouts/push-up.gif',
            'rep': '6'
          },
          {
            'name': 'Wall Push-Ups',
            'image': 'images/workouts/wall-push-up.gif',
            'rep': '8'
          },
        ],
        'Dumbbells': [
          {
            'name': 'Jumping Jacks',
            'image': 'images/workouts/jumping-jack.gif',
            'sec': '30 sec'
          },
          {
            'name': 'Dumbbell Bench Press (Floor)',
            'image': 'images/workouts/db-bench-press.gif',
            'rep': '8'
          },
          {
            'name': 'Dumbbell Chest Fly ',
            'image': 'images/workouts/Dumbbell-Fly.gif',
            'rep': '6'
          },
          {
            'name': 'Close Grip',
            'image': 'images/workouts/Close-Grip-Dumbbell-Press.gif',
            'rep': '8'
          },
          {
            'name': 'Dumbbell Pullover',
            'image': 'images/workouts/db-pullover.gif',
            'rep': '6'
          },
          {
            'name': 'Dumbbell High Curlw',
            'image': 'images/workouts/Dumbbell-High-Curl.gif',
            'rep': '6'
          },
          {
            'name': 'Dumbbell Bicep Curl',
            'image': 'images/workouts/db-bicep-curl.gif',
            'rep': '8'
          },
          {
            'name': 'Hammer Curl',
            'image': 'images/workouts/hammer-curl.gif',
            'rep': '6'
          },
          {
            'name': 'Concentration Curl',
            'image': 'images/workouts/concentration-curl.gif',
            'rep': '6'
          },
          {
            'name': 'Dumbbell Bench Press',
            'image':
                'images/workouts/db-bench-press.gif', // Placeholder for Dumbbell Bench Press GIF
            'rep': '12'
          },
          {
            'name': 'Dumbbell Bicep Curls',
            'image':
                'images/workouts/db-bicep-curl.gif', // Placeholder for Dumbbell Bicep Curls GIF
            'rep': '12'
          },
          {
            'name': 'Dumbbell Shoulder Press',
            'image':
                'images/workouts/db-shoulder.gif', // Placeholder for Dumbbell Shoulder Press GIF
            'rep': '10'
          },
          {
            'name': 'Dumbbell Triceps Extension (Overhead)',
            'image':
                'images/workouts/db-triceps-ext.gif', // Placeholder for Dumbbell Triceps Extension GIF
            'rep': '10'
          },
          {
            'name': 'Dumbbell Bicep Curls',
            'image':
                'images/workouts/db-bicep-curl.gif', // Placeholder for Dumbbell Bicep Curls GIF
            'rep': '12'
          },
        ],
      },
    );
  }
}
