// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_db.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetExamDbCollection on Isar {
  IsarCollection<ExamDb> get examDbs => this.collection();
}

const ExamDbSchema = CollectionSchema(
  name: r'ExamDb',
  id: 7740399179342524569,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'finishedAt': PropertySchema(
      id: 1,
      name: r'finishedAt',
      type: IsarType.dateTime,
    ),
    r'memos': PropertySchema(
      id: 2,
      name: r'memos',
      type: IsarType.stringList,
    ),
    r'questionCount': PropertySchema(
      id: 3,
      name: r'questionCount',
      type: IsarType.long,
    ),
    r'questionSeconds': PropertySchema(
      id: 4,
      name: r'questionSeconds',
      type: IsarType.longList,
    ),
    r'startedAt': PropertySchema(
      id: 5,
      name: r'startedAt',
      type: IsarType.dateTime,
    ),
    r'subjectId': PropertySchema(
      id: 6,
      name: r'subjectId',
      type: IsarType.long,
    ),
    r'title': PropertySchema(
      id: 7,
      name: r'title',
      type: IsarType.string,
    ),
    r'totalSeconds': PropertySchema(
      id: 8,
      name: r'totalSeconds',
      type: IsarType.long,
    )
  },
  estimateSize: _examDbEstimateSize,
  serialize: _examDbSerialize,
  deserialize: _examDbDeserialize,
  deserializeProp: _examDbDeserializeProp,
  idName: r'id',
  indexes: {
    r'subjectId': IndexSchema(
      id: 440306668014799972,
      name: r'subjectId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'subjectId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'finishedAt': IndexSchema(
      id: -547886419717679970,
      name: r'finishedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'finishedAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _examDbGetId,
  getLinks: _examDbGetLinks,
  attach: _examDbAttach,
  version: '3.1.0+1',
);

int _examDbEstimateSize(
  ExamDb object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.memos.length * 3;
  {
    for (var i = 0; i < object.memos.length; i++) {
      final value = object.memos[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.questionSeconds.length * 8;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _examDbSerialize(
  ExamDb object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeDateTime(offsets[1], object.finishedAt);
  writer.writeStringList(offsets[2], object.memos);
  writer.writeLong(offsets[3], object.questionCount);
  writer.writeLongList(offsets[4], object.questionSeconds);
  writer.writeDateTime(offsets[5], object.startedAt);
  writer.writeLong(offsets[6], object.subjectId);
  writer.writeString(offsets[7], object.title);
  writer.writeLong(offsets[8], object.totalSeconds);
}

ExamDb _examDbDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ExamDb();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.finishedAt = reader.readDateTime(offsets[1]);
  object.id = id;
  object.memos = reader.readStringList(offsets[2]) ?? [];
  object.questionSeconds = reader.readLongList(offsets[4]) ?? [];
  object.startedAt = reader.readDateTime(offsets[5]);
  object.subjectId = reader.readLong(offsets[6]);
  object.title = reader.readString(offsets[7]);
  object.totalSeconds = reader.readLong(offsets[8]);
  return object;
}

P _examDbDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readStringList(offset) ?? []) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLongList(offset) ?? []) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _examDbGetId(ExamDb object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _examDbGetLinks(ExamDb object) {
  return [];
}

void _examDbAttach(IsarCollection<dynamic> col, Id id, ExamDb object) {
  object.id = id;
}

extension ExamDbQueryWhereSort on QueryBuilder<ExamDb, ExamDb, QWhere> {
  QueryBuilder<ExamDb, ExamDb, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterWhere> anySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'subjectId'),
      );
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterWhere> anyFinishedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'finishedAt'),
      );
    });
  }
}

