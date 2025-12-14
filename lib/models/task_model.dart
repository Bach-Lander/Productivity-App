import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final bool isCompleted;
  final String projectId; // Can be empty if independent
  final String userId;

  TaskModel({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.projectId,
    required this.userId,
  });

  factory TaskModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      title: data['title'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      projectId: data['projectId'] ?? '',
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isCompleted': isCompleted,
      'projectId': projectId,
      'userId': userId,
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    String? projectId,
    String? userId,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      projectId: projectId ?? this.projectId,
      userId: userId ?? this.userId,
    );
  }
}
