import 'package:flutter/material.dart';

/// Displays the solution answer prominently and a list of collapsible
/// step cards explaining the solution in detail.
///
/// This widget is UI-only; it expects the answer text and a list of steps
/// to be provided (e.g. via Navigator arguments or a Bloc). Business logic
/// and state management will be wired in a later task.
class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.answer,
    required this.steps,
  });

  /// The final answer to the user’s maths problem.
  final String answer;

  /// A sequential list of explanation steps.
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solution'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Answer text in a large, readable font.
              SelectableText(
                answer,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              ..._buildStepCards(context),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStepCards(BuildContext context) => List.generate(
        steps.length,
        (index) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            initiallyExpanded: index == 0, // expand first step by default
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(
              'Step ${index + 1}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SelectableText.rich(
                  TextSpan(
                    text: steps[index],
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
