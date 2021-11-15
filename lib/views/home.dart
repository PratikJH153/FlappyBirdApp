import 'dart:async';

import 'package:flappybird/widgets/barrier.dart';
import 'package:flappybird/widgets/bird.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Bird Variables
  static double birdY = 0;
  double initialPos = birdY;
  double height = 0;
  double time = 0;
  double gravity = -4.4; // How strong the gravity is
  double velocity = 3.1; // How strong the jump is
  double birdWidth = 0.12;
  double birdHeight = 0.12;

  // Barrier Variables
  static List<double> barrierX = [2, 2 + 1.5];
  static double barrierWidth = 0.5;
  List<List<double>> barrierHeight = [
    [0.6, 0.4],
    [0.4, 0.6],
  ];

  bool gameHasStarted = false;

  void startGame() {
    gameHasStarted = true;
    Timer.periodic(const Duration(milliseconds: 10), (timer) {
      // A real physical jump is the same as an upside down parabola
      // So this is a simple quadratic expression dervived from y = -gt^2/2 + vt

      height = gravity * time * time + velocity * time;

      setState(() {
        birdY = initialPos - height;
      });

      // CHeck if the bird is dead
      if (birdIsDead()) {
        timer.cancel();
        setState(() {
          gameHasStarted = false;
        });
        _showDialog();
      }

      moveMap();

      // Keep the time going
      time += 0.008;
    });
  }

  void moveMap() {
    for (int i = 0; i < barrierX.length; i++) {
      setState(() {
        barrierX[i] -= 0.005;
      });

      if (barrierX[i] < -1.5) {
        barrierX[i] += 3;
      }
    }
  }

  void jump() {
    setState(() {
      time = 0;
      initialPos = birdY;
    });
  }

  bool birdIsDead() {
    // Check if the bird is hitting the top or bottom of the screen
    if (birdY < -1 || birdY > 1) {
      return true;
    }

    // CHeck if the bird hit any barriers
    for (int i = 0; i < barrierX.length; i++) {
      if (barrierX[i] <= birdWidth &&
          barrierX[i] + barrierWidth >= -birdWidth &&
          (birdY <= -1 + barrierHeight[i][0] ||
              birdY + birdHeight >= 1 - barrierHeight[i][1])) {
        return true;
      }
    }
    return false;
  }

  void resetGame() {
    Navigator.of(context).pop();
    setState(() {
      birdY = 0;
      gameHasStarted = false;
      time = 0;
      initialPos = birdY;
      barrierX = [2, 2 + 1.5];
    });
  }

  void _showDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.brown,
          title: const Center(
            child: Text(
              "G A M E  O V E R",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          actions: [
            GestureDetector(
              onTap: resetGame,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  padding: const EdgeInsets.all(7),
                  color: Colors.white,
                  child: const Text(
                    "PLAY AGAIN",
                    style: TextStyle(
                      color: Colors.brown,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: gameHasStarted ? jump : startGame,
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                color: const Color(0xFF4bc3cf),
                child: Center(
                  child: Stack(
                    children: [
                      MyBird(
                        birdY: birdY,
                        birdHeight: birdHeight,
                        birdWidth: birdWidth,
                      ),
                      Container(
                        alignment: const Alignment(0, -0.5),
                        child: Text(
                          gameHasStarted ? "" : "T A P  T O  P L A Y",
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      MyBarrier(
                        barrierHeight: barrierHeight[0][0],
                        barrierWidth: barrierWidth,
                        barrierX: barrierX[0],
                        isThisBottomBarrier: false,
                      ),
                      MyBarrier(
                        barrierHeight: barrierHeight[0][1],
                        barrierWidth: barrierWidth,
                        barrierX: barrierX[0],
                        isThisBottomBarrier: true,
                      ),
                      MyBarrier(
                        barrierHeight: barrierHeight[1][0],
                        barrierWidth: barrierWidth,
                        barrierX: barrierX[1],
                        isThisBottomBarrier: false,
                      ),
                      MyBarrier(
                        barrierHeight: barrierHeight[1][1],
                        barrierWidth: barrierWidth,
                        barrierX: barrierX[1],
                        isThisBottomBarrier: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF3a2e24),
                  border: Border(
                    top: BorderSide(
                      color: Color(0xFF75bf2f),
                      width: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
