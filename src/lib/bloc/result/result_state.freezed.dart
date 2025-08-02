// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'result_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ResultState _$ResultStateFromJson(Map<String, dynamic> json) {
  return _ResultState.fromJson(json);
}

/// @nodoc
mixin _$ResultState {
  String get answer => throw _privateConstructorUsedError;
  List<String> get steps => throw _privateConstructorUsedError;
  int get followUpsLeft => throw _privateConstructorUsedError;
  bool get isSubmitting => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Serializes this ResultState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ResultState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ResultStateCopyWith<ResultState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResultStateCopyWith<$Res> {
  factory $ResultStateCopyWith(
    ResultState value,
    $Res Function(ResultState) then,
  ) = _$ResultStateCopyWithImpl<$Res, ResultState>;
  @useResult
  $Res call({
    String answer,
    List<String> steps,
    int followUpsLeft,
    bool isSubmitting,
    String? error,
  });
}

/// @nodoc
class _$ResultStateCopyWithImpl<$Res, $Val extends ResultState>
    implements $ResultStateCopyWith<$Res> {
  _$ResultStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ResultState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? answer = null,
    Object? steps = null,
    Object? followUpsLeft = null,
    Object? isSubmitting = null,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            answer: null == answer
                ? _value.answer
                : answer // ignore: cast_nullable_to_non_nullable
                      as String,
            steps: null == steps
                ? _value.steps
                : steps // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            followUpsLeft: null == followUpsLeft
                ? _value.followUpsLeft
                : followUpsLeft // ignore: cast_nullable_to_non_nullable
                      as int,
            isSubmitting: null == isSubmitting
                ? _value.isSubmitting
                : isSubmitting // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ResultStateImplCopyWith<$Res>
    implements $ResultStateCopyWith<$Res> {
  factory _$$ResultStateImplCopyWith(
    _$ResultStateImpl value,
    $Res Function(_$ResultStateImpl) then,
  ) = __$$ResultStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String answer,
    List<String> steps,
    int followUpsLeft,
    bool isSubmitting,
    String? error,
  });
}

/// @nodoc
class __$$ResultStateImplCopyWithImpl<$Res>
    extends _$ResultStateCopyWithImpl<$Res, _$ResultStateImpl>
    implements _$$ResultStateImplCopyWith<$Res> {
  __$$ResultStateImplCopyWithImpl(
    _$ResultStateImpl _value,
    $Res Function(_$ResultStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ResultState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? answer = null,
    Object? steps = null,
    Object? followUpsLeft = null,
    Object? isSubmitting = null,
    Object? error = freezed,
  }) {
    return _then(
      _$ResultStateImpl(
        answer: null == answer
            ? _value.answer
            : answer // ignore: cast_nullable_to_non_nullable
                  as String,
        steps: null == steps
            ? _value._steps
            : steps // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        followUpsLeft: null == followUpsLeft
            ? _value.followUpsLeft
            : followUpsLeft // ignore: cast_nullable_to_non_nullable
                  as int,
        isSubmitting: null == isSubmitting
            ? _value.isSubmitting
            : isSubmitting // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ResultStateImpl implements _ResultState {
  const _$ResultStateImpl({
    required this.answer,
    required final List<String> steps,
    required this.followUpsLeft,
    this.isSubmitting = false,
    this.error,
  }) : _steps = steps;

  factory _$ResultStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$ResultStateImplFromJson(json);

  @override
  final String answer;
  final List<String> _steps;
  @override
  List<String> get steps {
    if (_steps is EqualUnmodifiableListView) return _steps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_steps);
  }

  @override
  final int followUpsLeft;
  @override
  @JsonKey()
  final bool isSubmitting;
  @override
  final String? error;

  @override
  String toString() {
    return 'ResultState(answer: $answer, steps: $steps, followUpsLeft: $followUpsLeft, isSubmitting: $isSubmitting, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResultStateImpl &&
            (identical(other.answer, answer) || other.answer == answer) &&
            const DeepCollectionEquality().equals(other._steps, _steps) &&
            (identical(other.followUpsLeft, followUpsLeft) ||
                other.followUpsLeft == followUpsLeft) &&
            (identical(other.isSubmitting, isSubmitting) ||
                other.isSubmitting == isSubmitting) &&
            (identical(other.error, error) || other.error == error));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    answer,
    const DeepCollectionEquality().hash(_steps),
    followUpsLeft,
    isSubmitting,
    error,
  );

  /// Create a copy of ResultState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResultStateImplCopyWith<_$ResultStateImpl> get copyWith =>
      __$$ResultStateImplCopyWithImpl<_$ResultStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ResultStateImplToJson(this);
  }
}

abstract class _ResultState implements ResultState {
  const factory _ResultState({
    required final String answer,
    required final List<String> steps,
    required final int followUpsLeft,
    final bool isSubmitting,
    final String? error,
  }) = _$ResultStateImpl;

  factory _ResultState.fromJson(Map<String, dynamic> json) =
      _$ResultStateImpl.fromJson;

  @override
  String get answer;
  @override
  List<String> get steps;
  @override
  int get followUpsLeft;
  @override
  bool get isSubmitting;
  @override
  String? get error;

  /// Create a copy of ResultState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResultStateImplCopyWith<_$ResultStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
