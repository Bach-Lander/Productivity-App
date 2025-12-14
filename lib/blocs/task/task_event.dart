import 'package:equatable/equatable.dart';
import 'package:productivity_app/models/task_model.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object> get props => [];
}

class LoadTasks extends TaskEvent {
  final String userId;
  const LoadTasks(this.userId);

  @override
  List<Object> get props => [userId];
}

class AddTask extends TaskEvent {
  final TaskModel task;
  const AddTask(this.task);

  @override
  List<Object> get props => [task];
}

class UpdateTask extends TaskEvent {
  final TaskModel task;
  const UpdateTask(this.task);

  @override
  List<Object> get props => [task];
}

class DeleteTask extends TaskEvent {
  final String taskId;
  const DeleteTask(this.taskId);

  @override
  List<Object> get props => [taskId];
}

class TasksUpdated extends TaskEvent {
  final List<TaskModel> tasks;
  const TasksUpdated(this.tasks);

  @override
  List<Object> get props => [tasks];
}
