// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'result_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ResultEvent {
  String get question => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String question) followUpRequested,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String question)? followUpRequested,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String question)? followUpRequested,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FollowUpRequested value) followUpRequested,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FollowUpRequested value)? followUpRequested,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FollowUpRequested value)? followUpRequested,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of ResultEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ResultEventCopyWith<ResultEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResultEventCopyWith<$Res> {
  factory $ResultEventCopyWith(
    ResultEvent value,
    $Res Function(ResultEvent) then,
  ) = _$ResultEventCopyWithImpl<$Res, ResultEvent>;
  @useResult
  $Res call({String question});
}

/// @nodoc
class _$ResultEventCopyWithImpl<$Res, $Val extends ResultEvent>
    implements $ResultEventCopyWith<$Res> {
  _$ResultEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ResultEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? question = null}) {
    return _then(
      _value.copyWith(
            question: null == question
                ? _value.question
                : question // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FollowUpRequestedImplCopyWith<$Res>
    implements $ResultEventCopyWith<$Res> {
  factory _$$FollowUpRequestedImplCopyWith(
    _$FollowUpRequestedImpl value,
    $Res Function(_$FollowUpRequestedImpl) then,
  ) = __$$FollowUpRequestedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String question});
}

/// @nodoc
class __$$FollowUpRequestedImplCopyWithImpl<$Res>
    extends _$ResultEventCopyWithImpl<$Res, _$FollowUpRequestedImpl>
    implements _$$FollowUpRequestedImplCopyWith<$Res> {
  __$$FollowUpRequestedImplCopyWithImpl(
    _$FollowUpRequestedImpl _value,
    $Res Function(_$FollowUpRequestedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ResultEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? question = null}) {
    return _then(
      _$FollowUpRequestedImpl(
        null == question
            ? _value.question
            : question // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$FollowUpRequestedImpl implements FollowUpRequested {
  const _$FollowUpRequestedImpl(this.question);

  @override
  final String question;

  @override
  String toString() {
    return 'ResultEvent.followUpRequested(question: $question)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FollowUpRequestedImpl &&
            (identical(other.question, question) ||
                other.question == question));
  }

  @override
  int get hashCode => Object.hash(runtimeType, question);

  /// Create a copy of ResultEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FollowUpRequestedImplCopyWith<_$FollowUpRequestedImpl> get copyWith =>
      __$$FollowUpRequestedImplCopyWithImpl<_$FollowUpRequestedImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String question) followUpRequested,
  }) {
    return followUpRequested(question);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String question)? followUpRequested,
  }) {
    return followUpRequested?.call(question);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String question)? followUpRequested,
    required TResult orElse(),
  }) {
    if (followUpRequested != null) {
      return followUpRequested(question);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FollowUpRequested value) followUpRequested,
  }) {
    return followUpRequested(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FollowUpRequested value)? followUpRequested,
  }) {
    return followUpRequested?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FollowUpRequested value)? followUpRequested,
    required TResult orElse(),
  }) {
    if (followUpRequested != null) {
      return followUpRequested(this);
    }
    return orElse();
  }
}

abstract class FollowUpRequested implements ResultEvent {
  const factory FollowUpRequested(final String question) =
      _$FollowUpRequestedImpl;

  @override
  String get question;

  /// Create a copy of ResultEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FollowUpRequestedImplCopyWith<_$FollowUpRequestedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
