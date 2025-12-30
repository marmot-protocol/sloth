// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'messages.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MessageStreamItem {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageStreamItem);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MessageStreamItem()';
}


}

/// @nodoc
class $MessageStreamItemCopyWith<$Res>  {
$MessageStreamItemCopyWith(MessageStreamItem _, $Res Function(MessageStreamItem) __);
}


/// Adds pattern-matching-related methods to [MessageStreamItem].
extension MessageStreamItemPatterns on MessageStreamItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( MessageStreamItem_InitialSnapshot value)?  initialSnapshot,TResult Function( MessageStreamItem_Update value)?  update,required TResult orElse(),}){
final _that = this;
switch (_that) {
case MessageStreamItem_InitialSnapshot() when initialSnapshot != null:
return initialSnapshot(_that);case MessageStreamItem_Update() when update != null:
return update(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( MessageStreamItem_InitialSnapshot value)  initialSnapshot,required TResult Function( MessageStreamItem_Update value)  update,}){
final _that = this;
switch (_that) {
case MessageStreamItem_InitialSnapshot():
return initialSnapshot(_that);case MessageStreamItem_Update():
return update(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( MessageStreamItem_InitialSnapshot value)?  initialSnapshot,TResult? Function( MessageStreamItem_Update value)?  update,}){
final _that = this;
switch (_that) {
case MessageStreamItem_InitialSnapshot() when initialSnapshot != null:
return initialSnapshot(_that);case MessageStreamItem_Update() when update != null:
return update(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( List<ChatMessage> messages)?  initialSnapshot,TResult Function( MessageUpdate update)?  update,required TResult orElse(),}) {final _that = this;
switch (_that) {
case MessageStreamItem_InitialSnapshot() when initialSnapshot != null:
return initialSnapshot(_that.messages);case MessageStreamItem_Update() when update != null:
return update(_that.update);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( List<ChatMessage> messages)  initialSnapshot,required TResult Function( MessageUpdate update)  update,}) {final _that = this;
switch (_that) {
case MessageStreamItem_InitialSnapshot():
return initialSnapshot(_that.messages);case MessageStreamItem_Update():
return update(_that.update);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( List<ChatMessage> messages)?  initialSnapshot,TResult? Function( MessageUpdate update)?  update,}) {final _that = this;
switch (_that) {
case MessageStreamItem_InitialSnapshot() when initialSnapshot != null:
return initialSnapshot(_that.messages);case MessageStreamItem_Update() when update != null:
return update(_that.update);case _:
  return null;

}
}

}

/// @nodoc


class MessageStreamItem_InitialSnapshot extends MessageStreamItem {
  const MessageStreamItem_InitialSnapshot({required final  List<ChatMessage> messages}): _messages = messages,super._();
  

 final  List<ChatMessage> _messages;
 List<ChatMessage> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}


/// Create a copy of MessageStreamItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageStreamItem_InitialSnapshotCopyWith<MessageStreamItem_InitialSnapshot> get copyWith => _$MessageStreamItem_InitialSnapshotCopyWithImpl<MessageStreamItem_InitialSnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageStreamItem_InitialSnapshot&&const DeepCollectionEquality().equals(other._messages, _messages));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_messages));

@override
String toString() {
  return 'MessageStreamItem.initialSnapshot(messages: $messages)';
}


}

/// @nodoc
abstract mixin class $MessageStreamItem_InitialSnapshotCopyWith<$Res> implements $MessageStreamItemCopyWith<$Res> {
  factory $MessageStreamItem_InitialSnapshotCopyWith(MessageStreamItem_InitialSnapshot value, $Res Function(MessageStreamItem_InitialSnapshot) _then) = _$MessageStreamItem_InitialSnapshotCopyWithImpl;
@useResult
$Res call({
 List<ChatMessage> messages
});




}
/// @nodoc
class _$MessageStreamItem_InitialSnapshotCopyWithImpl<$Res>
    implements $MessageStreamItem_InitialSnapshotCopyWith<$Res> {
  _$MessageStreamItem_InitialSnapshotCopyWithImpl(this._self, this._then);

  final MessageStreamItem_InitialSnapshot _self;
  final $Res Function(MessageStreamItem_InitialSnapshot) _then;

/// Create a copy of MessageStreamItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? messages = null,}) {
  return _then(MessageStreamItem_InitialSnapshot(
messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<ChatMessage>,
  ));
}


}

/// @nodoc


class MessageStreamItem_Update extends MessageStreamItem {
  const MessageStreamItem_Update({required this.update}): super._();
  

 final  MessageUpdate update;

/// Create a copy of MessageStreamItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageStreamItem_UpdateCopyWith<MessageStreamItem_Update> get copyWith => _$MessageStreamItem_UpdateCopyWithImpl<MessageStreamItem_Update>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageStreamItem_Update&&(identical(other.update, update) || other.update == update));
}


@override
int get hashCode => Object.hash(runtimeType,update);

@override
String toString() {
  return 'MessageStreamItem.update(update: $update)';
}


}

/// @nodoc
abstract mixin class $MessageStreamItem_UpdateCopyWith<$Res> implements $MessageStreamItemCopyWith<$Res> {
  factory $MessageStreamItem_UpdateCopyWith(MessageStreamItem_Update value, $Res Function(MessageStreamItem_Update) _then) = _$MessageStreamItem_UpdateCopyWithImpl;
@useResult
$Res call({
 MessageUpdate update
});




}
/// @nodoc
class _$MessageStreamItem_UpdateCopyWithImpl<$Res>
    implements $MessageStreamItem_UpdateCopyWith<$Res> {
  _$MessageStreamItem_UpdateCopyWithImpl(this._self, this._then);

  final MessageStreamItem_Update _self;
  final $Res Function(MessageStreamItem_Update) _then;

/// Create a copy of MessageStreamItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? update = null,}) {
  return _then(MessageStreamItem_Update(
update: null == update ? _self.update : update // ignore: cast_nullable_to_non_nullable
as MessageUpdate,
  ));
}


}

// dart format on
