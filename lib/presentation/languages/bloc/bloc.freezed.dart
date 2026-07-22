// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$LanguagesEvent {
  BuildContext get context => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(BuildContext context) fetch,
    required TResult Function(BuildContext context, LanguageModel languageModel)
        select,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(BuildContext context)? fetch,
    TResult? Function(BuildContext context, LanguageModel languageModel)?
        select,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(BuildContext context)? fetch,
    TResult Function(BuildContext context, LanguageModel languageModel)? select,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Fetch value) fetch,
    required TResult Function(_Select value) select,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Fetch value)? fetch,
    TResult? Function(_Select value)? select,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Fetch value)? fetch,
    TResult Function(_Select value)? select,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $LanguagesEventCopyWith<LanguagesEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LanguagesEventCopyWith<$Res> {
  factory $LanguagesEventCopyWith(
          LanguagesEvent value, $Res Function(LanguagesEvent) then) =
      _$LanguagesEventCopyWithImpl<$Res, LanguagesEvent>;
  @useResult
  $Res call({BuildContext context});
}

/// @nodoc
class _$LanguagesEventCopyWithImpl<$Res, $Val extends LanguagesEvent>
    implements $LanguagesEventCopyWith<$Res> {
  _$LanguagesEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? context = null,
  }) {
    return _then(_value.copyWith(
      context: null == context
          ? _value.context
          : context // ignore: cast_nullable_to_non_nullable
              as BuildContext,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FetchImplCopyWith<$Res>
    implements $LanguagesEventCopyWith<$Res> {
  factory _$$FetchImplCopyWith(
          _$FetchImpl value, $Res Function(_$FetchImpl) then) =
      __$$FetchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({BuildContext context});
}

/// @nodoc
class __$$FetchImplCopyWithImpl<$Res>
    extends _$LanguagesEventCopyWithImpl<$Res, _$FetchImpl>
    implements _$$FetchImplCopyWith<$Res> {
  __$$FetchImplCopyWithImpl(
      _$FetchImpl _value, $Res Function(_$FetchImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? context = null,
  }) {
    return _then(_$FetchImpl(
      context: null == context
          ? _value.context
          : context // ignore: cast_nullable_to_non_nullable
              as BuildContext,
    ));
  }
}

/// @nodoc

class _$FetchImpl implements _Fetch {
  const _$FetchImpl({required this.context});

  @override
  final BuildContext context;

  @override
  String toString() {
    return 'LanguagesEvent.fetch(context: $context)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FetchImpl &&
            (identical(other.context, context) || other.context == context));
  }

  @override
  int get hashCode => Object.hash(runtimeType, context);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FetchImplCopyWith<_$FetchImpl> get copyWith =>
      __$$FetchImplCopyWithImpl<_$FetchImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(BuildContext context) fetch,
    required TResult Function(BuildContext context, LanguageModel languageModel)
        select,
  }) {
    return fetch(context);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(BuildContext context)? fetch,
    TResult? Function(BuildContext context, LanguageModel languageModel)?
        select,
  }) {
    return fetch?.call(context);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(BuildContext context)? fetch,
    TResult Function(BuildContext context, LanguageModel languageModel)? select,
    required TResult orElse(),
  }) {
    if (fetch != null) {
      return fetch(context);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Fetch value) fetch,
    required TResult Function(_Select value) select,
  }) {
    return fetch(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Fetch value)? fetch,
    TResult? Function(_Select value)? select,
  }) {
    return fetch?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Fetch value)? fetch,
    TResult Function(_Select value)? select,
    required TResult orElse(),
  }) {
    if (fetch != null) {
      return fetch(this);
    }
    return orElse();
  }
}

abstract class _Fetch implements LanguagesEvent {
  const factory _Fetch({required final BuildContext context}) = _$FetchImpl;

  @override
  BuildContext get context;
  @override
  @JsonKey(ignore: true)
  _$$FetchImplCopyWith<_$FetchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SelectImplCopyWith<$Res>
    implements $LanguagesEventCopyWith<$Res> {
  factory _$$SelectImplCopyWith(
          _$SelectImpl value, $Res Function(_$SelectImpl) then) =
      __$$SelectImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({BuildContext context, LanguageModel languageModel});
}

/// @nodoc
class __$$SelectImplCopyWithImpl<$Res>
    extends _$LanguagesEventCopyWithImpl<$Res, _$SelectImpl>
    implements _$$SelectImplCopyWith<$Res> {
  __$$SelectImplCopyWithImpl(
      _$SelectImpl _value, $Res Function(_$SelectImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? context = null,
    Object? languageModel = null,
  }) {
    return _then(_$SelectImpl(
      context: null == context
          ? _value.context
          : context // ignore: cast_nullable_to_non_nullable
              as BuildContext,
      languageModel: null == languageModel
          ? _value.languageModel
          : languageModel // ignore: cast_nullable_to_non_nullable
              as LanguageModel,
    ));
  }
}

/// @nodoc

class _$SelectImpl implements _Select {
  const _$SelectImpl({required this.context, required this.languageModel});

  @override
  final BuildContext context;
  @override
  final LanguageModel languageModel;

