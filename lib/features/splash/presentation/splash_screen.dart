import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/loop_breathing_mark.dart';
import 'cubit/splash_cubit.dart';
import 'cubit/splash_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _completeWhenAppIsReady();
  }

  Future<void> _completeWhenAppIsReady() async {
    await Future.wait([
      WidgetsBinding.instance.endOfFrame,
      Future<void>.delayed(const Duration(seconds: 3)),
    ]);
    if (mounted) {
      context.read<SplashCubit>().complete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state is SplashCompleted) {
          context.go('/welcome');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: const LoopBreathingMark(dimension: 360)),
      ),
    );
  }
}
