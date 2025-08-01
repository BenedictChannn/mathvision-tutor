import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/capture/capture_cubit.dart';
import 'screens/capture/capture_screen.dart';
import 'services/solve_api.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Math Tutor MVP',
        theme: ThemeData.light(useMaterial3: true),
        home: BlocProvider(
          // TODO: Replace baseUrl and idToken with real values once backend is up.
          create: (_) => CaptureCubit(
            solveApi: const SolveApi('https://api.placeholder.com'),
            idToken: '',
          ),
          child: const CaptureScreen(),
        ),
      );
}
