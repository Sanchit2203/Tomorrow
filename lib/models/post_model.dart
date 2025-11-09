import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String authorId;
  final String authorUsername;
  final String authorDisplayName;
  final String authorProfileImage;
  final String content;
  final List<String> imageUrls;
  final String? videoUrl;
  final List<String> hashtags;
  final List<String> mentions;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final List<String> likes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String location;
  final bool isPublic;

  PostModel({
    required this.id,
    required this.authorId,
    required this.authorUsername,
    required this.authorDisplayName,
    this.authorProfileImage = '',
    required this.content,
    this.imageUrls = const [],
    this.videoUrl,
    this.hashtags = const [],
    this.mentions = const [],
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.likes = const [],
    required this.createdAt,
    required this.updatedAt,
    this.location = '',
    this.isPublic = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorId': authorId,
      'authorUsername': authorUsername,
      'authorDisplayName': authorDisplayName,
      'authorProfileImage': authorProfileImage,
      'content': content,
      'imageUrls': imageUrls,
      'videoUrl': videoUrl,
      'hashtags': hashtags,
      'mentions': mentions,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'shareCount': shareCount,
      'likes': likes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'location': location,
      'isPublic': isPublic,
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'] ?? '',
      authorId: map['authorId'] ?? '',
      authorUsername: map['authorUsername'] ?? '',
      authorDisplayName: map['authorDisplayName'] ?? '',
      authorProfileImage: map['authorProfileImage'] ?? '',
      content: map['content'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      videoUrl: map['videoUrl'],
      hashtags: List<String>.from(map['hashtags'] ?? []),
      mentions: List<String>.from(map['mentions'] ?? []),
      likeCount: map['likeCount']?.toInt() ?? 0,
      commentCount: map['commentCount']?.toInt() ?? 0,
      shareCount: map['shareCount']?.toInt() ?? 0,
      likes: List<String>.from(map['likes'] ?? []),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      location: map['location'] ?? '',
      isPublic: map['isPublic'] ?? true,
    );
  }

  factory PostModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel.fromMap({...data, 'id': doc.id});
  }

  PostModel copyWith({
    String? id,
    String? authorId,
    String? authorUsername,
    String? authorDisplayName,
    String? authorProfileImage,
    String? content,
    List<String>? imageUrls,
    String? videoUrl,
    List<String>? hashtags,
    List<String>? mentions,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    List<String>? likes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? location,
    bool? isPublic,
  }) {
    return PostModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorUsername: authorUsername ?? this.authorUsername,
      authorDisplayName: authorDisplayName ?? this.authorDisplayName,
      authorProfileImage: authorProfileImage ?? this.authorProfileImage,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      videoUrl: videoUrl ?? this.videoUrl,
      hashtags: hashtags ?? this.hashtags,
      mentions: mentions ?? this.mentions,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      location: location ?? this.location,
      isPublic: isPublic ?? this.isPublic,
    );
  }
}