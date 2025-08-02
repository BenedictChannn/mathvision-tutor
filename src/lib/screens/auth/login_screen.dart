import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_cubit.dart';
import '../../bloc/auth/auth_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Sign In')),
        body: Center(
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              state.maybeWhen(
                authenticated: (_) => Navigator.pop(context),
                orElse: () {},
              );
            },
            builder: (context, state) {
              final isLoading = state.maybeWhen(loading: () => true, orElse: () => false);
              final errorMsg = state.maybeWhen<String?>(
                error: (msg) => msg,
                orElse: () => null,
              );
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () => context.read<AuthCubit>().signInWithGoogle(),
                    child: const Text('Sign in with Google'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () => context.read<AuthCubit>().signInAnonymously(),
                    child: const Text('Continue as Guest'),
                  ),
                  if (errorMsg != null) ...[
                    const SizedBox(height: 16),
                    Text(errorMsg, style: const TextStyle(color: Colors.red)),
                  ],
                  if (isLoading) const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                ],
              );
            },
          ),
        ),
      );
}
