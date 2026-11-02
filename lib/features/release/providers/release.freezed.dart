// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'release.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReleaseState {

 Release get latest; String? get current;
/// Create a copy of ReleaseState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReleaseStateCopyWith<ReleaseState> get copyWith => _$ReleaseStateCopyWithImpl<ReleaseState>(this as ReleaseState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ReleaseState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReleaseState&&(identical(other.latest, _this.latest) || other.latest == _this.latest)&&(identical(other.current, _this.current) || other.current == _this.current));
}


@override
int get hashCode {
  final _this = this as ReleaseState;
  return Object.hash(runtimeType,_this.latest,_this.current);
}

@override
String toString() {
  final _this = this as ReleaseState;
  return 'ReleaseState(latest: ${_this.latest}, current: ${_this.current})';
}


}

/// @nodoc
abstract mixin class $ReleaseStateCopyWith<$Res>  {
  factory $ReleaseStateCopyWith(ReleaseState value, $Res Function(ReleaseState) _then) = _$ReleaseStateCopyWithImpl;
@useResult
$Res call({
 Release latest, String? current
});


$ReleaseCopyWith<$Res> get latest;

}
/// @nodoc
class _$ReleaseStateCopyWithImpl<$Res>
    implements $ReleaseStateCopyWith<$Res> {
  _$ReleaseStateCopyWithImpl(this._self, this._then);

  final ReleaseState _self;
  final $Res Function(ReleaseState) _then;

/// Create a copy of ReleaseState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? latest = null,Object? current = freezed,}) {
  return _then(ReleaseState(
latest: null == latest ? _self.latest : latest // ignore: cast_nullable_to_non_nullable
as Release,current: freezed == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ReleaseState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReleaseCopyWith<$Res> get latest {

  return $ReleaseCopyWith<$Res>(_self.latest, (value) {
    return _then(_self.copyWith(latest: value));
  });
}
}


/// Adds pattern-matching-related methods to [ReleaseState].
extension ReleaseStatePatterns on ReleaseState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReleaseState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReleaseState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReleaseState value)  $default,){
final _that = this;
switch (_that) {
case _ReleaseState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReleaseState value)?  $default,){
final _that = this;
switch (_that) {
case _ReleaseState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Release latest,  String? current)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReleaseState() when $default != null:
return $default(_that.latest,_that.current);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Release latest,  String? current)  $default,) {final _that = this;
switch (_that) {
case _ReleaseState():
return $default(_that.latest,_that.current);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Release latest,  String? current)?  $default,) {final _that = this;
switch (_that) {
case _ReleaseState() when $default != null:
return $default(_that.latest,_that.current);case _:
  return null;

}
}

}

/// @nodoc


class _ReleaseState implements ReleaseState {
  const _ReleaseState({required this.latest, this.current});


@override final  Release latest;
@override final  String? current;

/// Create a copy of ReleaseState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReleaseStateCopyWith<_ReleaseState> get copyWith => __$ReleaseStateCopyWithImpl<_ReleaseState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReleaseState&&(identical(other.latest, latest) || other.latest == latest)&&(identical(other.current, current) || other.current == current));
}


@override
int get hashCode {
    return Object.hash(runtimeType,latest,current);
}

@override
String toString() {
    return 'ReleaseState(latest: $latest, current: $current)';
}


}

/// @nodoc
abstract mixin class _$ReleaseStateCopyWith<$Res> implements $ReleaseStateCopyWith<$Res> {
  factory _$ReleaseStateCopyWith(_ReleaseState value, $Res Function(_ReleaseState) _then) = __$ReleaseStateCopyWithImpl;
@override @useResult
$Res call({
 Release latest, String? current
});


@override $ReleaseCopyWith<$Res> get latest;

}
/// @nodoc
class __$ReleaseStateCopyWithImpl<$Res>
    implements _$ReleaseStateCopyWith<$Res> {
  __$ReleaseStateCopyWithImpl(this._self, this._then);

  final _ReleaseState _self;
  final $Res Function(_ReleaseState) _then;

/// Create a copy of ReleaseState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? latest = null,Object? current = freezed,}) {
  return _then(_ReleaseState(
latest: null == latest ? _self.latest : latest // ignore: cast_nullable_to_non_nullable
as Release,current: freezed == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ReleaseState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReleaseCopyWith<$Res> get latest {

  return $ReleaseCopyWith<$Res>(_self.latest, (value) {
    return _then(_self.copyWith(latest: value));
  });
}
}

// dart format on
