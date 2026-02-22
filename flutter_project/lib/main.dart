import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const HellobusApp());
}

class HellobusApp extends StatelessWidget {
  const HellobusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hellobus Wakeword Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const WakewordScreen(),
    );
  }
}

class WakewordScreen extends StatefulWidget {
  const WakewordScreen({super.key});

  @override
  State<WakewordScreen> createState() => _WakewordScreenState();
}

class _WakewordScreenState extends State<WakewordScreen>
    with SingleTickerProviderStateMixin {
  static const List<String> _wakewords = [
    'hellobus',
    'busagent',
    'okbus',
    'okagent',
  ];
  static const double _detectionThreshold = 0.75;

  bool _isListening = false;
  String _detectedWord = '';
  double _confidence = 0.0;
  List<double> _scores = List.filled(_wakewords.length, 0.0);

  late AnimationController _pulseController;
  Timer? _simulationTimer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  void _toggleListening() {
    if (_isListening) {
      _simulationTimer?.cancel();
      setState(() {
        _isListening = false;
        _scores = List.filled(_wakewords.length, 0.0);
      });
    } else {
      setState(() {
        _isListening = true;
        _detectedWord = '';
        _confidence = 0.0;
        _scores = List.filled(_wakewords.length, 0.0);
      });
      _startSimulation();
    }
  }

  void _startSimulation() {
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      if (!_isListening) return;

      final spike = _random.nextDouble() > 0.85;
      final spikeIndex = _random.nextInt(_wakewords.length);

      final newScores = List.generate(_wakewords.length, (i) {
        if (spike && i == spikeIndex) {
          return 0.65 + _random.nextDouble() * 0.35;
        }
        return _random.nextDouble() * 0.3;
      });

      final maxScore = newScores.reduce(max);
      final maxIndex = newScores.indexOf(maxScore);

      setState(() {
        _scores = newScores;
        if (maxScore > _detectionThreshold) {
          _detectedWord = _wakewords[maxIndex];
          _confidence = maxScore;
        } else if (maxScore < 0.3) {
          _detectedWord = '';
          _confidence = 0.0;
        }
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _simulationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F0FF),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          'Hellobus Wakeword',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _buildMicButton(),
                  const SizedBox(height: 24),
                  Text(
                    _isListening ? 'Listening...' : 'Tap to start',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 40),
                  _buildDetectedWord(),
                  if (_confidence > 0) ...[
                    const SizedBox(height: 10),
                    Text(
                      '${(_confidence * 100).toStringAsFixed(1)}% confidence',
                      style: TextStyle(
                          color: Colors.deepPurple[300], fontSize: 13),
                    ),
                  ],
                  const SizedBox(height: 40),
                  _buildScoreBars(),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 12),
                  _buildModelInfoCard(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMicButton() {
    return GestureDetector(
      onTap: _toggleListening,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final scale =
              _isListening ? 1.0 + _pulseController.value * 0.12 : 1.0;
          final color = _isListening ? Colors.red : Colors.deepPurple;
          return Transform.scale(
            scale: scale,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                size: 60,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetectedWord() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _detectedWord.isNotEmpty
          ? Container(
              key: ValueKey(_detectedWord),
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Text(
                _detectedWord,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            )
          : Text(
              '—',
              key: const ValueKey('empty'),
              style: TextStyle(fontSize: 28, color: Colors.grey[400]),
            ),
    );
  }

  Widget _buildScoreBars() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detection Scores',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        ...List.generate(_wakewords.length, (i) {
          final score = _scores[i];
          final isDetected = _detectedWord == _wakewords[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 90,
                  child: Text(
                    _wakewords[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isDetected ? FontWeight.bold : FontWeight.normal,
                      color:
                          isDetected ? Colors.deepPurple : Colors.grey[700],
                    ),
                  ),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: score,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(6),
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(
                      isDetected ? Colors.deepPurple : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 40,
                  child: Text(
                    '${(score * 100).toStringAsFixed(0)}%',
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildModelInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: Colors.deepPurple.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Model Info',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _infoRow('Model', 'retrained_graph.tflite'),
          _infoRow('Framework', 'TensorFlow Lite'),
          _infoRow('Input', '800ms audio @ 16kHz'),
          _infoRow('Threshold', '${(_detectionThreshold * 100).toInt()}% confidence'),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text('$label: ',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
