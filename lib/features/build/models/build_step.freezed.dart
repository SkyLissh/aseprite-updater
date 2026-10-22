// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'build_step.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BuildStep {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is BuildStep);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'BuildStep()';
}


}

/// @nodoc
class $BuildStepCopyWith<$Res>  {
$BuildStepCopyWith(BuildStep _, $Res Function(BuildStep) __);
}


/// Adds pattern-matching-related methods to [BuildStep].
extension BuildStepPatterns on BuildStep {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Preparing value)?  preparing,TResult Function( Cloning value)?  cloning,TResult Function( DownloadingSkia value)?  downloadingSkia,TResult Function( Configuring value)?  configuring,TResult Function( Compiling value)?  compiling,TResult Function( Deploying value)?  deploying,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Preparing() when preparing != null:
return preparing(_that);case Cloning() when cloning != null:
return cloning(_that);case DownloadingSkia() when downloadingSkia != null:
return downloadingSkia(_that);case Configuring() when configuring != null:
return configuring(_that);case Compiling() when compiling != null:
return compiling(_that);case Deploying() when deploying != null:
return deploying(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Preparing value)  preparing,required TResult Function( Cloning value)  cloning,required TResult Function( DownloadingSkia value)  downloadingSkia,required TResult Function( Configuring value)  configuring,required TResult Function( Compiling value)  compiling,required TResult Function( Deploying value)  deploying,}){
final _that = this;
switch (_that) {
case Preparing():
return preparing(_that);case Cloning():
return cloning(_that);case DownloadingSkia():
return downloadingSkia(_that);case Configuring():
return configuring(_that);case Compiling():
return compiling(_that);case Deploying():
return deploying(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Preparing value)?  preparing,TResult? Function( Cloning value)?  cloning,TResult? Function( DownloadingSkia value)?  downloadingSkia,TResult? Function( Configuring value)?  configuring,TResult? Function( Compiling value)?  compiling,TResult? Function( Deploying value)?  deploying,}){
final _that = this;
switch (_that) {
case Preparing() when preparing != null:
return preparing(_that);case Cloning() when cloning != null:
return cloning(_that);case DownloadingSkia() when downloadingSkia != null:
return downloadingSkia(_that);case Configuring() when configuring != null:
return configuring(_that);case Compiling() when compiling != null:
return compiling(_that);case Deploying() when deploying != null:
return deploying(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  preparing,TResult Function()?  cloning,TResult Function( int receivedBytes,  int? totalBytes)?  downloadingSkia,TResult Function()?  configuring,TResult Function( int completedTasks,  int? totalTasks)?  compiling,TResult Function()?  deploying,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Preparing() when preparing != null:
return preparing();case Cloning() when cloning != null:
return cloning();case DownloadingSkia() when downloadingSkia != null:
return downloadingSkia(_that.receivedBytes,_that.totalBytes);case Configuring() when configuring != null:
return configuring();case Compiling() when compiling != null:
return compiling(_that.completedTasks,_that.totalTasks);case Deploying() when deploying != null:
return deploying();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  preparing,required TResult Function()  cloning,required TResult Function( int receivedBytes,  int? totalBytes)  downloadingSkia,required TResult Function()  configuring,required TResult Function( int completedTasks,  int? totalTasks)  compiling,required TResult Function()  deploying,}) {final _that = this;
switch (_that) {
case Preparing():
return preparing();case Cloning():
return cloning();case DownloadingSkia():
return downloadingSkia(_that.receivedBytes,_that.totalBytes);case Configuring():
return configuring();case Compiling():
return compiling(_that.completedTasks,_that.totalTasks);case Deploying():
return deploying();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  preparing,TResult? Function()?  cloning,TResult? Function( int receivedBytes,  int? totalBytes)?  downloadingSkia,TResult? Function()?  configuring,TResult? Function( int completedTasks,  int? totalTasks)?  compiling,TResult? Function()?  deploying,}) {final _that = this;
switch (_that) {
case Preparing() when preparing != null:
return preparing();case Cloning() when cloning != null:
return cloning();case DownloadingSkia() when downloadingSkia != null:
return downloadingSkia(_that.receivedBytes,_that.totalBytes);case Configuring() when configuring != null:
return configuring();case Compiling() when compiling != null:
return compiling(_that.completedTasks,_that.totalTasks);case Deploying() when deploying != null:
return deploying();case _:
  return null;

}
}

}

