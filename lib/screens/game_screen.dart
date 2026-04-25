import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/obstacle.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Game State
  bool _isPlaying = false;
  bool _isGameOver = false;
  int _score = 0;
  Timer? _gameTimer;
  
  // Hero Properties
  final double _heroX = -0.6;
  double _heroY = 0.8; // 0.8 is floor, -0.8 is ceiling
  final double _heroSize = 40.0;

  // Obstacle Properties
  List<Obstacle> _obstacles = [];
  final double _obstacleSize = 40.0;
  double _obstacleSpeed = 0.02;
  int _ticksToNextSpawn = 0;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // Don't start immediately, wait for user tap
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _isGameOver = false;
      _score = 0;
      _heroY = 0.8;
      _obstacles = [];
      _obstacleSpeed = 0.02;
      _ticksToNextSpawn = 0;
    });

    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      _updateGame();
    });
  }

  void _updateGame() {
    if (!_isPlaying || _isGameOver) return;

    setState(() {
      // Move obstacles
      for (var obstacle in _obstacles) {
        obstacle.x -= _obstacleSpeed;
      }

      // Remove off-screen obstacles
      _obstacles.removeWhere((o) => o.x < -1.2);

      // Spawn new obstacles
      if (_ticksToNextSpawn <= 0) {
        _spawnObstacle();
        _ticksToNextSpawn = 40 + _random.nextInt(60);
      } else {
        _ticksToNextSpawn--;
      }

      // Check for scoring and collisions
      for (var obstacle in _obstacles) {
        if (!obstacle.passedHero && obstacle.x < _heroX) {
          obstacle.passedHero = true;
          _score++;
          if (_score % 5 == 0) {
            _obstacleSpeed += 0.001;
          }
        }

        double dx = (obstacle.x - _heroX).abs();
        double dy = (obstacle.y - _heroY).abs();

        if (dx < 0.15 && dy < 0.1) {
          _gameOver();
        }
      }
    });
  }

  void _spawnObstacle() {
    double yPos = _random.nextBool() ? 0.8 : -0.8;
    _obstacles.add(Obstacle(
      x: 1.2,
      y: yPos,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    ));
  }

  void _gameOver() {
    _gameTimer?.cancel();
    setState(() {
      _isPlaying = false;
      _isGameOver = true;
    });
  }

  void _toggleGravity() {
    if (_isPlaying) {
      setState(() {
        _heroY = (_heroY == 0.8) ? -0.8 : 0.8;
      });
    } else if (_isGameOver) {
      _startGame();
    } else {
      _startGame();
    }
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggleGravity,
            child: Stack(
              children: [
                // Background Score
                Center(
                  child: Opacity(
                    opacity: 0.1,
                    child: Text(
                      'SCORE: $_score',
                      style: const TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // Boundary Lines
                Align(
                  alignment: const Alignment(0, 0.85),
                  child: Container(height: 2, color: Colors.white24),
                ),
                Align(
                  alignment: const Alignment(0, -0.85),
                  child: Container(height: 2, color: Colors.white24),
                ),

                // Obstacles
                ..._obstacles.map((obstacle) {
                  return Align(
                    alignment: Alignment(obstacle.x, obstacle.y),
                    child: Container(
                      width: _obstacleSize,
                      height: _obstacleSize,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withAlpha(128),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                // Hero
                Align(
                  alignment: Alignment(_heroX, _heroY),
                  child: Container(
                    width: _heroSize,
                    height: _heroSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.cyanAccent,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyan.withAlpha(200),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),

                // Back Button
                Positioned(
                  top: 40,
                  left: 20,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                // Overlays
                if (!_isPlaying && !_isGameOver)
                  _buildOverlay('TAP TO START', 'Get ready to switch!'),
                
                if (_isGameOver)
                  _buildOverlay('GAME OVER', 'Final Score: $_score\nTap to restart'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay(String title, String subtitle) {
    return Container(
      color: Colors.black.withAlpha(150),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
