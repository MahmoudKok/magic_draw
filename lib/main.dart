import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic_draw/board/bloc/drawing_bloc.dart';

import 'board/screens/white_board_drawing_screen.dart';

// Keep the BLoC instance alive across hot reloads
final drawingBloc = DrawingBloc();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocProvider.value(
        value: drawingBloc, // Use the existing instance
        child: const WhiteboardDrawing(),
      ),
    );
  }
}

class WhiteboardDrawing extends StatefulWidget {
  const WhiteboardDrawing({super.key});

  @override
  State<WhiteboardDrawing> createState() => _WhiteboardDrawingState();
}

class _WhiteboardDrawingState extends State<WhiteboardDrawing>
    with SingleTickerProviderStateMixin {
  Color _selectedColor = Colors.purple;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onPanUpdate: (details) {
                context
                    .read<DrawingBloc>()
                    .add(AddPointEvent(details.localPosition, _selectedColor));
              },
              onPanEnd: (details) {
                context.read<DrawingBloc>().add(SetPressPositionEvent(null));
              },
              onTapDown: (details) {
                context
                    .read<DrawingBloc>()
                    .add(SetPressPositionEvent(details.localPosition));
              },
              onTapUp: (details) {
                context.read<DrawingBloc>().add(SetPressPositionEvent(null));
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!, width: 2.0),
                ),
                child: SizedBox(
                  width: 400,
                  height: 400,
                  child: BlocBuilder<DrawingBloc, DrawingState>(
                    builder: (context, state) {
                      return CustomPaint(
                        painter: MagicLinesPainter(
                          points: state.points,
                          animationValue: _controller.value,
                          pressPosition: state.pressPosition,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          _buildColorPalette(),
        ],
      ),
    );
  }

  Widget _buildColorPalette() {
    final colors = [
      Colors.purple,
      Colors.blue,
      Colors.cyan,
      Colors.red,
      Colors.green,
      Colors.yellow,
      Colors.black,
    ];
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: colors.map((color) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedColor = color;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _selectedColor == color
                      ? Colors.white
                      : Colors.transparent,
                  width: 2.0,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
