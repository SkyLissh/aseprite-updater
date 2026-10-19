// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'build_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BuildState {

 BuildPhase get phase; BuildStatus get status; BuildOperation? get operation; double? get progress; String? get errorMessage;
/// Create a copy of BuildState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BuildStateCopyWith<BuildState> get copyWith => _$BuildStateCopyWithImpl<BuildState>(this as BuildState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BuildState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BuildState&&(identical(other.phase, _this.phase) || other.phase == _this.phase)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.operation, _this.operation) || other.operation == _this.operation)&&(identical(other.progress, _this.progress) || other.progress == _this.progress)&&(identical(other.errorMessage, _this.errorMessage) || other.errorMessage == _this.errorMessage));
}


@override
int get hashCode {
  final _this = this as BuildState;
  return Object.hash(runtimeType,_this.phase,_this.status,_this.operation,_this.progress,_this.errorMessage);
}

@override
String toString() {
  final _this = this as BuildState;
  return 'BuildState(phase: ${_this.phase}, status: ${_this.status}, operation: ${_this.operation}, progress: ${_this.progress}, errorMessage: ${_this.errorMessage})';
}


}

/// @nodoc
abstract mixin class $BuildStateCopyWith<$Res>  {
  factory $BuildStateCopyWith(BuildState value, $Res Function(BuildState) _then) = _$BuildStateCopyWithImpl;
@useResult
$Res call({
 BuildPhase phase, BuildStatus status, BuildOperation? operation, double? progress, String? errorMessage
});




}
/// @nodoc
class _$BuildStateCopyWithImpl<$Res>
    implements $BuildStateCopyWith<$Res> {
  _$BuildStateCopyWithImpl(this._self, this._then);

  final BuildState _self;
  final $Res Function(BuildState) _then;

/// Create a copy of BuildState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phase = null,Object? status = null,Object? operation = freezed,Object? progress = freezed,Object? errorMessage = freezed,}) {
  return _then(BuildState(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as BuildPhase,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BuildStatus,operation: freezed == operation ? _self.operation : operation // ignore: cast_nullable_to_non_nullable
as BuildOperation?,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BuildState].
extension BuildStatePatterns on BuildState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BuildState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BuildState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BuildState value)  $default,){
final _that = this;
switch (_that) {
case _BuildState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BuildState value)?  $default,){
final _that = this;
switch (_that) {
case _BuildState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BuildPhase phase,  BuildStatus status,  BuildOperation? operation,  double? progress,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BuildState() when $default != null:
return $default(_that.phase,_that.status,_that.operation,_that.progress,_that.errorMessage);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BuildPhase phase,  BuildStatus status,  BuildOperation? operation,  double? progress,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _BuildState():
return $default(_that.phase,_that.status,_that.operation,_that.progress,_that.errorMessage);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BuildPhase phase,  BuildStatus status,  BuildOperation? operation,  double? progress,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _BuildState() when $default != null:
return $default(_that.phase,_that.status,_that.operation,_that.progress,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _BuildState implements BuildState {
  const _BuildState({this.phase = BuildPhase.preparing, this.status = BuildStatus.idle, this.operation, this.progress, this.errorMessage});
  

@override@JsonKey() final  BuildPhase phase;
@override@JsonKey() final  BuildStatus status;
@override final  BuildOperation? operation;
@override final  double? progress;
@override final  String? errorMessage;

/// Create a copy of BuildState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BuildStateCopyWith<_BuildState> get copyWith => __$BuildStateCopyWithImpl<_BuildState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BuildState&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.status, status) || other.status == status)&&(identical(other.operation, operation) || other.operation == operation)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode {
    return Object.hash(runtimeType,phase,status,operation,progress,errorMessage);
}

@override
String toString() {
    return 'BuildState(phase: $phase, status: $status, operation: $operation, progress: $progress, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$BuildStateCopyWith<$Res> implements $BuildStateCopyWith<$Res> {
  factory _$BuildStateCopyWith(_BuildState value, $Res Function(_BuildState) _then) = __$BuildStateCopyWithImpl;
@override @useResult
$Res call({
 BuildPhase phase, BuildStatus status, BuildOperation? operation, double? progress, String? errorMessage
});




}
/// @nodoc
class __$BuildStateCopyWithImpl<$Res>
    implements _$BuildStateCopyWith<$Res> {
  __$BuildStateCopyWithImpl(this._self, this._then);

  final _BuildState _self;
  final $Res Function(_BuildState) _then;

/// Create a copy of BuildState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phase = null,Object? status = null,Object? operation = freezed,Object? progress = freezed,Object? errorMessage = freezed,}) {
  return _then(_BuildState(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as BuildPhase,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BuildStatus,operation: freezed == operation ? _self.operation : operation // ignore: cast_nullable_to_non_nullable
as BuildOperation?,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
