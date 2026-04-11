// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_metadata.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetVideoMetadataCollection on Isar {
  IsarCollection<VideoMetadata> get videoMetadatas => this.collection();
}

const VideoMetadataSchema = CollectionSchema(
  name: r'VideoMetadata',
  id: 1585430333783386232,
  properties: {
    r'probeJson': PropertySchema(
      id: 0,
      name: r'probeJson',
      type: IsarType.string,
    ),
    r'probedAt': PropertySchema(
      id: 1,
      name: r'probedAt',
      type: IsarType.dateTime,
    ),
    r'sourcePath': PropertySchema(
      id: 2,
      name: r'sourcePath',
      type: IsarType.string,
    )
  },
  estimateSize: _videoMetadataEstimateSize,
  serialize: _videoMetadataSerialize,
  deserialize: _videoMetadataDeserialize,
  deserializeProp: _videoMetadataDeserializeProp,
  idName: r'id',
  indexes: {
    r'sourcePath': IndexSchema(
      id: 369116665021572463,
      name: r'sourcePath',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'sourcePath',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'probedAt': IndexSchema(
      id: 3177162761186617092,
      name: r'probedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'probedAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _videoMetadataGetId,
  getLinks: _videoMetadataGetLinks,
  attach: _videoMetadataAttach,
  version: '3.1.0+1',
);

int _videoMetadataEstimateSize(
  VideoMetadata object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.probeJson.length * 3;
  bytesCount += 3 + object.sourcePath.length * 3;
  return bytesCount;
}

void _videoMetadataSerialize(
  VideoMetadata object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.probeJson);
  writer.writeDateTime(offsets[1], object.probedAt);
  writer.writeString(offsets[2], object.sourcePath);
}

VideoMetadata _videoMetadataDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = VideoMetadata();
  object.id = id;
  object.probeJson = reader.readString(offsets[0]);
  object.probedAt = reader.readDateTime(offsets[1]);
  object.sourcePath = reader.readString(offsets[2]);
  return object;
}

P _videoMetadataDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _videoMetadataGetId(VideoMetadata object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _videoMetadataGetLinks(VideoMetadata object) {
  return [];
}

void _videoMetadataAttach(
    IsarCollection<dynamic> col, Id id, VideoMetadata object) {
  object.id = id;
}

extension VideoMetadataByIndex on IsarCollection<VideoMetadata> {
  Future<VideoMetadata?> getBySourcePath(String sourcePath) {
    return getByIndex(r'sourcePath', [sourcePath]);
  }

  VideoMetadata? getBySourcePathSync(String sourcePath) {
    return getByIndexSync(r'sourcePath', [sourcePath]);
  }

  Future<bool> deleteBySourcePath(String sourcePath) {
    return deleteByIndex(r'sourcePath', [sourcePath]);
  }

  bool deleteBySourcePathSync(String sourcePath) {
    return deleteByIndexSync(r'sourcePath', [sourcePath]);
  }

  Future<List<VideoMetadata?>> getAllBySourcePath(
      List<String> sourcePathValues) {
    final values = sourcePathValues.map((e) => [e]).toList();
    return getAllByIndex(r'sourcePath', values);
  }

  List<VideoMetadata?> getAllBySourcePathSync(List<String> sourcePathValues) {
    final values = sourcePathValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'sourcePath', values);
  }

  Future<int> deleteAllBySourcePath(List<String> sourcePathValues) {
    final values = sourcePathValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'sourcePath', values);
  }

  int deleteAllBySourcePathSync(List<String> sourcePathValues) {
    final values = sourcePathValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'sourcePath', values);
  }

  Future<Id> putBySourcePath(VideoMetadata object) {
    return putByIndex(r'sourcePath', object);
  }

  Id putBySourcePathSync(VideoMetadata object, {bool saveLinks = true}) {
    return putByIndexSync(r'sourcePath', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySourcePath(List<VideoMetadata> objects) {
    return putAllByIndex(r'sourcePath', objects);
  }

  List<Id> putAllBySourcePathSync(List<VideoMetadata> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'sourcePath', objects, saveLinks: saveLinks);
  }
}

extension VideoMetadataQueryWhereSort
    on QueryBuilder<VideoMetadata, VideoMetadata, QWhere> {
  QueryBuilder<VideoMetadata, VideoMetadata, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterWhere> anyProbedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'probedAt'),
      );
    });
  }
}

