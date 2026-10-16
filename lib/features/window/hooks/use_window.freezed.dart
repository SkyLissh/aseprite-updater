// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'use_window.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WindowState {

 bool get isMaximized; bool get isMinimized; Future<void> Function() get toggleMaximize; Future<void> Function() get minimize; Future<void> Function() get close; Future<void> Function() get startDrag; Future<void> Function() get showPopupMenu;
/// Create a copy of WindowState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WindowStateCopyWith<WindowState> get copyWith => _$WindowStateCopyWithImpl<WindowState>(this as WindowState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WindowState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WindowState&&(identical(other.isMaximized, _this.isMaximized) || other.isMaximized == _this.isMaximized)&&(identical(other.isMinimized, _this.isMinimized) || other.isMinimized == _this.isMinimized)&&(identical(other.toggleMaximize, _this.toggleMaximize) || other.toggleMaximize == _this.toggleMaximize)&&(identical(other.minimize, _this.minimize) || other.minimize == _this.minimize)&&(identical(other.close, _this.close) || other.close == _this.close)&&(identical(other.startDrag, _this.startDrag) || other.startDrag == _this.startDrag)&&(identical(other.showPopupMenu, _this.showPopupMenu) || other.showPopupMenu == _this.showPopupMenu));
}


@override
int get hashCode {
  final _this = this as WindowState;
  return Object.hash(runtimeType,_this.isMaximized,_this.isMinimized,_this.toggleMaximize,_this.minimize,_this.close,_this.startDrag,_this.showPopupMenu);
}

@override
String toString() {
  final _this = this as WindowState;
  return 'WindowState(isMaximized: ${_this.isMaximized}, isMinimized: ${_this.isMinimized}, toggleMaximize: ${_this.toggleMaximize}, minimize: ${_this.minimize}, close: ${_this.close}, startDrag: ${_this.startDrag}, showPopupMenu: ${_this.showPopupMenu})';
}


}

/// @nodoc
abstract mixin class $WindowStateCopyWith<$Res>  {
  factory $WindowStateCopyWith(WindowState value, $Res Function(WindowState) _then) = _$WindowStateCopyWithImpl;
@useResult
$Res call({
 bool isMaximized, bool isMinimized, Future<void> Function() toggleMaximize, Future<void> Function() minimize, Future<void> Function() close, Future<void> Function() startDrag, Future<void> Function() showPopupMenu
});




}
/// @nodoc
class _$WindowStateCopyWithImpl<$Res>
    implements $WindowStateCopyWith<$Res> {
  _$WindowStateCopyWithImpl(this._self, this._then);

  final WindowState _self;
  final $Res Function(WindowState) _then;

/// Create a copy of WindowState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isMaximized = null,Object? isMinimized = null,Object? toggleMaximize = null,Object? minimize = null,Object? close = null,Object? startDrag = null,Object? showPopupMenu = null,}) {
  return _then(WindowState(
isMaximized: null == isMaximized ? _self.isMaximized : isMaximized // ignore: cast_nullable_to_non_nullable
as bool,isMinimized: null == isMinimized ? _self.isMinimized : isMinimized // ignore: cast_nullable_to_non_nullable
as bool,toggleMaximize: null == toggleMaximize ? _self.toggleMaximize : toggleMaximize // ignore: cast_nullable_to_non_nullable
as Future<void> Function(),minimize: null == minimize ? _self.minimize : minimize // ignore: cast_nullable_to_non_nullable
as Future<void> Function(),close: null == close ? _self.close : close // ignore: cast_nullable_to_non_nullable
as Future<void> Function(),startDrag: null == startDrag ? _self.startDrag : startDrag // ignore: cast_nullable_to_non_nullable
as Future<void> Function(),showPopupMenu: null == showPopupMenu ? _self.showPopupMenu : showPopupMenu // ignore: cast_nullable_to_non_nullable
as Future<void> Function(),
  ));
}

}


