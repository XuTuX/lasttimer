// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject_db.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSubjectDbCollection on Isar {
  IsarCollection<SubjectDb> get subjectDbs => this.collection();
}

const SubjectDbSchema = CollectionSchema(
  name: r'SubjectDb',
  id: 5305975792246144207,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'isMock': PropertySchema(
      id: 1,
      name: r'isMock',
      type: IsarType.bool,
    ),
    r'isPractice': PropertySchema(
      id: 2,
      name: r'isPractice',
      type: IsarType.bool,
    ),
    r'mockQuestionCount': PropertySchema(
      id: 3,
      name: r'mockQuestionCount',
      type: IsarType.long,
    ),
    r'mockTimeSeconds': PropertySchema(
      id: 4,
      name: r'mockTimeSeconds',
      type: IsarType.long,
    ),
    r'subjectName': PropertySchema(
      id: 5,
      name: r'subjectName',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 6,
      name: r'type',
      type: IsarType.byte,
      enumMap: _SubjectDbtypeEnumValueMap,
    ),
    r'typeIndex': PropertySchema(
      id: 7,
      name: r'typeIndex',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 8,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _subjectDbEstimateSize,
  serialize: _subjectDbSerialize,
  deserialize: _subjectDbDeserialize,
  deserializeProp: _subjectDbDeserializeProp,
  idName: r'id',
  indexes: {
    r'typeIndex_subjectName': IndexSchema(
      id: -4843504016697575549,
      name: r'typeIndex_subjectName',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'typeIndex',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'subjectName',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _subjectDbGetId,
  getLinks: _subjectDbGetLinks,
  attach: _subjectDbAttach,
  version: '3.1.0+1',
);

int _subjectDbEstimateSize(
  SubjectDb object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.subjectName.length * 3;
  return bytesCount;
}

void _subjectDbSerialize(
  SubjectDb object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeBool(offsets[1], object.isMock);
  writer.writeBool(offsets[2], object.isPractice);
  writer.writeLong(offsets[3], object.mockQuestionCount);
  writer.writeLong(offsets[4], object.mockTimeSeconds);
  writer.writeString(offsets[5], object.subjectName);
  writer.writeByte(offsets[6], object.type.index);
  writer.writeLong(offsets[7], object.typeIndex);
  writer.writeDateTime(offsets[8], object.updatedAt);
}

SubjectDb _subjectDbDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SubjectDb();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.id = id;
  object.mockQuestionCount = reader.readLongOrNull(offsets[3]);
  object.mockTimeSeconds = reader.readLongOrNull(offsets[4]);
  object.subjectName = reader.readString(offsets[5]);
  object.type = _SubjectDbtypeValueEnumMap[reader.readByteOrNull(offsets[6])] ??
      SubjectType.practice;
  object.updatedAt = reader.readDateTime(offsets[8]);
  return object;
}

P _subjectDbDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (_SubjectDbtypeValueEnumMap[reader.readByteOrNull(offset)] ??
          SubjectType.practice) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _SubjectDbtypeEnumValueMap = {
  'practice': 0,
  'mock': 1,
};
const _SubjectDbtypeValueEnumMap = {
  0: SubjectType.practice,
  1: SubjectType.mock,
};

Id _subjectDbGetId(SubjectDb object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _subjectDbGetLinks(SubjectDb object) {
  return [];
}

void _subjectDbAttach(IsarCollection<dynamic> col, Id id, SubjectDb object) {
  object.id = id;
}

extension SubjectDbByIndex on IsarCollection<SubjectDb> {
  Future<SubjectDb?> getByTypeIndexSubjectName(
      int typeIndex, String subjectName) {
    return getByIndex(r'typeIndex_subjectName', [typeIndex, subjectName]);
  }

  SubjectDb? getByTypeIndexSubjectNameSync(int typeIndex, String subjectName) {
    return getByIndexSync(r'typeIndex_subjectName', [typeIndex, subjectName]);
  }

  Future<bool> deleteByTypeIndexSubjectName(int typeIndex, String subjectName) {
    return deleteByIndex(r'typeIndex_subjectName', [typeIndex, subjectName]);
  }

  bool deleteByTypeIndexSubjectNameSync(int typeIndex, String subjectName) {
    return deleteByIndexSync(
        r'typeIndex_subjectName', [typeIndex, subjectName]);
  }

  Future<List<SubjectDb?>> getAllByTypeIndexSubjectName(
      List<int> typeIndexValues, List<String> subjectNameValues) {
    final len = typeIndexValues.length;
    assert(subjectNameValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([typeIndexValues[i], subjectNameValues[i]]);
    }

    return getAllByIndex(r'typeIndex_subjectName', values);
  }

  List<SubjectDb?> getAllByTypeIndexSubjectNameSync(
      List<int> typeIndexValues, List<String> subjectNameValues) {
    final len = typeIndexValues.length;
    assert(subjectNameValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([typeIndexValues[i], subjectNameValues[i]]);
    }

    return getAllByIndexSync(r'typeIndex_subjectName', values);
  }

  Future<int> deleteAllByTypeIndexSubjectName(
      List<int> typeIndexValues, List<String> subjectNameValues) {
    final len = typeIndexValues.length;
    assert(subjectNameValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([typeIndexValues[i], subjectNameValues[i]]);
    }

    return deleteAllByIndex(r'typeIndex_subjectName', values);
  }

  int deleteAllByTypeIndexSubjectNameSync(
      List<int> typeIndexValues, List<String> subjectNameValues) {
    final len = typeIndexValues.length;
    assert(subjectNameValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([typeIndexValues[i], subjectNameValues[i]]);
    }

    return deleteAllByIndexSync(r'typeIndex_subjectName', values);
  }

  Future<Id> putByTypeIndexSubjectName(SubjectDb object) {
    return putByIndex(r'typeIndex_subjectName', object);
  }

  Id putByTypeIndexSubjectNameSync(SubjectDb object, {bool saveLinks = true}) {
    return putByIndexSync(r'typeIndex_subjectName', object,
        saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByTypeIndexSubjectName(List<SubjectDb> objects) {
    return putAllByIndex(r'typeIndex_subjectName', objects);
  }

  List<Id> putAllByTypeIndexSubjectNameSync(List<SubjectDb> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'typeIndex_subjectName', objects,
        saveLinks: saveLinks);
  }
}

extension SubjectDbQueryWhereSort
    on QueryBuilder<SubjectDb, SubjectDb, QWhere> {
  QueryBuilder<SubjectDb, SubjectDb, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SubjectDbQueryWhere
    on QueryBuilder<SubjectDb, SubjectDb, QWhereClause> {
  QueryBuilder<SubjectDb, SubjectDb, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterWhereClause>
      typeIndexEqualToAnySubjectName(int typeIndex) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'typeIndex_subjectName',
        value: [typeIndex],
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterWhereClause>
      typeIndexNotEqualToAnySubjectName(int typeIndex) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'typeIndex_subjectName',
              lower: [],
              upper: [typeIndex],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'typeIndex_subjectName',
              lower: [typeIndex],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'typeIndex_subjectName',
              lower: [typeIndex],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'typeIndex_subjectName',
              lower: [],
              upper: [typeIndex],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterWhereClause>
      typeIndexGreaterThanAnySubjectName(
    int typeIndex, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'typeIndex_subjectName',
        lower: [typeIndex],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterWhereClause>
      typeIndexLessThanAnySubjectName(
    int typeIndex, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'typeIndex_subjectName',
        lower: [],
        upper: [typeIndex],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterWhereClause>
      typeIndexBetweenAnySubjectName(
    int lowerTypeIndex,
    int upperTypeIndex, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'typeIndex_subjectName',
        lower: [lowerTypeIndex],
        includeLower: includeLower,
        upper: [upperTypeIndex],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterWhereClause>
      typeIndexSubjectNameEqualTo(int typeIndex, String subjectName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'typeIndex_subjectName',
        value: [typeIndex, subjectName],
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterWhereClause>
      typeIndexEqualToSubjectNameNotEqualTo(int typeIndex, String subjectName) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'typeIndex_subjectName',
              lower: [typeIndex],
              upper: [typeIndex, subjectName],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'typeIndex_subjectName',
              lower: [typeIndex, subjectName],
              includeLower: false,
              upper: [typeIndex],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'typeIndex_subjectName',
              lower: [typeIndex, subjectName],
              includeLower: false,
              upper: [typeIndex],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'typeIndex_subjectName',
              lower: [typeIndex],
              upper: [typeIndex, subjectName],
              includeUpper: false,
            ));
      }
    });
  }
}

extension SubjectDbQueryFilter
    on QueryBuilder<SubjectDb, SubjectDb, QFilterCondition> {
  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition> isMockEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isMock',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition> isPracticeEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPractice',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition>
      mockQuestionCountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'mockQuestionCount',
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition>
      mockQuestionCountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'mockQuestionCount',
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition>
      mockQuestionCountEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mockQuestionCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition>
      mockQuestionCountGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mockQuestionCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition>
      mockQuestionCountLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mockQuestionCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition>
      mockQuestionCountBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mockQuestionCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition>
      mockTimeSecondsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'mockTimeSeconds',
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition>
      mockTimeSecondsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'mockTimeSeconds',
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition>
      mockTimeSecondsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mockTimeSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition>
      mockTimeSecondsGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mockTimeSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition>
      mockTimeSecondsLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mockTimeSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition>
      mockTimeSecondsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mockTimeSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition> subjectNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition>
      subjectNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subjectName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition> subjectNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subjectName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition> subjectNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subjectName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition>
      subjectNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'subjectName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition> subjectNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'subjectName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition> subjectNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subjectName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition> subjectNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subjectName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition>
      subjectNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectName',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition>
      subjectNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subjectName',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition> typeEqualTo(
      SubjectType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition> typeGreaterThan(
    SubjectType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition> typeLessThan(
    SubjectType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition> typeBetween(
    SubjectType lower,
    SubjectType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition> typeIndexEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'typeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition>
      typeIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'typeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition> typeIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'typeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition> typeIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'typeIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition> updatedAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition> updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterFilterCondition> updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SubjectDbQueryObject
    on QueryBuilder<SubjectDb, SubjectDb, QFilterCondition> {}

extension SubjectDbQueryLinks
    on QueryBuilder<SubjectDb, SubjectDb, QFilterCondition> {}

extension SubjectDbQuerySortBy on QueryBuilder<SubjectDb, SubjectDb, QSortBy> {
  QueryBuilder<SubjectDb, SubjectDb, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterSortBy> sortByIsMock() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMock', Sort.asc);
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterSortBy> sortByIsMockDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMock', Sort.desc);
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterSortBy> sortByIsPractice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPractice', Sort.asc);
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterSortBy> sortByIsPracticeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPractice', Sort.desc);
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterSortBy> sortByMockQuestionCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mockQuestionCount', Sort.asc);
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterSortBy>
      sortByMockQuestionCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mockQuestionCount', Sort.desc);
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterSortBy> sortByMockTimeSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mockTimeSeconds', Sort.asc);
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterSortBy> sortByMockTimeSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mockTimeSeconds', Sort.desc);
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterSortBy> sortBySubjectName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectName', Sort.asc);
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterSortBy> sortBySubjectNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectName', Sort.desc);
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterSortBy> sortByTypeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'typeIndex', Sort.asc);
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterSortBy> sortByTypeIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'typeIndex', Sort.desc);
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension SubjectDbQuerySortThenBy
    on QueryBuilder<SubjectDb, SubjectDb, QSortThenBy> {
  QueryBuilder<SubjectDb, SubjectDb, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterSortBy> thenByIsMock() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMock', Sort.asc);
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterSortBy> thenByIsMockDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMock', Sort.desc);
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterSortBy> thenByIsPractice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPractice', Sort.asc);
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterSortBy> thenByIsPracticeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPractice', Sort.desc);
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterSortBy> thenByMockQuestionCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mockQuestionCount', Sort.asc);
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterSortBy>
      thenByMockQuestionCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mockQuestionCount', Sort.desc);
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterSortBy> thenByMockTimeSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mockTimeSeconds', Sort.asc);
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterSortBy> thenByMockTimeSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mockTimeSeconds', Sort.desc);
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterSortBy> thenBySubjectName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectName', Sort.asc);
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterSortBy> thenBySubjectNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectName', Sort.desc);
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterSortBy> thenByTypeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'typeIndex', Sort.asc);
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterSortBy> thenByTypeIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'typeIndex', Sort.desc);
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension SubjectDbQueryWhereDistinct
    on QueryBuilder<SubjectDb, SubjectDb, QDistinct> {
  QueryBuilder<SubjectDb, SubjectDb, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QDistinct> distinctByIsMock() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isMock');
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QDistinct> distinctByIsPractice() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPractice');
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QDistinct> distinctByMockQuestionCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mockQuestionCount');
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QDistinct> distinctByMockTimeSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mockTimeSeconds');
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QDistinct> distinctBySubjectName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subjectName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QDistinct> distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type');
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QDistinct> distinctByTypeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'typeIndex');
    });
  }

  QueryBuilder<SubjectDb, SubjectDb, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension SubjectDbQueryProperty
    on QueryBuilder<SubjectDb, SubjectDb, QQueryProperty> {
  QueryBuilder<SubjectDb, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SubjectDb, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<SubjectDb, bool, QQueryOperations> isMockProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isMock');
    });
  }

  QueryBuilder<SubjectDb, bool, QQueryOperations> isPracticeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPractice');
    });
  }

  QueryBuilder<SubjectDb, int?, QQueryOperations> mockQuestionCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mockQuestionCount');
    });
  }

  QueryBuilder<SubjectDb, int?, QQueryOperations> mockTimeSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mockTimeSeconds');
    });
  }

  QueryBuilder<SubjectDb, String, QQueryOperations> subjectNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subjectName');
    });
  }

  QueryBuilder<SubjectDb, SubjectType, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<SubjectDb, int, QQueryOperations> typeIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'typeIndex');
    });
  }

  QueryBuilder<SubjectDb, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