  @override
  String toString() {
    return 'LanguagesEvent.select(context: $context, languageModel: $languageModel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SelectImpl &&
            (identical(other.context, context) || other.context == context) &&
            (identical(other.languageModel, languageModel) ||
                other.languageModel == languageModel));
  }

  @override
  int get hashCode => Object.hash(runtimeType, context, languageModel);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SelectImplCopyWith<_$SelectImpl> get copyWith =>
      __$$SelectImplCopyWithImpl<_$SelectImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(BuildContext context) fetch,
    required TResult Function(BuildContext context, LanguageModel languageModel)
        select,
  }) {
    return select(context, languageModel);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(BuildContext context)? fetch,
    TResult? Function(BuildContext context, LanguageModel languageModel)?
        select,
  }) {
    return select?.call(context, languageModel);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(BuildContext context)? fetch,
    TResult Function(BuildContext context, LanguageModel languageModel)? select,
    required TResult orElse(),
  }) {
    if (select != null) {
      return select(context, languageModel);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Fetch value) fetch,
    required TResult Function(_Select value) select,
  }) {
    return select(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Fetch value)? fetch,
    TResult? Function(_Select value)? select,
  }) {
    return select?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Fetch value)? fetch,
    TResult Function(_Select value)? select,
    required TResult orElse(),
  }) {
    if (select != null) {
      return select(this);
    }
    return orElse();
  }
}

abstract class _Select implements LanguagesEvent {
  const factory _Select(
      {required final BuildContext context,
      required final LanguageModel languageModel}) = _$SelectImpl;

  @override
  BuildContext get context;
  LanguageModel get languageModel;
  @override
  @JsonKey(ignore: true)
  _$$SelectImplCopyWith<_$SelectImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$LanguagesState {
  List<LanguageModel> get locales => throw _privateConstructorUsedError;
  LanguageModel? get selected => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            List<LanguageModel> locales, LanguageModel? selected)
        initial,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<LanguageModel> locales, LanguageModel? selected)?
        initial,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<LanguageModel> locales, LanguageModel? selected)?
        initial,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $LanguagesStateCopyWith<LanguagesState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LanguagesStateCopyWith<$Res> {
  factory $LanguagesStateCopyWith(
          LanguagesState value, $Res Function(LanguagesState) then) =
      _$LanguagesStateCopyWithImpl<$Res, LanguagesState>;
  @useResult
  $Res call({List<LanguageModel> locales, LanguageModel? selected});
}

/// @nodoc
class _$LanguagesStateCopyWithImpl<$Res, $Val extends LanguagesState>
    implements $LanguagesStateCopyWith<$Res> {
  _$LanguagesStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? locales = null,
    Object? selected = freezed,
  }) {
    return _then(_value.copyWith(
      locales: null == locales
          ? _value.locales
          : locales // ignore: cast_nullable_to_non_nullable
              as List<LanguageModel>,
      selected: freezed == selected
          ? _value.selected
          : selected // ignore: cast_nullable_to_non_nullable
              as LanguageModel?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res>
    implements $LanguagesStateCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
          _$InitialImpl value, $Res Function(_$InitialImpl) then) =
      __$$InitialImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<LanguageModel> locales, LanguageModel? selected});
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$LanguagesStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
      _$InitialImpl _value, $Res Function(_$InitialImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? locales = null,
    Object? selected = freezed,
  }) {
    return _then(_$InitialImpl(
      locales: null == locales
          ? _value._locales
          : locales // ignore: cast_nullable_to_non_nullable
              as List<LanguageModel>,
      selected: freezed == selected
          ? _value.selected
          : selected // ignore: cast_nullable_to_non_nullable
              as LanguageModel?,
    ));
  }
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl(
      {required final List<LanguageModel> locales, required this.selected})
      : _locales = locales;

  final List<LanguageModel> _locales;
  @override
  List<LanguageModel> get locales {
    if (_locales is EqualUnmodifiableListView) return _locales;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_locales);
  }

  @override
  final LanguageModel? selected;

  @override
  String toString() {
    return 'LanguagesState.initial(locales: $locales, selected: $selected)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InitialImpl &&
            const DeepCollectionEquality().equals(other._locales, _locales) &&
            (identical(other.selected, selected) ||
                other.selected == selected));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_locales), selected);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InitialImplCopyWith<_$InitialImpl> get copyWith =>
      __$$InitialImplCopyWithImpl<_$InitialImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            List<LanguageModel> locales, LanguageModel? selected)
        initial,
  }) {
    return initial(locales, selected);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<LanguageModel> locales, LanguageModel? selected)?
        initial,
  }) {
    return initial?.call(locales, selected);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<LanguageModel> locales, LanguageModel? selected)?
        initial,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(locales, selected);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements LanguagesState {
  const factory _Initial(
      {required final List<LanguageModel> locales,
      required final LanguageModel? selected}) = _$InitialImpl;

  @override
  List<LanguageModel> get locales;
  @override
  LanguageModel? get selected;
  @override
  @JsonKey(ignore: true)
  _$$InitialImplCopyWith<_$InitialImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