extension ExamDbQueryWhere on QueryBuilder<ExamDb, ExamDb, QWhereClause> {
  QueryBuilder<ExamDb, ExamDb, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<ExamDb, ExamDb, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterWhereClause> idBetween(
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

  QueryBuilder<ExamDb, ExamDb, QAfterWhereClause> subjectIdEqualTo(
      int subjectId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'subjectId',
        value: [subjectId],
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterWhereClause> subjectIdNotEqualTo(
      int subjectId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subjectId',
              lower: [],
              upper: [subjectId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subjectId',
              lower: [subjectId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subjectId',
              lower: [subjectId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subjectId',
              lower: [],
              upper: [subjectId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterWhereClause> subjectIdGreaterThan(
    int subjectId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'subjectId',
        lower: [subjectId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterWhereClause> subjectIdLessThan(
    int subjectId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'subjectId',
        lower: [],
        upper: [subjectId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterWhereClause> subjectIdBetween(
    int lowerSubjectId,
    int upperSubjectId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'subjectId',
        lower: [lowerSubjectId],
        includeLower: includeLower,
        upper: [upperSubjectId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterWhereClause> finishedAtEqualTo(
      DateTime finishedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'finishedAt',
        value: [finishedAt],
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterWhereClause> finishedAtNotEqualTo(
      DateTime finishedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'finishedAt',
              lower: [],
              upper: [finishedAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'finishedAt',
              lower: [finishedAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'finishedAt',
              lower: [finishedAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'finishedAt',
              lower: [],
              upper: [finishedAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterWhereClause> finishedAtGreaterThan(
    DateTime finishedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'finishedAt',
        lower: [finishedAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterWhereClause> finishedAtLessThan(
    DateTime finishedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'finishedAt',
        lower: [],
        upper: [finishedAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterWhereClause> finishedAtBetween(
    DateTime lowerFinishedAt,
    DateTime upperFinishedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'finishedAt',
        lower: [lowerFinishedAt],
        includeLower: includeLower,
        upper: [upperFinishedAt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ExamDbQueryFilter on QueryBuilder<ExamDb, ExamDb, QFilterCondition> {
  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> createdAtGreaterThan(
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

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> finishedAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'finishedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> finishedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'finishedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> finishedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'finishedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> finishedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'finishedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> memosElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'memos',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> memosElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'memos',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> memosElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'memos',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> memosElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'memos',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> memosElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'memos',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> memosElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'memos',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> memosElementContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'memos',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> memosElementMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'memos',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> memosElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'memos',
        value: '',
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> memosElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'memos',
        value: '',
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> memosLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'memos',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> memosIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'memos',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> memosIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'memos',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> memosLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'memos',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> memosLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'memos',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> memosLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'memos',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> questionCountEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'questionCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> questionCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'questionCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> questionCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'questionCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> questionCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'questionCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition>
      questionSecondsElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'questionSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition>
      questionSecondsElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'questionSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition>
      questionSecondsElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'questionSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition>
      questionSecondsElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'questionSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition>
      questionSecondsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'questionSeconds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> questionSecondsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'questionSeconds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition>
      questionSecondsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'questionSeconds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition>
      questionSecondsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'questionSeconds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition>
      questionSecondsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'questionSeconds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition>
      questionSecondsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'questionSeconds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> startedAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> startedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> startedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> startedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> subjectIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectId',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> subjectIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subjectId',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> subjectIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subjectId',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> subjectIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subjectId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> titleContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> titleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> totalSecondsEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> totalSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> totalSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterFilterCondition> totalSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ExamDbQueryObject on QueryBuilder<ExamDb, ExamDb, QFilterCondition> {}

extension ExamDbQueryLinks on QueryBuilder<ExamDb, ExamDb, QFilterCondition> {}

extension ExamDbQuerySortBy on QueryBuilder<ExamDb, ExamDb, QSortBy> {
  QueryBuilder<ExamDb, ExamDb, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterSortBy> sortByFinishedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finishedAt', Sort.asc);
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterSortBy> sortByFinishedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finishedAt', Sort.desc);
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterSortBy> sortByQuestionCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionCount', Sort.asc);
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterSortBy> sortByQuestionCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionCount', Sort.desc);
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterSortBy> sortByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterSortBy> sortByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterSortBy> sortBySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.asc);
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterSortBy> sortBySubjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.desc);
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterSortBy> sortByTotalSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSeconds', Sort.asc);
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterSortBy> sortByTotalSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSeconds', Sort.desc);
    });
  }
}

extension ExamDbQuerySortThenBy on QueryBuilder<ExamDb, ExamDb, QSortThenBy> {
  QueryBuilder<ExamDb, ExamDb, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterSortBy> thenByFinishedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finishedAt', Sort.asc);
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterSortBy> thenByFinishedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finishedAt', Sort.desc);
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterSortBy> thenByQuestionCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionCount', Sort.asc);
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterSortBy> thenByQuestionCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionCount', Sort.desc);
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterSortBy> thenByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterSortBy> thenByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterSortBy> thenBySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.asc);
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterSortBy> thenBySubjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.desc);
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterSortBy> thenByTotalSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSeconds', Sort.asc);
    });
  }

  QueryBuilder<ExamDb, ExamDb, QAfterSortBy> thenByTotalSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSeconds', Sort.desc);
    });
  }
}

extension ExamDbQueryWhereDistinct on QueryBuilder<ExamDb, ExamDb, QDistinct> {
  QueryBuilder<ExamDb, ExamDb, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ExamDb, ExamDb, QDistinct> distinctByFinishedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'finishedAt');
    });
  }

  QueryBuilder<ExamDb, ExamDb, QDistinct> distinctByMemos() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'memos');
    });
  }

  QueryBuilder<ExamDb, ExamDb, QDistinct> distinctByQuestionCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'questionCount');
    });
  }

  QueryBuilder<ExamDb, ExamDb, QDistinct> distinctByQuestionSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'questionSeconds');
    });
  }

  QueryBuilder<ExamDb, ExamDb, QDistinct> distinctByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startedAt');
    });
  }

  QueryBuilder<ExamDb, ExamDb, QDistinct> distinctBySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subjectId');
    });
  }

  QueryBuilder<ExamDb, ExamDb, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExamDb, ExamDb, QDistinct> distinctByTotalSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalSeconds');
    });
  }
}

extension ExamDbQueryProperty on QueryBuilder<ExamDb, ExamDb, QQueryProperty> {
  QueryBuilder<ExamDb, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ExamDb, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ExamDb, DateTime, QQueryOperations> finishedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'finishedAt');
    });
  }

  QueryBuilder<ExamDb, List<String>, QQueryOperations> memosProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'memos');
    });
  }

  QueryBuilder<ExamDb, int, QQueryOperations> questionCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'questionCount');
    });
  }

  QueryBuilder<ExamDb, List<int>, QQueryOperations> questionSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'questionSeconds');
    });
  }

  QueryBuilder<ExamDb, DateTime, QQueryOperations> startedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startedAt');
    });
  }

  QueryBuilder<ExamDb, int, QQueryOperations> subjectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subjectId');
    });
  }

  QueryBuilder<ExamDb, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<ExamDb, int, QQueryOperations> totalSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalSeconds');
    });
  }
}
