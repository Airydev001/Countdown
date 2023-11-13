import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Days Countdown',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CountdownScreen(),
    );
  }
}

class CountdownScreen extends StatefulWidget {
  @override
  _CountdownScreenState createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen>
    with SingleTickerProviderStateMixin {
  DateTime? targetDate; // Updated target date

  late Duration remainingTime;
  int days = 0;
  int hours = 0;
  int minutes = 0;
  int seconds = 0;

  late Timer timer;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    pickTargetDate(); // Call pickTargetDate in initState
  }

  void pickTargetDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != targetDate) {
      setState(() {
        targetDate = pickedDate;
        calculateRemainingTime();
        startTimer();
      });
    }
  }

  void calculateRemainingTime() {
    DateTime now = DateTime.now();
    if (targetDate!.isAfter(now)) {
      remainingTime = targetDate!.difference(now);
      updateDigits();
    } else {
      remainingTime = Duration.zero;
    }
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingTime.inSeconds > 0) {
        setState(() {
          remainingTime = remainingTime - Duration(seconds: 1);
          updateDigits();
        });
      } else {
        timer.cancel();
      }
    });
  }

  void updateDigits() {
    days = remainingTime.inDays;
    hours = remainingTime.inHours % 24;
    minutes = remainingTime.inMinutes % 60;
    seconds = remainingTime.inSeconds % 60;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Days Countdown'),
      ),
      body: Center(
        child: Card(
          elevation: 5,
          margin: EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  targetDate != null
                      ? 'Countdown to ${targetDate!.year}-${targetDate!.month}-${targetDate!.day}'
                      : 'Select Target Date',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 20),
                targetDate != null
                    ? Flexible(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FlipDigit(value: days),
                            Text(' days '),
                            FlipDigit(value: hours),
                            Text(' hrs '),
                            FlipDigit(value: minutes),
                            Text(' mins '),
                            FlipDigit(value: seconds),
                            Text(' secs'),
                          ],
                        ),
                      )
                    : ElevatedButton(
                        onPressed: pickTargetDate,
                        child: Text('Pick Target Date'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    _controller.dispose();
    super.dispose();
  }
}

class FlipDigit extends StatelessWidget {
  final int value;

  FlipDigit({required this.value});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Text(
          value.toString().padLeft(2, '0'),
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        );
      },
    );
  }
}
