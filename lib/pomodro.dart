import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Focus keeper',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  int workDuration = 25 * 60;
  int breakDuration = 5 * 60;

  late int currentDuration;
  bool isRunning = false;
  late Timer timer;

  late AnimationController controller;

  late Animation<int> animation;

  @override
  void initState() {
    super.initState();
    currentDuration = workDuration;

    controller = AnimationController(
        vsync: this,
        duration: Duration(
          seconds: currentDuration,
        ));
    animation = IntTween(begin: currentDuration, end: 0).animate(controller);
  }

  void startTimer() {
    controller.duration = Duration(seconds: currentDuration);

    controller.reset();

    controller.forward();

    timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        if (currentDuration > 0) {
          currentDuration--;
        } else {
          if (isRunning) {
            currentDuration = breakDuration;
          } else {
            currentDuration = workDuration;
          }
          isRunning = !isRunning;

          controller.duration = Duration(seconds: currentDuration);
          controller.reset();
          controller.forward();
        }
      });
    });
  }

  void pauseTimer() {
    timer.cancel();
    controller.stop();
  }

  void resetTimer() {
    if (timer != null) {
      timer.cancel();
    }
    setState(() {
      isRunning = false;
      currentDuration = workDuration;
    });
    controller.stop();
  }

  @override
  Widget build(BuildContext context) {
    String minutes = (currentDuration ~/ 60).toString().padLeft(2, '0');
    String seconds = (currentDuration * 60).toString().padLeft(2, '0');
    return Scaffold(
      appBar: AppBar(
        title: Text('Focus Keeper'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  String animatedMinutes =
                      (animation.value ~/ 60).toString().padLeft(2, '0');
                  String animatedSeconds =
                      (animation.value * 60).toString().padLeft(2, '0');
                  return Text(
                    '$animatedMinutes: $animatedSeconds',
                    style: TextStyle(fontSize: 40),
                  );
                }),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: startTimer, child: Text("Start")),
                ElevatedButton(onPressed: pauseTimer, child: Text("Pause")),
                ElevatedButton(onPressed: resetTimer, child: Text("Reset"))
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  void disposed() {
    controller.dispose();
    super.dispose();
  }
}
