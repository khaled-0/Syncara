// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetPreferencesCollection on Isar {
  IsarCollection<String, Preferences> get preferences => this.collection();
}

const PreferencesSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'Preferences',
    idName: 'key',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'key',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'stringValue',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'intValue',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'doubleValue',
        type: IsarType.double,
      ),
      IsarPropertySchema(
        name: 'boolValue',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'jsonValue',
        type: IsarType.string,
      ),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<String, Preferences>(
    serialize: serializePreferences,
    deserialize: deserializePreferences,
    deserializeProperty: deserializePreferencesProp,
  ),
  embeddedSchemas: [],
);

@isarProtected
int serializePreferences(IsarWriter writer, Preferences object) {
  IsarCore.writeString(writer, 1, object.key);
  {
    final value = object.stringValue;
    if (value == null) {
      IsarCore.writeNull(writer, 2);
    } else {
      IsarCore.writeString(writer, 2, value);
    }
  }
  IsarCore.writeLong(writer, 3, object.intValue ?? -9223372036854775808);
  IsarCore.writeDouble(writer, 4, object.doubleValue ?? double.nan);
  {
    final value = object.boolValue;
    if (value == null) {
      IsarCore.writeNull(writer, 5);
    } else {
      IsarCore.writeBool(writer, 5, value);
    }
  }
  {
    final value = object.jsonValue;
    if (value == null) {
      IsarCore.writeNull(writer, 6);
    } else {
      IsarCore.writeString(writer, 6, value);
    }
  }
  return Isar.fastHash(object.key);
}

@isarProtected
Preferences deserializePreferences(IsarReader reader) {
  final String _key;
  _key = IsarCore.readString(reader, 1) ?? '';
  final object = Preferences(
    _key,
  );
  object.stringValue = IsarCore.readString(reader, 2);
  {
    final value = IsarCore.readLong(reader, 3);
    if (value == -9223372036854775808) {
      object.intValue = null;
    } else {
      object.intValue = value;
    }
  }
  {
    final value = IsarCore.readDouble(reader, 4);
    if (value.isNaN) {
      object.doubleValue = null;
    } else {
      object.doubleValue = value;
    }
  }
  {
    if (IsarCore.readNull(reader, 5)) {
      object.boolValue = null;
    } else {
      object.boolValue = IsarCore.readBool(reader, 5);
    }
  }
  object.jsonValue = IsarCore.readString(reader, 6);
  return object;
}

