import 'package:etsport/pages/HOME%20WORKOUT/chest/beginner.dart'; // Assuming ReusableWorkoutPage is here
import 'package:flutter/material.dart';

class ButtWorkout extends StatelessWidget {
  const ButtWorkout({super.key});

  @override
  Widget build(BuildContext context) {
    return const ReusableWorkoutPage(
      title: 'Butt Workout',
      subtitle: '10 mins - 7 Workouts', // Updated time and workout count
      backgroundImage:
          'images/discovery/butt workout.webp', // Placeholder for a more relevant image
      workouts: [
        {
          'name': 'Jumping Jacks',
          'image': 'images/workouts/jumping-jack.gif',
          'sec': '30 sec'
        },
        {
          'name': 'Squats',
          'image': 'images/workouts/gsquats.gif', // Placeholder for a squat GIF
          'rep': '15'
        },
        {
          'name': 'Glute Bridges',
          'image':
              'images/workouts/gglute_bridge.gif', // Placeholder for a glute bridge GIF
          'rep': '20'
        },
        {
          'name': 'Reverse Lunge Knee (each leg)',
          'image':
              'images/workouts/Reverse-Lunge-Knee.gif', // Placeholder for a lunge GIF
          'rep': '10'
        },
        {
          'name': 'Donkey Kicks (each leg)',
          'image':
              'images/workouts/gdonkey_kicks.gif', // Placeholder for a donkey kick GIF
          'rep': '15'
        },
        {
          'name': 'Side Lunges (each side)',
          'image':
              'images/workouts/gside_lunges.gif', // Placeholder for a side lunge GIF
          'rep': '12'
        },
        {
          'name': 'Cossack Squat',
          'image':
              'images/workouts/Cossack-Squat.gif', // Placeholder for a wall sit GIF
          'sec': '45 sec'
        },
        {
          'name': 'Wall Sit',
          'image':
              'images/workouts/wall-sit.webp', // Placeholder for a wall sit GIF
          'sec': '45 sec'
        },
      ],
    );
  }
}
    /*'workouts': [
      {
        'name': 'Jumping Jacks',
        'image':
            'https://fitnessprogramer.com/wp-content/uploads/2021/05/Jumping-jack.gif',
        'sec': '30',
      },
      {
        'name': 'Partner Squats',
        'image':
            'https://fitnessprogramer.com/wp-content/uploads/2023/01/Dumbbell-Goblet-Squat.gif',
        'rep': '10',
      },
      {
        'name': 'Glute Bridges',
        'image':
            'https://i.pinimg.com/originals/06/24/b5/0624b5b7f2b9cf39108199399e671611.gif',
        'rep': '20',
      },
      {
        'name': 'Reverse Lunge',
        'image':
            'https://fitnessprogramer.com/wp-content/uploads/2022/08/bodyweight-reverse-lunge.gif',
        'rep': '10',
      },
      {
        'name': 'Push Up',
        'image':
            'https://i.pinimg.com/originals/1e/ad/ad/1eadad644c80735ffc1cd62f07d216dc.gif',
        'rep': '10',
      },
      {
        'name': 'Crunches',
        'image':
            'https://fitnessprogramer.com/wp-content/uploads/2015/11/Crunch.gif',
        'rep': '12',
      },
      {
        'name': 'Wall Sit',
        'image':
            'https://fitnessprogramer.com/wp-content/uploads/2021/06/Wall-Sit.png',
        'sec': '45',
      },
    ],*/