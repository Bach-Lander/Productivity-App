import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:productivity_app/blocs/auth/auth_bloc.dart';
import 'package:productivity_app/blocs/calendar/calendar_bloc.dart';
import 'package:productivity_app/blocs/calendar/calendar_event.dart';
import 'package:productivity_app/blocs/calendar/calendar_state.dart';
import 'package:productivity_app/blocs/task/task_bloc.dart';
import 'package:productivity_app/blocs/task/task_event.dart';
import 'package:productivity_app/blocs/task/task_state.dart';
import 'package:productivity_app/models/calendar_event_model.dart';
import 'package:productivity_app/models/task_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<CalendarBloc>().add(LoadEvents(authState.userId));
      context.read<TaskBloc>().add(LoadTasks(authState.userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Welcome back,",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "My Dashboard",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications_none, color: Colors.blue),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Upcoming Meetings Section
              const Text(
                "Upcoming Meetings",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              BlocBuilder<CalendarBloc, CalendarState>(
                builder: (context, state) {
                  if (state is CalendarLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is CalendarLoaded) {
                    final meetings = state.events
                        .where((e) => e.category == 'Meeting' && e.startTime.isAfter(DateTime.now()))
                        .toList();
                    
                    meetings.sort((a, b) => a.startTime.compareTo(b.startTime));

                    if (meetings.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(child: Text("No upcoming meetings")),
                      );
                    }

                    return SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: meetings.length,
                        itemBuilder: (context, index) {
                          return _buildMeetingCard(meetings[index]);
                        },
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),

              const SizedBox(height: 32),

              // Recent Tasks Section
              const Text(
                "Recent Tasks",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              BlocBuilder<TaskBloc, TaskState>(
                builder: (context, state) {
                  if (state is TaskLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is TaskLoaded) {
                    final tasks = state.tasks;
                    if (tasks.isEmpty) {
                      return const Text("No tasks found.");
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: tasks.length > 5 ? 5 : tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: Checkbox(
                              value: task.isCompleted,
                              onChanged: (val) {
                                context.read<TaskBloc>().add(
                                  UpdateTask(task.copyWith(isCompleted: val)),
                                );
                              },
                            ),
                            title: Text(
                              task.title,
                              style: TextStyle(
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            subtitle: task.projectId.isNotEmpty
                                ? Text("Project: ${task.projectId}")
                                : const Text("Independent Task"),
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeetingCard(CalendarEventModel event) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(event.color),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            event.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.black54),
              const SizedBox(width: 4),
              Text(
                DateFormat('MMM d, HH:mm').format(event.startTime),
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