@isarProtected
dynamic deserializePreferencesProp(IsarReader reader, int property) {
  switch (property) {
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      return IsarCore.readString(reader, 2);
    case 3:
      {
        final value = IsarCore.readLong(reader, 3);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return value;
        }
      }
    case 4:
      {
        final value = IsarCore.readDouble(reader, 4);
        if (value.isNaN) {
          return null;
        } else {
          return value;
        }
      }
    case 5:
      {
        if (IsarCore.readNull(reader, 5)) {
          return null;
        } else {
          return IsarCore.readBool(reader, 5);
        }
      }
    case 6:
      return IsarCore.readString(reader, 6);
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _PreferencesUpdate {
  bool call({
    required String key,
    String? stringValue,
    int? intValue,
    double? doubleValue,
    bool? boolValue,
    String? jsonValue,
  });
}

class _PreferencesUpdateImpl implements _PreferencesUpdate {
  const _PreferencesUpdateImpl(this.collection);

  final IsarCollection<String, Preferences> collection;

  @override
  bool call({
    required String key,
    Object? stringValue = ignore,
    Object? intValue = ignore,
    Object? doubleValue = ignore,
    Object? boolValue = ignore,
    Object? jsonValue = ignore,
  }) {
    return collection.updateProperties([
          key
        ], {
          if (stringValue != ignore) 2: stringValue as String?,
          if (intValue != ignore) 3: intValue as int?,
          if (doubleValue != ignore) 4: doubleValue as double?,
          if (boolValue != ignore) 5: boolValue as bool?,
          if (jsonValue != ignore) 6: jsonValue as String?,
        }) >
        0;
  }
}

sealed class _PreferencesUpdateAll {
  int call({
    required List<String> key,
    String? stringValue,
    int? intValue,
    double? doubleValue,
    bool? boolValue,
    String? jsonValue,
  });
}

class _PreferencesUpdateAllImpl implements _PreferencesUpdateAll {
  const _PreferencesUpdateAllImpl(this.collection);

  final IsarCollection<String, Preferences> collection;

  @override
  int call({
    required List<String> key,
    Object? stringValue = ignore,
    Object? intValue = ignore,
    Object? doubleValue = ignore,
    Object? boolValue = ignore,
    Object? jsonValue = ignore,
  }) {
    return collection.updateProperties(key, {
      if (stringValue != ignore) 2: stringValue as String?,
      if (intValue != ignore) 3: intValue as int?,
      if (doubleValue != ignore) 4: doubleValue as double?,
      if (boolValue != ignore) 5: boolValue as bool?,
      if (jsonValue != ignore) 6: jsonValue as String?,
    });
  }
}

extension PreferencesUpdate on IsarCollection<String, Preferences> {
  _PreferencesUpdate get update => _PreferencesUpdateImpl(this);

  _PreferencesUpdateAll get updateAll => _PreferencesUpdateAllImpl(this);
}

sealed class _PreferencesQueryUpdate {
  int call({
    String? stringValue,
    int? intValue,
    double? doubleValue,
    bool? boolValue,
    String? jsonValue,
  });
}

class _PreferencesQueryUpdateImpl implements _PreferencesQueryUpdate {
  const _PreferencesQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<Preferences> query;
  final int? limit;

  @override
  int call({
    Object? stringValue = ignore,
    Object? intValue = ignore,
    Object? doubleValue = ignore,
    Object? boolValue = ignore,
    Object? jsonValue = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (stringValue != ignore) 2: stringValue as String?,
      if (intValue != ignore) 3: intValue as int?,
      if (doubleValue != ignore) 4: doubleValue as double?,
      if (boolValue != ignore) 5: boolValue as bool?,
      if (jsonValue != ignore) 6: jsonValue as String?,
    });
  }
}

extension PreferencesQueryUpdate on IsarQuery<Preferences> {
  _PreferencesQueryUpdate get updateFirst =>
      _PreferencesQueryUpdateImpl(this, limit: 1);

  _PreferencesQueryUpdate get updateAll => _PreferencesQueryUpdateImpl(this);
}

class _PreferencesQueryBuilderUpdateImpl implements _PreferencesQueryUpdate {
  const _PreferencesQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<Preferences, Preferences, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? stringValue = ignore,
    Object? intValue = ignore,
    Object? doubleValue = ignore,
    Object? boolValue = ignore,
    Object? jsonValue = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (stringValue != ignore) 2: stringValue as String?,
        if (intValue != ignore) 3: intValue as int?,
        if (doubleValue != ignore) 4: doubleValue as double?,
        if (boolValue != ignore) 5: boolValue as bool?,
        if (jsonValue != ignore) 6: jsonValue as String?,
      });
    } finally {
      q.close();
    }
  }
}

extension PreferencesQueryBuilderUpdate
    on QueryBuilder<Preferences, Preferences, QOperations> {
  _PreferencesQueryUpdate get updateFirst =>
      _PreferencesQueryBuilderUpdateImpl(this, limit: 1);

  _PreferencesQueryUpdate get updateAll =>
      _PreferencesQueryBuilderUpdateImpl(this);
}

