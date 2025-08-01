import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:src/bloc/capture/capture_cubit.dart';
import 'package:src/bloc/capture/capture_state.dart';
import 'package:src/screens/capture/capture_screen.dart';
import 'package:src/services/solve_api.dart';

class _FakeSolveApi extends SolveApi {
  const _FakeSolveApi() : super('https://example.com');

  @override
  Future<String> uploadImage({required image, required String idToken}) async {
    return 'ok';
  }
}

void main() {
  group('CaptureCubit', () {
    late CaptureCubit cubit;

    setUp(() {
      cubit = CaptureCubit(solveApi: const _FakeSolveApi(), idToken: 'token');
    });

    test('initial state is CaptureState.initial', () {
      expect(cubit.state, const CaptureState.initial());
    });
  });

  group('CaptureScreen UI', () {
    testWidgets('shows progress indicator when uploading', (tester) async {
      final cubit = CaptureCubit(solveApi: const _FakeSolveApi(), idToken: 'token');

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: cubit,
            child: const CaptureScreen(),
          ),
        ),
      );

      expect(find.byWidgetPredicate((w) => w is ElevatedButton), findsNWidgets(2));
      expect(find.byType(CircularProgressIndicator), findsNothing);

      cubit.emit(const CaptureState.uploading());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final elevatedButtons = tester.widgetList<ElevatedButton>(find.byWidgetPredicate((w) => w is ElevatedButton));
      for (final btn in elevatedButtons) {
        expect(btn.onPressed, isNull);
      }

      cubit.emit(const CaptureState.error('failure'));
      await tester.pump();
      expect(find.text('failure'), findsOneWidget);
    });
  });
}