extension VideoMetadataQueryWhere
    on QueryBuilder<VideoMetadata, VideoMetadata, QWhereClause> {
  QueryBuilder<VideoMetadata, VideoMetadata, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterWhereClause> idBetween(
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

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterWhereClause>
      sourcePathEqualTo(String sourcePath) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sourcePath',
        value: [sourcePath],
      ));
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterWhereClause>
      sourcePathNotEqualTo(String sourcePath) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sourcePath',
              lower: [],
              upper: [sourcePath],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sourcePath',
              lower: [sourcePath],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sourcePath',
              lower: [sourcePath],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sourcePath',
              lower: [],
              upper: [sourcePath],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterWhereClause> probedAtEqualTo(
      DateTime probedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'probedAt',
        value: [probedAt],
      ));
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterWhereClause>
      probedAtNotEqualTo(DateTime probedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'probedAt',
              lower: [],
              upper: [probedAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'probedAt',
              lower: [probedAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'probedAt',
              lower: [probedAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'probedAt',
              lower: [],
              upper: [probedAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterWhereClause>
      probedAtGreaterThan(
    DateTime probedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'probedAt',
        lower: [probedAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterWhereClause>
      probedAtLessThan(
    DateTime probedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'probedAt',
        lower: [],
        upper: [probedAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterWhereClause> probedAtBetween(
    DateTime lowerProbedAt,
    DateTime upperProbedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'probedAt',
        lower: [lowerProbedAt],
        includeLower: includeLower,
        upper: [upperProbedAt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension VideoMetadataQueryFilter
    on QueryBuilder<VideoMetadata, VideoMetadata, QFilterCondition> {
  QueryBuilder<VideoMetadata, VideoMetadata, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterFilterCondition> idBetween(
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

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterFilterCondition>
      probeJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'probeJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterFilterCondition>
      probeJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'probeJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterFilterCondition>
      probeJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'probeJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterFilterCondition>
      probeJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'probeJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterFilterCondition>
      probeJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'probeJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterFilterCondition>
      probeJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'probeJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterFilterCondition>
      probeJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'probeJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterFilterCondition>
      probeJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'probeJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterFilterCondition>
      probeJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'probeJson',
        value: '',
      ));
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterFilterCondition>
      probeJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'probeJson',
        value: '',
      ));
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterFilterCondition>
      probedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'probedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterFilterCondition>
      probedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'probedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterFilterCondition>
      probedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'probedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterFilterCondition>
      probedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'probedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterFilterCondition>
      sourcePathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourcePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterFilterCondition>
      sourcePathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourcePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterFilterCondition>
      sourcePathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourcePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterFilterCondition>
      sourcePathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourcePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterFilterCondition>
      sourcePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourcePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterFilterCondition>
      sourcePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourcePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterFilterCondition>
      sourcePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourcePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterFilterCondition>
      sourcePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourcePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterFilterCondition>
      sourcePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourcePath',
        value: '',
      ));
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterFilterCondition>
      sourcePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourcePath',
        value: '',
      ));
    });
  }
}

extension VideoMetadataQueryObject
    on QueryBuilder<VideoMetadata, VideoMetadata, QFilterCondition> {}

extension VideoMetadataQueryLinks
    on QueryBuilder<VideoMetadata, VideoMetadata, QFilterCondition> {}

extension VideoMetadataQuerySortBy
    on QueryBuilder<VideoMetadata, VideoMetadata, QSortBy> {
  QueryBuilder<VideoMetadata, VideoMetadata, QAfterSortBy> sortByProbeJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'probeJson', Sort.asc);
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterSortBy>
      sortByProbeJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'probeJson', Sort.desc);
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterSortBy> sortByProbedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'probedAt', Sort.asc);
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterSortBy>
      sortByProbedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'probedAt', Sort.desc);
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterSortBy> sortBySourcePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourcePath', Sort.asc);
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterSortBy>
      sortBySourcePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourcePath', Sort.desc);
    });
  }
}

extension VideoMetadataQuerySortThenBy
    on QueryBuilder<VideoMetadata, VideoMetadata, QSortThenBy> {
  QueryBuilder<VideoMetadata, VideoMetadata, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterSortBy> thenByProbeJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'probeJson', Sort.asc);
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterSortBy>
      thenByProbeJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'probeJson', Sort.desc);
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterSortBy> thenByProbedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'probedAt', Sort.asc);
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterSortBy>
      thenByProbedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'probedAt', Sort.desc);
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterSortBy> thenBySourcePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourcePath', Sort.asc);
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QAfterSortBy>
      thenBySourcePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourcePath', Sort.desc);
    });
  }
}

extension VideoMetadataQueryWhereDistinct
    on QueryBuilder<VideoMetadata, VideoMetadata, QDistinct> {
  QueryBuilder<VideoMetadata, VideoMetadata, QDistinct> distinctByProbeJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'probeJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QDistinct> distinctByProbedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'probedAt');
    });
  }

  QueryBuilder<VideoMetadata, VideoMetadata, QDistinct> distinctBySourcePath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourcePath', caseSensitive: caseSensitive);
    });
  }
}

extension VideoMetadataQueryProperty
    on QueryBuilder<VideoMetadata, VideoMetadata, QQueryProperty> {
  QueryBuilder<VideoMetadata, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<VideoMetadata, String, QQueryOperations> probeJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'probeJson');
    });
  }

  QueryBuilder<VideoMetadata, DateTime, QQueryOperations> probedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'probedAt');
    });
  }

  QueryBuilder<VideoMetadata, String, QQueryOperations> sourcePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourcePath');
    });
  }
}
