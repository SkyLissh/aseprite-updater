// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'release.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Release _$ReleaseFromJson(Map<String, dynamic> json) => _Release(
  tagName: json['tag_name'] as String,
  name: json['name'] as String,
  body: json['body'] as String,
  publishedAt: DateTime.parse(json['published_at'] as String),
  draft: json['draft'] as bool,
  prerelease: json['prerelease'] as bool,
);

Map<String, dynamic> _$ReleaseToJson(_Release instance) => <String, dynamic>{
  'tag_name': instance.tagName,
  'name': instance.name,
  'body': instance.body,
  'published_at': instance.publishedAt.toIso8601String(),
  'draft': instance.draft,
  'prerelease': instance.prerelease,
};
