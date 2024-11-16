import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: const MyHomePage(title: 'Modern Counter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  SharedPreferences? prefs;
  int _counter = 0;
  bool _isLoading = true; // Tambahkan loading state
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _initPreferences();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initPreferences() async {
    try {
      prefs = await SharedPreferences.getInstance();
      int counterStorage = prefs?.getInt('counter') ?? 0;
      setState(() {
        _counter = counterStorage;
        _isLoading = false; // Set loading ke false setelah data dimuat
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _counter = 0;
      });
      debugPrint('Error loading preferences: $e');
    }
  }

  Future<void> _incrementCounter() async {
    if (_isLoading) return; // Prevent action while loading
    prefs ??= await SharedPreferences.getInstance();
    setState(() {
      _counter++;
    });
    _controller.forward(from: 0);
    await prefs?.setInt('counter', _counter);
  }

  Future<void> _decrementCounter() async {
    if (_isLoading) return; // Prevent action while loading
    prefs ??= await SharedPreferences.getInstance();
    setState(() {
      _counter--;
    });
    _controller.forward(from: 0);
    await prefs?.setInt('counter', _counter);
  }

  Future<void> _resetCounter() async {
    if (_isLoading) return; // Prevent action while loading
    prefs ??= await SharedPreferences.getInstance();
    await prefs?.remove('counter');
    setState(() {
      _counter = 0;
    });
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2196F3),
              Color(0xFF1976D2),
              Color(0xFF0D47A1),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Glass morphism card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Counter Value',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : ScaleTransition(
                                    scale: _animation,
                                    child: Text(
                                      '$_counter',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 72,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Modern buttons with icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildIconButton(
                        icon: Icons.remove,
                        color: Colors.white,
                        onPressed: _isLoading ? null : _decrementCounter,
                      ),
                      const SizedBox(width: 24),
                      _buildIconButton(
                        icon: Icons.add,
                        color: Colors.white,
                        onPressed: _isLoading ? null : _incrementCounter,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Reset button
                  _buildResetButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    final isDisabled = onPressed == null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: Colors.white.withOpacity(isDisabled ? 0.1 : 0.3)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(isDisabled ? 0.1 : 0.3),
                Colors.white.withOpacity(isDisabled ? 0.05 : 0.1),
              ],
            ),
          ),
          child: Icon(
            icon,
            color: color.withOpacity(isDisabled ? 0.5 : 1.0),
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLoading ? null : _resetCounter,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.red.withOpacity(_isLoading ? 0.1 : 0.3),
            border: Border.all(
                color: Colors.red.withOpacity(_isLoading ? 0.2 : 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.refresh,
                color: Colors.white.withOpacity(_isLoading ? 0.5 : 1.0),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Reset Counter',
                style: TextStyle(
                  color: Colors.white.withOpacity(_isLoading ? 0.5 : 1.0),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
