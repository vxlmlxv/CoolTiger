// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Guardian {

 String get id; String get email; String get name;
/// Create a copy of Guardian
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GuardianCopyWith<Guardian> get copyWith => _$GuardianCopyWithImpl<Guardian>(this as Guardian, _$identity);

  /// Serializes this Guardian to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Guardian&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,name);

@override
String toString() {
  return 'Guardian(id: $id, email: $email, name: $name)';
}


}

/// @nodoc
abstract mixin class $GuardianCopyWith<$Res>  {
  factory $GuardianCopyWith(Guardian value, $Res Function(Guardian) _then) = _$GuardianCopyWithImpl;
@useResult
$Res call({
 String id, String email, String name
});




}
/// @nodoc
class _$GuardianCopyWithImpl<$Res>
    implements $GuardianCopyWith<$Res> {
  _$GuardianCopyWithImpl(this._self, this._then);

  final Guardian _self;
  final $Res Function(Guardian) _then;

/// Create a copy of Guardian
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Guardian].
extension GuardianPatterns on Guardian {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Guardian value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Guardian() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Guardian value)  $default,){
final _that = this;
switch (_that) {
case _Guardian():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Guardian value)?  $default,){
final _that = this;
switch (_that) {
case _Guardian() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String email,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Guardian() when $default != null:
return $default(_that.id,_that.email,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String email,  String name)  $default,) {final _that = this;
switch (_that) {
case _Guardian():
return $default(_that.id,_that.email,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String email,  String name)?  $default,) {final _that = this;
switch (_that) {
case _Guardian() when $default != null:
return $default(_that.id,_that.email,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Guardian implements Guardian {
  const _Guardian({required this.id, required this.email, required this.name});
  factory _Guardian.fromJson(Map<String, dynamic> json) => _$GuardianFromJson(json);

@override final  String id;
@override final  String email;
@override final  String name;

/// Create a copy of Guardian
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuardianCopyWith<_Guardian> get copyWith => __$GuardianCopyWithImpl<_Guardian>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GuardianToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Guardian&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,name);

@override
String toString() {
  return 'Guardian(id: $id, email: $email, name: $name)';
}


}

/// @nodoc
abstract mixin class _$GuardianCopyWith<$Res> implements $GuardianCopyWith<$Res> {
  factory _$GuardianCopyWith(_Guardian value, $Res Function(_Guardian) _then) = __$GuardianCopyWithImpl;
@override @useResult
$Res call({
 String id, String email, String name
});




}
/// @nodoc
class __$GuardianCopyWithImpl<$Res>
    implements _$GuardianCopyWith<$Res> {
  __$GuardianCopyWithImpl(this._self, this._then);

  final _Guardian _self;
  final $Res Function(_Guardian) _then;

/// Create a copy of Guardian
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? name = null,}) {
  return _then(_Guardian(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SeniorSettings {

 String get checkinTime; bool get proactiveCall;
/// Create a copy of SeniorSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeniorSettingsCopyWith<SeniorSettings> get copyWith => _$SeniorSettingsCopyWithImpl<SeniorSettings>(this as SeniorSettings, _$identity);

  /// Serializes this SeniorSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SeniorSettings&&(identical(other.checkinTime, checkinTime) || other.checkinTime == checkinTime)&&(identical(other.proactiveCall, proactiveCall) || other.proactiveCall == proactiveCall));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,checkinTime,proactiveCall);

@override
String toString() {
  return 'SeniorSettings(checkinTime: $checkinTime, proactiveCall: $proactiveCall)';
}


}

/// @nodoc
abstract mixin class $SeniorSettingsCopyWith<$Res>  {
  factory $SeniorSettingsCopyWith(SeniorSettings value, $Res Function(SeniorSettings) _then) = _$SeniorSettingsCopyWithImpl;
@useResult
$Res call({
 String checkinTime, bool proactiveCall
});




}
/// @nodoc
class _$SeniorSettingsCopyWithImpl<$Res>
    implements $SeniorSettingsCopyWith<$Res> {
  _$SeniorSettingsCopyWithImpl(this._self, this._then);

  final SeniorSettings _self;
  final $Res Function(SeniorSettings) _then;

/// Create a copy of SeniorSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? checkinTime = null,Object? proactiveCall = null,}) {
  return _then(_self.copyWith(
checkinTime: null == checkinTime ? _self.checkinTime : checkinTime // ignore: cast_nullable_to_non_nullable
as String,proactiveCall: null == proactiveCall ? _self.proactiveCall : proactiveCall // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SeniorSettings].
extension SeniorSettingsPatterns on SeniorSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SeniorSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SeniorSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SeniorSettings value)  $default,){
final _that = this;
switch (_that) {
case _SeniorSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SeniorSettings value)?  $default,){
final _that = this;
switch (_that) {
case _SeniorSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String checkinTime,  bool proactiveCall)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SeniorSettings() when $default != null:
return $default(_that.checkinTime,_that.proactiveCall);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String checkinTime,  bool proactiveCall)  $default,) {final _that = this;
switch (_that) {
case _SeniorSettings():
return $default(_that.checkinTime,_that.proactiveCall);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String checkinTime,  bool proactiveCall)?  $default,) {final _that = this;
switch (_that) {
case _SeniorSettings() when $default != null:
return $default(_that.checkinTime,_that.proactiveCall);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SeniorSettings implements SeniorSettings {
  const _SeniorSettings({required this.checkinTime, this.proactiveCall = true});
  factory _SeniorSettings.fromJson(Map<String, dynamic> json) => _$SeniorSettingsFromJson(json);

@override final  String checkinTime;
@override@JsonKey() final  bool proactiveCall;

/// Create a copy of SeniorSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SeniorSettingsCopyWith<_SeniorSettings> get copyWith => __$SeniorSettingsCopyWithImpl<_SeniorSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SeniorSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SeniorSettings&&(identical(other.checkinTime, checkinTime) || other.checkinTime == checkinTime)&&(identical(other.proactiveCall, proactiveCall) || other.proactiveCall == proactiveCall));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,checkinTime,proactiveCall);

@override
String toString() {
  return 'SeniorSettings(checkinTime: $checkinTime, proactiveCall: $proactiveCall)';
}


}

/// @nodoc
abstract mixin class _$SeniorSettingsCopyWith<$Res> implements $SeniorSettingsCopyWith<$Res> {
  factory _$SeniorSettingsCopyWith(_SeniorSettings value, $Res Function(_SeniorSettings) _then) = __$SeniorSettingsCopyWithImpl;
@override @useResult
$Res call({
 String checkinTime, bool proactiveCall
});




}
/// @nodoc
class __$SeniorSettingsCopyWithImpl<$Res>
    implements _$SeniorSettingsCopyWith<$Res> {
  __$SeniorSettingsCopyWithImpl(this._self, this._then);

  final _SeniorSettings _self;
  final $Res Function(_SeniorSettings) _then;

/// Create a copy of SeniorSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? checkinTime = null,Object? proactiveCall = null,}) {
  return _then(_SeniorSettings(
checkinTime: null == checkinTime ? _self.checkinTime : checkinTime // ignore: cast_nullable_to_non_nullable
as String,proactiveCall: null == proactiveCall ? _self.proactiveCall : proactiveCall // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$Senior {

 String get id; String get guardianId; String get name; SeniorSettings get settings; Map<String, dynamic> get personalHistory;
/// Create a copy of Senior
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeniorCopyWith<Senior> get copyWith => _$SeniorCopyWithImpl<Senior>(this as Senior, _$identity);

  /// Serializes this Senior to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Senior&&(identical(other.id, id) || other.id == id)&&(identical(other.guardianId, guardianId) || other.guardianId == guardianId)&&(identical(other.name, name) || other.name == name)&&(identical(other.settings, settings) || other.settings == settings)&&const DeepCollectionEquality().equals(other.personalHistory, personalHistory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,guardianId,name,settings,const DeepCollectionEquality().hash(personalHistory));

@override
String toString() {
  return 'Senior(id: $id, guardianId: $guardianId, name: $name, settings: $settings, personalHistory: $personalHistory)';
}


}

/// @nodoc
abstract mixin class $SeniorCopyWith<$Res>  {
  factory $SeniorCopyWith(Senior value, $Res Function(Senior) _then) = _$SeniorCopyWithImpl;
@useResult
$Res call({
 String id, String guardianId, String name, SeniorSettings settings, Map<String, dynamic> personalHistory
});


$SeniorSettingsCopyWith<$Res> get settings;

}
/// @nodoc
class _$SeniorCopyWithImpl<$Res>
    implements $SeniorCopyWith<$Res> {
  _$SeniorCopyWithImpl(this._self, this._then);

  final Senior _self;
  final $Res Function(Senior) _then;

/// Create a copy of Senior
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? guardianId = null,Object? name = null,Object? settings = null,Object? personalHistory = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,guardianId: null == guardianId ? _self.guardianId : guardianId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as SeniorSettings,personalHistory: null == personalHistory ? _self.personalHistory : personalHistory // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}
/// Create a copy of Senior
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SeniorSettingsCopyWith<$Res> get settings {
  
  return $SeniorSettingsCopyWith<$Res>(_self.settings, (value) {
    return _then(_self.copyWith(settings: value));
  });
}
}


/// Adds pattern-matching-related methods to [Senior].
extension SeniorPatterns on Senior {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Senior value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Senior() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Senior value)  $default,){
final _that = this;
switch (_that) {
case _Senior():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Senior value)?  $default,){
final _that = this;
switch (_that) {
case _Senior() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String guardianId,  String name,  SeniorSettings settings,  Map<String, dynamic> personalHistory)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Senior() when $default != null:
return $default(_that.id,_that.guardianId,_that.name,_that.settings,_that.personalHistory);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String guardianId,  String name,  SeniorSettings settings,  Map<String, dynamic> personalHistory)  $default,) {final _that = this;
switch (_that) {
case _Senior():
return $default(_that.id,_that.guardianId,_that.name,_that.settings,_that.personalHistory);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String guardianId,  String name,  SeniorSettings settings,  Map<String, dynamic> personalHistory)?  $default,) {final _that = this;
switch (_that) {
case _Senior() when $default != null:
return $default(_that.id,_that.guardianId,_that.name,_that.settings,_that.personalHistory);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Senior implements Senior {
  const _Senior({required this.id, required this.guardianId, required this.name, required this.settings, final  Map<String, dynamic> personalHistory = const <String, dynamic>{}}): _personalHistory = personalHistory;
  factory _Senior.fromJson(Map<String, dynamic> json) => _$SeniorFromJson(json);

@override final  String id;
@override final  String guardianId;
@override final  String name;
@override final  SeniorSettings settings;
 final  Map<String, dynamic> _personalHistory;
@override@JsonKey() Map<String, dynamic> get personalHistory {
  if (_personalHistory is EqualUnmodifiableMapView) return _personalHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_personalHistory);
}


/// Create a copy of Senior
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SeniorCopyWith<_Senior> get copyWith => __$SeniorCopyWithImpl<_Senior>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SeniorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Senior&&(identical(other.id, id) || other.id == id)&&(identical(other.guardianId, guardianId) || other.guardianId == guardianId)&&(identical(other.name, name) || other.name == name)&&(identical(other.settings, settings) || other.settings == settings)&&const DeepCollectionEquality().equals(other._personalHistory, _personalHistory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,guardianId,name,settings,const DeepCollectionEquality().hash(_personalHistory));

@override
String toString() {
  return 'Senior(id: $id, guardianId: $guardianId, name: $name, settings: $settings, personalHistory: $personalHistory)';
}


}

/// @nodoc
abstract mixin class _$SeniorCopyWith<$Res> implements $SeniorCopyWith<$Res> {
  factory _$SeniorCopyWith(_Senior value, $Res Function(_Senior) _then) = __$SeniorCopyWithImpl;
@override @useResult
$Res call({
 String id, String guardianId, String name, SeniorSettings settings, Map<String, dynamic> personalHistory
});


@override $SeniorSettingsCopyWith<$Res> get settings;

}
/// @nodoc
class __$SeniorCopyWithImpl<$Res>
    implements _$SeniorCopyWith<$Res> {
  __$SeniorCopyWithImpl(this._self, this._then);

  final _Senior _self;
  final $Res Function(_Senior) _then;

/// Create a copy of Senior
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? guardianId = null,Object? name = null,Object? settings = null,Object? personalHistory = null,}) {
  return _then(_Senior(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,guardianId: null == guardianId ? _self.guardianId : guardianId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as SeniorSettings,personalHistory: null == personalHistory ? _self._personalHistory : personalHistory // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

/// Create a copy of Senior
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SeniorSettingsCopyWith<$Res> get settings {
  
  return $SeniorSettingsCopyWith<$Res>(_self.settings, (value) {
    return _then(_self.copyWith(settings: value));
  });
}
}


/// @nodoc
mixin _$ConversationLog {

 String get id; String get seniorId; String get guardianId; DateTime get timestamp; ConversationSpeaker get speaker; String get transcript; String? get audioUrl; String get analysisStatus;
/// Create a copy of ConversationLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConversationLogCopyWith<ConversationLog> get copyWith => _$ConversationLogCopyWithImpl<ConversationLog>(this as ConversationLog, _$identity);

  /// Serializes this ConversationLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConversationLog&&(identical(other.id, id) || other.id == id)&&(identical(other.seniorId, seniorId) || other.seniorId == seniorId)&&(identical(other.guardianId, guardianId) || other.guardianId == guardianId)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.speaker, speaker) || other.speaker == speaker)&&(identical(other.transcript, transcript) || other.transcript == transcript)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl)&&(identical(other.analysisStatus, analysisStatus) || other.analysisStatus == analysisStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,seniorId,guardianId,timestamp,speaker,transcript,audioUrl,analysisStatus);

@override
String toString() {
  return 'ConversationLog(id: $id, seniorId: $seniorId, guardianId: $guardianId, timestamp: $timestamp, speaker: $speaker, transcript: $transcript, audioUrl: $audioUrl, analysisStatus: $analysisStatus)';
}


}

/// @nodoc
abstract mixin class $ConversationLogCopyWith<$Res>  {
  factory $ConversationLogCopyWith(ConversationLog value, $Res Function(ConversationLog) _then) = _$ConversationLogCopyWithImpl;
@useResult
$Res call({
 String id, String seniorId, String guardianId, DateTime timestamp, ConversationSpeaker speaker, String transcript, String? audioUrl, String analysisStatus
});




}
/// @nodoc
class _$ConversationLogCopyWithImpl<$Res>
    implements $ConversationLogCopyWith<$Res> {
  _$ConversationLogCopyWithImpl(this._self, this._then);

  final ConversationLog _self;
  final $Res Function(ConversationLog) _then;

/// Create a copy of ConversationLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? seniorId = null,Object? guardianId = null,Object? timestamp = null,Object? speaker = null,Object? transcript = null,Object? audioUrl = freezed,Object? analysisStatus = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,seniorId: null == seniorId ? _self.seniorId : seniorId // ignore: cast_nullable_to_non_nullable
as String,guardianId: null == guardianId ? _self.guardianId : guardianId // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,speaker: null == speaker ? _self.speaker : speaker // ignore: cast_nullable_to_non_nullable
as ConversationSpeaker,transcript: null == transcript ? _self.transcript : transcript // ignore: cast_nullable_to_non_nullable
as String,audioUrl: freezed == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String?,analysisStatus: null == analysisStatus ? _self.analysisStatus : analysisStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ConversationLog].
extension ConversationLogPatterns on ConversationLog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConversationLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConversationLog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConversationLog value)  $default,){
final _that = this;
switch (_that) {
case _ConversationLog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConversationLog value)?  $default,){
final _that = this;
switch (_that) {
case _ConversationLog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String seniorId,  String guardianId,  DateTime timestamp,  ConversationSpeaker speaker,  String transcript,  String? audioUrl,  String analysisStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConversationLog() when $default != null:
return $default(_that.id,_that.seniorId,_that.guardianId,_that.timestamp,_that.speaker,_that.transcript,_that.audioUrl,_that.analysisStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String seniorId,  String guardianId,  DateTime timestamp,  ConversationSpeaker speaker,  String transcript,  String? audioUrl,  String analysisStatus)  $default,) {final _that = this;
switch (_that) {
case _ConversationLog():
return $default(_that.id,_that.seniorId,_that.guardianId,_that.timestamp,_that.speaker,_that.transcript,_that.audioUrl,_that.analysisStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String seniorId,  String guardianId,  DateTime timestamp,  ConversationSpeaker speaker,  String transcript,  String? audioUrl,  String analysisStatus)?  $default,) {final _that = this;
switch (_that) {
case _ConversationLog() when $default != null:
return $default(_that.id,_that.seniorId,_that.guardianId,_that.timestamp,_that.speaker,_that.transcript,_that.audioUrl,_that.analysisStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConversationLog implements ConversationLog {
  const _ConversationLog({required this.id, required this.seniorId, required this.guardianId, required this.timestamp, required this.speaker, required this.transcript, this.audioUrl, this.analysisStatus = 'pending'});
  factory _ConversationLog.fromJson(Map<String, dynamic> json) => _$ConversationLogFromJson(json);

@override final  String id;
@override final  String seniorId;
@override final  String guardianId;
@override final  DateTime timestamp;
@override final  ConversationSpeaker speaker;
@override final  String transcript;
@override final  String? audioUrl;
@override@JsonKey() final  String analysisStatus;

/// Create a copy of ConversationLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConversationLogCopyWith<_ConversationLog> get copyWith => __$ConversationLogCopyWithImpl<_ConversationLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConversationLogToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConversationLog&&(identical(other.id, id) || other.id == id)&&(identical(other.seniorId, seniorId) || other.seniorId == seniorId)&&(identical(other.guardianId, guardianId) || other.guardianId == guardianId)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.speaker, speaker) || other.speaker == speaker)&&(identical(other.transcript, transcript) || other.transcript == transcript)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl)&&(identical(other.analysisStatus, analysisStatus) || other.analysisStatus == analysisStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,seniorId,guardianId,timestamp,speaker,transcript,audioUrl,analysisStatus);

@override
String toString() {
  return 'ConversationLog(id: $id, seniorId: $seniorId, guardianId: $guardianId, timestamp: $timestamp, speaker: $speaker, transcript: $transcript, audioUrl: $audioUrl, analysisStatus: $analysisStatus)';
}


}

/// @nodoc
abstract mixin class _$ConversationLogCopyWith<$Res> implements $ConversationLogCopyWith<$Res> {
  factory _$ConversationLogCopyWith(_ConversationLog value, $Res Function(_ConversationLog) _then) = __$ConversationLogCopyWithImpl;
@override @useResult
$Res call({
 String id, String seniorId, String guardianId, DateTime timestamp, ConversationSpeaker speaker, String transcript, String? audioUrl, String analysisStatus
});




}
/// @nodoc
class __$ConversationLogCopyWithImpl<$Res>
    implements _$ConversationLogCopyWith<$Res> {
  __$ConversationLogCopyWithImpl(this._self, this._then);

  final _ConversationLog _self;
  final $Res Function(_ConversationLog) _then;

/// Create a copy of ConversationLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? seniorId = null,Object? guardianId = null,Object? timestamp = null,Object? speaker = null,Object? transcript = null,Object? audioUrl = freezed,Object? analysisStatus = null,}) {
  return _then(_ConversationLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,seniorId: null == seniorId ? _self.seniorId : seniorId // ignore: cast_nullable_to_non_nullable
as String,guardianId: null == guardianId ? _self.guardianId : guardianId // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,speaker: null == speaker ? _self.speaker : speaker // ignore: cast_nullable_to_non_nullable
as ConversationSpeaker,transcript: null == transcript ? _self.transcript : transcript // ignore: cast_nullable_to_non_nullable
as String,audioUrl: freezed == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String?,analysisStatus: null == analysisStatus ? _self.analysisStatus : analysisStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$AnalysisMetrics {

 String get sentiment; int get wordCount; double get ttr; int get speakingRate;
/// Create a copy of AnalysisMetrics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalysisMetricsCopyWith<AnalysisMetrics> get copyWith => _$AnalysisMetricsCopyWithImpl<AnalysisMetrics>(this as AnalysisMetrics, _$identity);

  /// Serializes this AnalysisMetrics to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalysisMetrics&&(identical(other.sentiment, sentiment) || other.sentiment == sentiment)&&(identical(other.wordCount, wordCount) || other.wordCount == wordCount)&&(identical(other.ttr, ttr) || other.ttr == ttr)&&(identical(other.speakingRate, speakingRate) || other.speakingRate == speakingRate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sentiment,wordCount,ttr,speakingRate);

@override
String toString() {
  return 'AnalysisMetrics(sentiment: $sentiment, wordCount: $wordCount, ttr: $ttr, speakingRate: $speakingRate)';
}


}

/// @nodoc
abstract mixin class $AnalysisMetricsCopyWith<$Res>  {
  factory $AnalysisMetricsCopyWith(AnalysisMetrics value, $Res Function(AnalysisMetrics) _then) = _$AnalysisMetricsCopyWithImpl;
@useResult
$Res call({
 String sentiment, int wordCount, double ttr, int speakingRate
});




}
/// @nodoc
class _$AnalysisMetricsCopyWithImpl<$Res>
    implements $AnalysisMetricsCopyWith<$Res> {
  _$AnalysisMetricsCopyWithImpl(this._self, this._then);

  final AnalysisMetrics _self;
  final $Res Function(AnalysisMetrics) _then;

/// Create a copy of AnalysisMetrics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sentiment = null,Object? wordCount = null,Object? ttr = null,Object? speakingRate = null,}) {
  return _then(_self.copyWith(
sentiment: null == sentiment ? _self.sentiment : sentiment // ignore: cast_nullable_to_non_nullable
as String,wordCount: null == wordCount ? _self.wordCount : wordCount // ignore: cast_nullable_to_non_nullable
as int,ttr: null == ttr ? _self.ttr : ttr // ignore: cast_nullable_to_non_nullable
as double,speakingRate: null == speakingRate ? _self.speakingRate : speakingRate // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AnalysisMetrics].
extension AnalysisMetricsPatterns on AnalysisMetrics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalysisMetrics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalysisMetrics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalysisMetrics value)  $default,){
final _that = this;
switch (_that) {
case _AnalysisMetrics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalysisMetrics value)?  $default,){
final _that = this;
switch (_that) {
case _AnalysisMetrics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sentiment,  int wordCount,  double ttr,  int speakingRate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalysisMetrics() when $default != null:
return $default(_that.sentiment,_that.wordCount,_that.ttr,_that.speakingRate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sentiment,  int wordCount,  double ttr,  int speakingRate)  $default,) {final _that = this;
switch (_that) {
case _AnalysisMetrics():
return $default(_that.sentiment,_that.wordCount,_that.ttr,_that.speakingRate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sentiment,  int wordCount,  double ttr,  int speakingRate)?  $default,) {final _that = this;
switch (_that) {
case _AnalysisMetrics() when $default != null:
return $default(_that.sentiment,_that.wordCount,_that.ttr,_that.speakingRate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnalysisMetrics implements AnalysisMetrics {
  const _AnalysisMetrics({required this.sentiment, required this.wordCount, required this.ttr, required this.speakingRate});
  factory _AnalysisMetrics.fromJson(Map<String, dynamic> json) => _$AnalysisMetricsFromJson(json);

@override final  String sentiment;
@override final  int wordCount;
@override final  double ttr;
@override final  int speakingRate;

/// Create a copy of AnalysisMetrics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalysisMetricsCopyWith<_AnalysisMetrics> get copyWith => __$AnalysisMetricsCopyWithImpl<_AnalysisMetrics>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnalysisMetricsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalysisMetrics&&(identical(other.sentiment, sentiment) || other.sentiment == sentiment)&&(identical(other.wordCount, wordCount) || other.wordCount == wordCount)&&(identical(other.ttr, ttr) || other.ttr == ttr)&&(identical(other.speakingRate, speakingRate) || other.speakingRate == speakingRate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sentiment,wordCount,ttr,speakingRate);

@override
String toString() {
  return 'AnalysisMetrics(sentiment: $sentiment, wordCount: $wordCount, ttr: $ttr, speakingRate: $speakingRate)';
}


}

/// @nodoc
abstract mixin class _$AnalysisMetricsCopyWith<$Res> implements $AnalysisMetricsCopyWith<$Res> {
  factory _$AnalysisMetricsCopyWith(_AnalysisMetrics value, $Res Function(_AnalysisMetrics) _then) = __$AnalysisMetricsCopyWithImpl;
@override @useResult
$Res call({
 String sentiment, int wordCount, double ttr, int speakingRate
});




}
/// @nodoc
class __$AnalysisMetricsCopyWithImpl<$Res>
    implements _$AnalysisMetricsCopyWith<$Res> {
  __$AnalysisMetricsCopyWithImpl(this._self, this._then);

  final _AnalysisMetrics _self;
  final $Res Function(_AnalysisMetrics) _then;

/// Create a copy of AnalysisMetrics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sentiment = null,Object? wordCount = null,Object? ttr = null,Object? speakingRate = null,}) {
  return _then(_AnalysisMetrics(
sentiment: null == sentiment ? _self.sentiment : sentiment // ignore: cast_nullable_to_non_nullable
as String,wordCount: null == wordCount ? _self.wordCount : wordCount // ignore: cast_nullable_to_non_nullable
as int,ttr: null == ttr ? _self.ttr : ttr // ignore: cast_nullable_to_non_nullable
as double,speakingRate: null == speakingRate ? _self.speakingRate : speakingRate // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$AnalysisReport {

 String get id; String get seniorId; String get guardianId; DateTime get date; AnalysisMetrics get metrics; String get summary;
/// Create a copy of AnalysisReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalysisReportCopyWith<AnalysisReport> get copyWith => _$AnalysisReportCopyWithImpl<AnalysisReport>(this as AnalysisReport, _$identity);

  /// Serializes this AnalysisReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalysisReport&&(identical(other.id, id) || other.id == id)&&(identical(other.seniorId, seniorId) || other.seniorId == seniorId)&&(identical(other.guardianId, guardianId) || other.guardianId == guardianId)&&(identical(other.date, date) || other.date == date)&&(identical(other.metrics, metrics) || other.metrics == metrics)&&(identical(other.summary, summary) || other.summary == summary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,seniorId,guardianId,date,metrics,summary);

@override
String toString() {
  return 'AnalysisReport(id: $id, seniorId: $seniorId, guardianId: $guardianId, date: $date, metrics: $metrics, summary: $summary)';
}


}

/// @nodoc
abstract mixin class $AnalysisReportCopyWith<$Res>  {
  factory $AnalysisReportCopyWith(AnalysisReport value, $Res Function(AnalysisReport) _then) = _$AnalysisReportCopyWithImpl;
@useResult
$Res call({
 String id, String seniorId, String guardianId, DateTime date, AnalysisMetrics metrics, String summary
});


$AnalysisMetricsCopyWith<$Res> get metrics;

}
/// @nodoc
class _$AnalysisReportCopyWithImpl<$Res>
    implements $AnalysisReportCopyWith<$Res> {
  _$AnalysisReportCopyWithImpl(this._self, this._then);

  final AnalysisReport _self;
  final $Res Function(AnalysisReport) _then;

/// Create a copy of AnalysisReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? seniorId = null,Object? guardianId = null,Object? date = null,Object? metrics = null,Object? summary = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,seniorId: null == seniorId ? _self.seniorId : seniorId // ignore: cast_nullable_to_non_nullable
as String,guardianId: null == guardianId ? _self.guardianId : guardianId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,metrics: null == metrics ? _self.metrics : metrics // ignore: cast_nullable_to_non_nullable
as AnalysisMetrics,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of AnalysisReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalysisMetricsCopyWith<$Res> get metrics {
  
  return $AnalysisMetricsCopyWith<$Res>(_self.metrics, (value) {
    return _then(_self.copyWith(metrics: value));
  });
}
}


/// Adds pattern-matching-related methods to [AnalysisReport].
extension AnalysisReportPatterns on AnalysisReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalysisReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalysisReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalysisReport value)  $default,){
final _that = this;
switch (_that) {
case _AnalysisReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalysisReport value)?  $default,){
final _that = this;
switch (_that) {
case _AnalysisReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String seniorId,  String guardianId,  DateTime date,  AnalysisMetrics metrics,  String summary)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalysisReport() when $default != null:
return $default(_that.id,_that.seniorId,_that.guardianId,_that.date,_that.metrics,_that.summary);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String seniorId,  String guardianId,  DateTime date,  AnalysisMetrics metrics,  String summary)  $default,) {final _that = this;
switch (_that) {
case _AnalysisReport():
return $default(_that.id,_that.seniorId,_that.guardianId,_that.date,_that.metrics,_that.summary);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String seniorId,  String guardianId,  DateTime date,  AnalysisMetrics metrics,  String summary)?  $default,) {final _that = this;
switch (_that) {
case _AnalysisReport() when $default != null:
return $default(_that.id,_that.seniorId,_that.guardianId,_that.date,_that.metrics,_that.summary);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnalysisReport implements AnalysisReport {
  const _AnalysisReport({required this.id, required this.seniorId, required this.guardianId, required this.date, required this.metrics, required this.summary});
  factory _AnalysisReport.fromJson(Map<String, dynamic> json) => _$AnalysisReportFromJson(json);

@override final  String id;
@override final  String seniorId;
@override final  String guardianId;
@override final  DateTime date;
@override final  AnalysisMetrics metrics;
@override final  String summary;

/// Create a copy of AnalysisReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalysisReportCopyWith<_AnalysisReport> get copyWith => __$AnalysisReportCopyWithImpl<_AnalysisReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnalysisReportToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalysisReport&&(identical(other.id, id) || other.id == id)&&(identical(other.seniorId, seniorId) || other.seniorId == seniorId)&&(identical(other.guardianId, guardianId) || other.guardianId == guardianId)&&(identical(other.date, date) || other.date == date)&&(identical(other.metrics, metrics) || other.metrics == metrics)&&(identical(other.summary, summary) || other.summary == summary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,seniorId,guardianId,date,metrics,summary);

@override
String toString() {
  return 'AnalysisReport(id: $id, seniorId: $seniorId, guardianId: $guardianId, date: $date, metrics: $metrics, summary: $summary)';
}


}

/// @nodoc
abstract mixin class _$AnalysisReportCopyWith<$Res> implements $AnalysisReportCopyWith<$Res> {
  factory _$AnalysisReportCopyWith(_AnalysisReport value, $Res Function(_AnalysisReport) _then) = __$AnalysisReportCopyWithImpl;
@override @useResult
$Res call({
 String id, String seniorId, String guardianId, DateTime date, AnalysisMetrics metrics, String summary
});


@override $AnalysisMetricsCopyWith<$Res> get metrics;

}
/// @nodoc
class __$AnalysisReportCopyWithImpl<$Res>
    implements _$AnalysisReportCopyWith<$Res> {
  __$AnalysisReportCopyWithImpl(this._self, this._then);

  final _AnalysisReport _self;
  final $Res Function(_AnalysisReport) _then;

/// Create a copy of AnalysisReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? seniorId = null,Object? guardianId = null,Object? date = null,Object? metrics = null,Object? summary = null,}) {
  return _then(_AnalysisReport(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,seniorId: null == seniorId ? _self.seniorId : seniorId // ignore: cast_nullable_to_non_nullable
as String,guardianId: null == guardianId ? _self.guardianId : guardianId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,metrics: null == metrics ? _self.metrics : metrics // ignore: cast_nullable_to_non_nullable
as AnalysisMetrics,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of AnalysisReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalysisMetricsCopyWith<$Res> get metrics {
  
  return $AnalysisMetricsCopyWith<$Res>(_self.metrics, (value) {
    return _then(_self.copyWith(metrics: value));
  });
}
}


/// @nodoc
mixin _$TrainingModuleResponse {

 String get type;@JsonKey(name: 'tts_audio_url') String get ttsAudioUrl;@JsonKey(name: 'tts_prompt') String get ttsPrompt;@JsonKey(name: 'module_type') TrainingModuleType get moduleType;@JsonKey(name: 'module_data') Map<String, dynamic> get moduleData; String? get moduleId;
/// Create a copy of TrainingModuleResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrainingModuleResponseCopyWith<TrainingModuleResponse> get copyWith => _$TrainingModuleResponseCopyWithImpl<TrainingModuleResponse>(this as TrainingModuleResponse, _$identity);

  /// Serializes this TrainingModuleResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrainingModuleResponse&&(identical(other.type, type) || other.type == type)&&(identical(other.ttsAudioUrl, ttsAudioUrl) || other.ttsAudioUrl == ttsAudioUrl)&&(identical(other.ttsPrompt, ttsPrompt) || other.ttsPrompt == ttsPrompt)&&(identical(other.moduleType, moduleType) || other.moduleType == moduleType)&&const DeepCollectionEquality().equals(other.moduleData, moduleData)&&(identical(other.moduleId, moduleId) || other.moduleId == moduleId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,ttsAudioUrl,ttsPrompt,moduleType,const DeepCollectionEquality().hash(moduleData),moduleId);

@override
String toString() {
  return 'TrainingModuleResponse(type: $type, ttsAudioUrl: $ttsAudioUrl, ttsPrompt: $ttsPrompt, moduleType: $moduleType, moduleData: $moduleData, moduleId: $moduleId)';
}


}

/// @nodoc
abstract mixin class $TrainingModuleResponseCopyWith<$Res>  {
  factory $TrainingModuleResponseCopyWith(TrainingModuleResponse value, $Res Function(TrainingModuleResponse) _then) = _$TrainingModuleResponseCopyWithImpl;
@useResult
$Res call({
 String type,@JsonKey(name: 'tts_audio_url') String ttsAudioUrl,@JsonKey(name: 'tts_prompt') String ttsPrompt,@JsonKey(name: 'module_type') TrainingModuleType moduleType,@JsonKey(name: 'module_data') Map<String, dynamic> moduleData, String? moduleId
});




}
/// @nodoc
class _$TrainingModuleResponseCopyWithImpl<$Res>
    implements $TrainingModuleResponseCopyWith<$Res> {
  _$TrainingModuleResponseCopyWithImpl(this._self, this._then);

  final TrainingModuleResponse _self;
  final $Res Function(TrainingModuleResponse) _then;

/// Create a copy of TrainingModuleResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? ttsAudioUrl = null,Object? ttsPrompt = null,Object? moduleType = null,Object? moduleData = null,Object? moduleId = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,ttsAudioUrl: null == ttsAudioUrl ? _self.ttsAudioUrl : ttsAudioUrl // ignore: cast_nullable_to_non_nullable
as String,ttsPrompt: null == ttsPrompt ? _self.ttsPrompt : ttsPrompt // ignore: cast_nullable_to_non_nullable
as String,moduleType: null == moduleType ? _self.moduleType : moduleType // ignore: cast_nullable_to_non_nullable
as TrainingModuleType,moduleData: null == moduleData ? _self.moduleData : moduleData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,moduleId: freezed == moduleId ? _self.moduleId : moduleId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TrainingModuleResponse].
extension TrainingModuleResponsePatterns on TrainingModuleResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrainingModuleResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrainingModuleResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrainingModuleResponse value)  $default,){
final _that = this;
switch (_that) {
case _TrainingModuleResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrainingModuleResponse value)?  $default,){
final _that = this;
switch (_that) {
case _TrainingModuleResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type, @JsonKey(name: 'tts_audio_url')  String ttsAudioUrl, @JsonKey(name: 'tts_prompt')  String ttsPrompt, @JsonKey(name: 'module_type')  TrainingModuleType moduleType, @JsonKey(name: 'module_data')  Map<String, dynamic> moduleData,  String? moduleId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrainingModuleResponse() when $default != null:
return $default(_that.type,_that.ttsAudioUrl,_that.ttsPrompt,_that.moduleType,_that.moduleData,_that.moduleId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type, @JsonKey(name: 'tts_audio_url')  String ttsAudioUrl, @JsonKey(name: 'tts_prompt')  String ttsPrompt, @JsonKey(name: 'module_type')  TrainingModuleType moduleType, @JsonKey(name: 'module_data')  Map<String, dynamic> moduleData,  String? moduleId)  $default,) {final _that = this;
switch (_that) {
case _TrainingModuleResponse():
return $default(_that.type,_that.ttsAudioUrl,_that.ttsPrompt,_that.moduleType,_that.moduleData,_that.moduleId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type, @JsonKey(name: 'tts_audio_url')  String ttsAudioUrl, @JsonKey(name: 'tts_prompt')  String ttsPrompt, @JsonKey(name: 'module_type')  TrainingModuleType moduleType, @JsonKey(name: 'module_data')  Map<String, dynamic> moduleData,  String? moduleId)?  $default,) {final _that = this;
switch (_that) {
case _TrainingModuleResponse() when $default != null:
return $default(_that.type,_that.ttsAudioUrl,_that.ttsPrompt,_that.moduleType,_that.moduleData,_that.moduleId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrainingModuleResponse implements TrainingModuleResponse {
  const _TrainingModuleResponse({required this.type, @JsonKey(name: 'tts_audio_url') required this.ttsAudioUrl, @JsonKey(name: 'tts_prompt') required this.ttsPrompt, @JsonKey(name: 'module_type') required this.moduleType, @JsonKey(name: 'module_data') required final  Map<String, dynamic> moduleData, this.moduleId}): _moduleData = moduleData;
  factory _TrainingModuleResponse.fromJson(Map<String, dynamic> json) => _$TrainingModuleResponseFromJson(json);

@override final  String type;
@override@JsonKey(name: 'tts_audio_url') final  String ttsAudioUrl;
@override@JsonKey(name: 'tts_prompt') final  String ttsPrompt;
@override@JsonKey(name: 'module_type') final  TrainingModuleType moduleType;
 final  Map<String, dynamic> _moduleData;
@override@JsonKey(name: 'module_data') Map<String, dynamic> get moduleData {
  if (_moduleData is EqualUnmodifiableMapView) return _moduleData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_moduleData);
}

@override final  String? moduleId;

/// Create a copy of TrainingModuleResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrainingModuleResponseCopyWith<_TrainingModuleResponse> get copyWith => __$TrainingModuleResponseCopyWithImpl<_TrainingModuleResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrainingModuleResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrainingModuleResponse&&(identical(other.type, type) || other.type == type)&&(identical(other.ttsAudioUrl, ttsAudioUrl) || other.ttsAudioUrl == ttsAudioUrl)&&(identical(other.ttsPrompt, ttsPrompt) || other.ttsPrompt == ttsPrompt)&&(identical(other.moduleType, moduleType) || other.moduleType == moduleType)&&const DeepCollectionEquality().equals(other._moduleData, _moduleData)&&(identical(other.moduleId, moduleId) || other.moduleId == moduleId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,ttsAudioUrl,ttsPrompt,moduleType,const DeepCollectionEquality().hash(_moduleData),moduleId);

@override
String toString() {
  return 'TrainingModuleResponse(type: $type, ttsAudioUrl: $ttsAudioUrl, ttsPrompt: $ttsPrompt, moduleType: $moduleType, moduleData: $moduleData, moduleId: $moduleId)';
}


}

/// @nodoc
abstract mixin class _$TrainingModuleResponseCopyWith<$Res> implements $TrainingModuleResponseCopyWith<$Res> {
  factory _$TrainingModuleResponseCopyWith(_TrainingModuleResponse value, $Res Function(_TrainingModuleResponse) _then) = __$TrainingModuleResponseCopyWithImpl;
@override @useResult
$Res call({
 String type,@JsonKey(name: 'tts_audio_url') String ttsAudioUrl,@JsonKey(name: 'tts_prompt') String ttsPrompt,@JsonKey(name: 'module_type') TrainingModuleType moduleType,@JsonKey(name: 'module_data') Map<String, dynamic> moduleData, String? moduleId
});




}
/// @nodoc
class __$TrainingModuleResponseCopyWithImpl<$Res>
    implements _$TrainingModuleResponseCopyWith<$Res> {
  __$TrainingModuleResponseCopyWithImpl(this._self, this._then);

  final _TrainingModuleResponse _self;
  final $Res Function(_TrainingModuleResponse) _then;

/// Create a copy of TrainingModuleResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? ttsAudioUrl = null,Object? ttsPrompt = null,Object? moduleType = null,Object? moduleData = null,Object? moduleId = freezed,}) {
  return _then(_TrainingModuleResponse(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,ttsAudioUrl: null == ttsAudioUrl ? _self.ttsAudioUrl : ttsAudioUrl // ignore: cast_nullable_to_non_nullable
as String,ttsPrompt: null == ttsPrompt ? _self.ttsPrompt : ttsPrompt // ignore: cast_nullable_to_non_nullable
as String,moduleType: null == moduleType ? _self.moduleType : moduleType // ignore: cast_nullable_to_non_nullable
as TrainingModuleType,moduleData: null == moduleData ? _self._moduleData : moduleData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,moduleId: freezed == moduleId ? _self.moduleId : moduleId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
