import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:productivity_app/blocs/task/task_event.dart';
import 'package:productivity_app/blocs/task/task_state.dart';
import 'package:productivity_app/repositories/task_repository.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _taskRepository;
  StreamSubscription? _tasksSubscription;

  TaskBloc({required TaskRepository taskRepository})
      : _taskRepository = taskRepository,
        super(TaskLoading()) {
    on<LoadTasks>(_onLoadTasks);
    on<TasksUpdated>(_onTasksUpdated);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
  }

  void _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) {
    _tasksSubscription?.cancel();
    _tasksSubscription = _taskRepository.getTasks(event.userId).listen(
      (tasks) => add(TasksUpdated(tasks)),
      onError: (error) => print(error),
    );
  }

  void _onTasksUpdated(TasksUpdated event, Emitter<TaskState> emit) {
    emit(TaskLoaded(tasks: event.tasks));
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    try {
      await _taskRepository.addTask(event.task);
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    try {
      await _taskRepository.updateTask(event.task);
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      await _taskRepository.deleteTask(event.taskId);
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    return super.close();
  }
}