/// @nodoc


class Preparing extends BuildStep {
  const Preparing(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Preparing);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'BuildStep.preparing()';
}


}




/// @nodoc


class Cloning extends BuildStep {
  const Cloning(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Cloning);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'BuildStep.cloning()';
}


}




/// @nodoc


class DownloadingSkia extends BuildStep {
  const DownloadingSkia({required this.receivedBytes, this.totalBytes}): super._();
  

 final  int receivedBytes;
 final  int? totalBytes;

/// Create a copy of BuildStep
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DownloadingSkiaCopyWith<DownloadingSkia> get copyWith => _$DownloadingSkiaCopyWithImpl<DownloadingSkia>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadingSkia&&(identical(other.receivedBytes, receivedBytes) || other.receivedBytes == receivedBytes)&&(identical(other.totalBytes, totalBytes) || other.totalBytes == totalBytes));
}


@override
int get hashCode {
    return Object.hash(runtimeType,receivedBytes,totalBytes);
}

@override
String toString() {
    return 'BuildStep.downloadingSkia(receivedBytes: $receivedBytes, totalBytes: $totalBytes)';
}


}

/// @nodoc
abstract mixin class $DownloadingSkiaCopyWith<$Res> implements $BuildStepCopyWith<$Res> {
  factory $DownloadingSkiaCopyWith(DownloadingSkia value, $Res Function(DownloadingSkia) _then) = _$DownloadingSkiaCopyWithImpl;
@useResult
$Res call({
 int receivedBytes, int? totalBytes
});




}
/// @nodoc
class _$DownloadingSkiaCopyWithImpl<$Res>
    implements $DownloadingSkiaCopyWith<$Res> {
  _$DownloadingSkiaCopyWithImpl(this._self, this._then);

  final DownloadingSkia _self;
  final $Res Function(DownloadingSkia) _then;

/// Create a copy of BuildStep
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? receivedBytes = null,Object? totalBytes = freezed,}) {
  return _then(DownloadingSkia(
receivedBytes: null == receivedBytes ? _self.receivedBytes : receivedBytes // ignore: cast_nullable_to_non_nullable
as int,totalBytes: freezed == totalBytes ? _self.totalBytes : totalBytes // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc


class Configuring extends BuildStep {
  const Configuring(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Configuring);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'BuildStep.configuring()';
}


}




/// @nodoc


class Compiling extends BuildStep {
  const Compiling({required this.completedTasks, this.totalTasks}): super._();
  

 final  int completedTasks;
 final  int? totalTasks;

/// Create a copy of BuildStep
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompilingCopyWith<Compiling> get copyWith => _$CompilingCopyWithImpl<Compiling>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Compiling&&(identical(other.completedTasks, completedTasks) || other.completedTasks == completedTasks)&&(identical(other.totalTasks, totalTasks) || other.totalTasks == totalTasks));
}


@override
int get hashCode {
    return Object.hash(runtimeType,completedTasks,totalTasks);
}

@override
String toString() {
    return 'BuildStep.compiling(completedTasks: $completedTasks, totalTasks: $totalTasks)';
}


}

/// @nodoc
abstract mixin class $CompilingCopyWith<$Res> implements $BuildStepCopyWith<$Res> {
  factory $CompilingCopyWith(Compiling value, $Res Function(Compiling) _then) = _$CompilingCopyWithImpl;
@useResult
$Res call({
 int completedTasks, int? totalTasks
});




}
/// @nodoc
class _$CompilingCopyWithImpl<$Res>
    implements $CompilingCopyWith<$Res> {
  _$CompilingCopyWithImpl(this._self, this._then);

  final Compiling _self;
  final $Res Function(Compiling) _then;

/// Create a copy of BuildStep
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? completedTasks = null,Object? totalTasks = freezed,}) {
  return _then(Compiling(
completedTasks: null == completedTasks ? _self.completedTasks : completedTasks // ignore: cast_nullable_to_non_nullable
as int,totalTasks: freezed == totalTasks ? _self.totalTasks : totalTasks // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc


class Deploying extends BuildStep {
  const Deploying(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Deploying);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'BuildStep.deploying()';
}


}




// dart format on