/// Adds pattern-matching-related methods to [WindowState].
extension WindowStatePatterns on WindowState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WindowState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WindowState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WindowState value)  $default,){
final _that = this;
switch (_that) {
case _WindowState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WindowState value)?  $default,){
final _that = this;
switch (_that) {
case _WindowState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isMaximized,  bool isMinimized,  Future<void> Function() toggleMaximize,  Future<void> Function() minimize,  Future<void> Function() close,  Future<void> Function() startDrag,  Future<void> Function() showPopupMenu)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WindowState() when $default != null:
return $default(_that.isMaximized,_that.isMinimized,_that.toggleMaximize,_that.minimize,_that.close,_that.startDrag,_that.showPopupMenu);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isMaximized,  bool isMinimized,  Future<void> Function() toggleMaximize,  Future<void> Function() minimize,  Future<void> Function() close,  Future<void> Function() startDrag,  Future<void> Function() showPopupMenu)  $default,) {final _that = this;
switch (_that) {
case _WindowState():
return $default(_that.isMaximized,_that.isMinimized,_that.toggleMaximize,_that.minimize,_that.close,_that.startDrag,_that.showPopupMenu);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isMaximized,  bool isMinimized,  Future<void> Function() toggleMaximize,  Future<void> Function() minimize,  Future<void> Function() close,  Future<void> Function() startDrag,  Future<void> Function() showPopupMenu)?  $default,) {final _that = this;
switch (_that) {
case _WindowState() when $default != null:
return $default(_that.isMaximized,_that.isMinimized,_that.toggleMaximize,_that.minimize,_that.close,_that.startDrag,_that.showPopupMenu);case _:
  return null;

}
}

}

/// @nodoc


class _WindowState implements WindowState {
  const _WindowState({required this.isMaximized, required this.isMinimized, required this.toggleMaximize, required this.minimize, required this.close, required this.startDrag, required this.showPopupMenu});
  

@override final  bool isMaximized;
@override final  bool isMinimized;
@override final  Future<void> Function() toggleMaximize;
@override final  Future<void> Function() minimize;
@override final  Future<void> Function() close;
@override final  Future<void> Function() startDrag;
@override final  Future<void> Function() showPopupMenu;

/// Create a copy of WindowState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WindowStateCopyWith<_WindowState> get copyWith => __$WindowStateCopyWithImpl<_WindowState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WindowState&&(identical(other.isMaximized, isMaximized) || other.isMaximized == isMaximized)&&(identical(other.isMinimized, isMinimized) || other.isMinimized == isMinimized)&&(identical(other.toggleMaximize, toggleMaximize) || other.toggleMaximize == toggleMaximize)&&(identical(other.minimize, minimize) || other.minimize == minimize)&&(identical(other.close, close) || other.close == close)&&(identical(other.startDrag, startDrag) || other.startDrag == startDrag)&&(identical(other.showPopupMenu, showPopupMenu) || other.showPopupMenu == showPopupMenu));
}


@override
int get hashCode {
    return Object.hash(runtimeType,isMaximized,isMinimized,toggleMaximize,minimize,close,startDrag,showPopupMenu);
}

@override
String toString() {
    return 'WindowState(isMaximized: $isMaximized, isMinimized: $isMinimized, toggleMaximize: $toggleMaximize, minimize: $minimize, close: $close, startDrag: $startDrag, showPopupMenu: $showPopupMenu)';
}


}

/// @nodoc
abstract mixin class _$WindowStateCopyWith<$Res> implements $WindowStateCopyWith<$Res> {
  factory _$WindowStateCopyWith(_WindowState value, $Res Function(_WindowState) _then) = __$WindowStateCopyWithImpl;
@override @useResult
$Res call({
 bool isMaximized, bool isMinimized, Future<void> Function() toggleMaximize, Future<void> Function() minimize, Future<void> Function() close, Future<void> Function() startDrag, Future<void> Function() showPopupMenu
});




}
/// @nodoc
class __$WindowStateCopyWithImpl<$Res>
    implements _$WindowStateCopyWith<$Res> {
  __$WindowStateCopyWithImpl(this._self, this._then);

  final _WindowState _self;
  final $Res Function(_WindowState) _then;

/// Create a copy of WindowState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isMaximized = null,Object? isMinimized = null,Object? toggleMaximize = null,Object? minimize = null,Object? close = null,Object? startDrag = null,Object? showPopupMenu = null,}) {
  return _then(_WindowState(
isMaximized: null == isMaximized ? _self.isMaximized : isMaximized // ignore: cast_nullable_to_non_nullable
as bool,isMinimized: null == isMinimized ? _self.isMinimized : isMinimized // ignore: cast_nullable_to_non_nullable
as bool,toggleMaximize: null == toggleMaximize ? _self.toggleMaximize : toggleMaximize // ignore: cast_nullable_to_non_nullable
as Future<void> Function(),minimize: null == minimize ? _self.minimize : minimize // ignore: cast_nullable_to_non_nullable
as Future<void> Function(),close: null == close ? _self.close : close // ignore: cast_nullable_to_non_nullable
as Future<void> Function(),startDrag: null == startDrag ? _self.startDrag : startDrag // ignore: cast_nullable_to_non_nullable
as Future<void> Function(),showPopupMenu: null == showPopupMenu ? _self.showPopupMenu : showPopupMenu // ignore: cast_nullable_to_non_nullable
as Future<void> Function(),
  ));
}


}

// dart format on
