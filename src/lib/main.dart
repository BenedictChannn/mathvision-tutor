import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/capture/capture_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/capture/capture_screen.dart';
import 'services/solve_api.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

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