extension PreferencesQueryFilter
    on QueryBuilder<Preferences, Preferences, QFilterCondition> {
  QueryBuilder<Preferences, Preferences, QAfterFilterCondition> keyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition> keyGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      keyGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition> keyLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      keyLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition> keyBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition> keyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition> keyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition> keyContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition> keyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 1,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition> keyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      keyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      stringValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 2));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      stringValueIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 2));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      stringValueEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      stringValueGreaterThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      stringValueGreaterThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      stringValueLessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      stringValueLessThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      stringValueBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      stringValueStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      stringValueEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      stringValueContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      stringValueMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 2,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      stringValueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      stringValueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      intValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 3));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      intValueIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 3));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition> intValueEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 3,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      intValueGreaterThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 3,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      intValueGreaterThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 3,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      intValueLessThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 3,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      intValueLessThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 3,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition> intValueBetween(
    int? lower,
    int? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 3,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      doubleValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 4));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      doubleValueIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 4));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      doubleValueEqualTo(
    double? value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 4,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      doubleValueGreaterThan(
    double? value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 4,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      doubleValueGreaterThanOrEqualTo(
    double? value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 4,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      doubleValueLessThan(
    double? value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 4,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      doubleValueLessThanOrEqualTo(
    double? value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 4,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      doubleValueBetween(
    double? lower,
    double? upper, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 4,
          lower: lower,
          upper: upper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      boolValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      boolValueIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      boolValueEqualTo(
    bool? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 5,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      jsonValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 6));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      jsonValueIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 6));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      jsonValueEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      jsonValueGreaterThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      jsonValueGreaterThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      jsonValueLessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      jsonValueLessThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      jsonValueBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 6,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      jsonValueStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      jsonValueEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      jsonValueContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      jsonValueMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 6,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      jsonValueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 6,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      jsonValueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 6,
          value: '',
        ),
      );
    });
  }
}

extension PreferencesQueryObject
    on QueryBuilder<Preferences, Preferences, QFilterCondition> {}

extension PreferencesQuerySortBy
    on QueryBuilder<Preferences, Preferences, QSortBy> {
  QueryBuilder<Preferences, Preferences, QAfterSortBy> sortByKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> sortByKeyDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> sortByStringValue(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> sortByStringValueDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> sortByIntValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> sortByIntValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> sortByDoubleValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> sortByDoubleValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> sortByBoolValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> sortByBoolValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> sortByJsonValue(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        6,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> sortByJsonValueDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        6,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }
}

extension PreferencesQuerySortThenBy
    on QueryBuilder<Preferences, Preferences, QSortThenBy> {
  QueryBuilder<Preferences, Preferences, QAfterSortBy> thenByKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> thenByKeyDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> thenByStringValue(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> thenByStringValueDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> thenByIntValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> thenByIntValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> thenByDoubleValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> thenByDoubleValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> thenByBoolValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> thenByBoolValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> thenByJsonValue(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> thenByJsonValueDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }
}

extension PreferencesQueryWhereDistinct
    on QueryBuilder<Preferences, Preferences, QDistinct> {
  QueryBuilder<Preferences, Preferences, QAfterDistinct> distinctByStringValue(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterDistinct> distinctByIntValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterDistinct>
      distinctByDoubleValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterDistinct> distinctByBoolValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterDistinct> distinctByJsonValue(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6, caseSensitive: caseSensitive);
    });
  }
}

extension PreferencesQueryProperty1
    on QueryBuilder<Preferences, Preferences, QProperty> {
  QueryBuilder<Preferences, String, QAfterProperty> keyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<Preferences, String?, QAfterProperty> stringValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<Preferences, int?, QAfterProperty> intValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<Preferences, double?, QAfterProperty> doubleValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<Preferences, bool?, QAfterProperty> boolValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<Preferences, String?, QAfterProperty> jsonValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }
}

extension PreferencesQueryProperty2<R>
    on QueryBuilder<Preferences, R, QAfterProperty> {
  QueryBuilder<Preferences, (R, String), QAfterProperty> keyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<Preferences, (R, String?), QAfterProperty>
      stringValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<Preferences, (R, int?), QAfterProperty> intValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<Preferences, (R, double?), QAfterProperty>
      doubleValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<Preferences, (R, bool?), QAfterProperty> boolValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<Preferences, (R, String?), QAfterProperty> jsonValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }
}

extension PreferencesQueryProperty3<R1, R2>
    on QueryBuilder<Preferences, (R1, R2), QAfterProperty> {
  QueryBuilder<Preferences, (R1, R2, String), QOperations> keyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<Preferences, (R1, R2, String?), QOperations>
      stringValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<Preferences, (R1, R2, int?), QOperations> intValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<Preferences, (R1, R2, double?), QOperations>
      doubleValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<Preferences, (R1, R2, bool?), QOperations> boolValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<Preferences, (R1, R2, String?), QOperations>
      jsonValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }
}
