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
    this.followUpsLeft = 3,
    this.onFollowUpRequested,
  });

  /// The final answer to the user’s maths problem.
  final String answer;

  /// A sequential list of explanation steps.
  final List<String> steps;

  /// Remaining follow-up questions the user can ask before reaching the cap.
  final int followUpsLeft;

  /// Invoked when the user submits a follow-up question.
  final ValueChanged<String>? onFollowUpRequested;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solution'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double maxListHeight = constraints.maxHeight * 0.6; // Limit to 60% of viewport
          return Padding(
            padding: const EdgeInsets.all(16.0),
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
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxListHeight),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: steps.length,
                    itemBuilder: (context, index) =>
                        _buildStepCard(context, index),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: followUpsLeft > 0 ? () => _openFollowUpSheet(context) : null,
          child: Text('Ask a follow-up (\$followUpsLeft left)'),
        ),
      ),
    );
  }

  Future<void> _openFollowUpSheet(BuildContext context) async {
    final controller = TextEditingController();
    final question = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: controller,
                textInputAction: TextInputAction.send,
                decoration: const InputDecoration(
                  labelText: 'Enter your follow-up question',
                ),
                onSubmitted: (_) =>
                    Navigator.of(context).pop(controller.text.trim()),
                maxLines: null,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pop(controller.text.trim()),
                child: const Text('Send'),
              ),
            ],
          ),
        );
      },
    );

    if (question != null && question.isNotEmpty) {
      onFollowUpRequested?.call(question);
    }
  }

  Widget _buildStepCard(BuildContext context, int index) => Card(
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
      );
}
