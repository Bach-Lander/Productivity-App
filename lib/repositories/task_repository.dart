import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:productivity_app/models/task_model.dart';

class TaskRepository {
  final FirebaseFirestore _firestore;

  TaskRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> addTask(TaskModel task) async {
    await _firestore.collection('tasks').add(task.toMap());
  }

  Future<void> updateTask(TaskModel task) async {
    await _firestore.collection('tasks').doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }

  Stream<List<TaskModel>> getTasks(String userId) {
    return _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => TaskModel.fromSnapshot(doc)).toList();
    });
  }
  
  Stream<List<TaskModel>> getProjectTasks(String userId, String projectId) {
    return _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => TaskModel.fromSnapshot(doc)).toList();
    });
  }
}
