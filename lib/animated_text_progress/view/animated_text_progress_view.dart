import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AnimatedTextProgressPage extends StatefulWidget {
  const AnimatedTextProgressPage({super.key});

  static PageRoute route() =>
      MaterialPageRoute(builder: (context) => const AnimatedTextProgressPage());

  @override
  State<AnimatedTextProgressPage> createState() =>
      _AnimatedTextProgressPageState();
}

class _AnimatedTextProgressPageState extends State<AnimatedTextProgressPage>
    with TickerProviderStateMixin {
  late Ticker _ticker;
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _activeIndex = 0;
  final texts = [
    'Connecting to server',
    'Connected to server',
    'Fetching data',
    'Data fetched',
    'Processing data',
    // 'Data processed',
    // 'Uploading data',
    // 'Data uploaded',
    // 'Downloading data',
    // 'Data downloaded',
  ];
  final int _elapsedThreshold = 250;
  int _counter = 0;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );
    _ticker = Ticker((elapsed) {
      if (_counter >= _elapsedThreshold) {
        setState(() {
          _counter = 0;
        });
        if (_activeIndex <= texts.length - 1) {
          _increment();
        }
      }
      setState(() {
        _counter++;
      });
    });
    _ticker.start();
  }

  void _increment() {
    Future.delayed(const Duration(milliseconds: 200), () {
      _animationController.forward(from: 0).then((value) {
        setState(() {
          _activeIndex++;
        });
      });
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Animated Text Progress"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            ClipRRect(
              child: SizedBox(
                height: 120,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: OverflowBox(
                    maxHeight: .infinity,
                    alignment: .topCenter,
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        final offset = (_activeIndex + _animation.value) * 60;
                        return Transform.translate(
                          offset: const Offset(0, -(0 * 60.0)),
                          child: Column(
                            mainAxisSize: .min,
                            children: List.generate(texts.length, (index) {
                              final text = texts[index];
                              return _AnimatedTextRow(
                                text: text,
                                // opacity: index == _activeIndex
                                //     ? 1
                                //     : index == _activeIndex + 1
                                //     ? 0.45
                                //     : 0,
                                opacity: 1,
                                isDone: index <= _activeIndex,
                                isActive: index == _activeIndex,
                              );
                            }),
                          ),
                        );
                      },
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

class _AnimatedTextRow extends StatelessWidget {
  const _AnimatedTextRow({
    this.opacity = 1.0,
    this.isActive = false,
    this.isDone = false,
    required this.text,
  });
  final double opacity;
  final bool isActive;
  final bool isDone;
  final String text;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: opacity,
      curve: Curves.easeInOut,
      duration: const Duration(milliseconds: 500),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isActive
                ? const Icon(Icons.timer_sharp, color: Colors.blue, size: 22)
                : isDone
                ? const Icon(Icons.done, color: Colors.green, size: 22)
                : const Icon(
                    Icons.circle_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
          ),
          const SizedBox(width: 10),
          AnimatedDefaultTextStyle(
            style: TextStyle(
              color: isActive
                  ? Colors.blue
                  : isDone
                  ? Colors.green
                  : Colors.black,
              fontSize: 20,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
            duration: const Duration(milliseconds: 500),
            child: Text(text),
          ),
        ],
      ),
    );
  }
}
