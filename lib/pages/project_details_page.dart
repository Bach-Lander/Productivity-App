import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:productivity_app/blocs/auth/auth_bloc.dart';
import 'package:productivity_app/blocs/task/task_bloc.dart';
import 'package:productivity_app/blocs/task/task_event.dart';
import 'package:productivity_app/blocs/task/task_state.dart';
import 'package:productivity_app/models/github_repo_model.dart';
import 'package:productivity_app/models/task_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectDetailsPage extends StatefulWidget {
  final GithubRepoModel repo;

  const ProjectDetailsPage({Key? key, required this.repo}) : super(key: key);

  @override
  State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<TaskBloc>().add(LoadTasks(authState.userId));
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  void _addTask() {
    final TextEditingController _taskController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Task to Project"),
          content: TextField(
            controller: _taskController,
            decoration: const InputDecoration(hintText: "Task Title"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_taskController.text.isNotEmpty) {
                  final authState = context.read<AuthBloc>().state;
                  if (authState is AuthAuthenticated) {
                    final newTask = TaskModel(
                      id: '',
                      title: _taskController.text,
                      isCompleted: false,
                      projectId: widget.repo.name, // Using name as ID for simplicity here
                      userId: authState.userId,
                    );
                    context.read<TaskBloc>().add(AddTask(newTask));
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.repo.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add_task),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Icon and Stats
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.folder, size: 40, color: Colors.blue),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.repo.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (widget.repo.language != 'Unknown')
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.repo.language,
                            style: const TextStyle(
                                color: Colors.purple, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Description Section
            const Text(
              "Description",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.repo.description.isNotEmpty
                  ? widget.repo.description
                  : "No description provided.",
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 24),

            // Stats Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _buildStatCard(Icons.star, "Stars", "${widget.repo.stargazersCount}", Colors.orange),
                _buildStatCard(Icons.remove_red_eye, "Watchers", "${widget.repo.watchersCount}", Colors.blue),
                _buildStatCard(Icons.call_split, "Forks", "${widget.repo.forksCount}", Colors.green),
                _buildStatCard(Icons.code, "Language", widget.repo.language, Colors.purple),
              ],
            ),
            
            const SizedBox(height: 30),

            // Tasks Section
            const Text(
              "Tasks & Progress",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                if (state is TaskLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is TaskLoaded) {
                  final projectTasks = state.tasks
                      .where((task) => task.projectId == widget.repo.name)
                      .toList();
                  
                  if (projectTasks.isEmpty) {
                    return const Text("No tasks added yet.");
                  }

                  final completedCount = projectTasks.where((t) => t.isCompleted).length;
                  final progress = projectTasks.isNotEmpty 
                      ? completedCount / projectTasks.length 
                      : 0.0;

                  return Column(
                    children: [
                      LinearPercentIndicator(
                        lineHeight: 20.0,
                        percent: progress,
                        center: Text(
                          "${(progress * 100).toStringAsFixed(1)}%",
                          style: const TextStyle(fontSize: 12.0),
                        ),
                        barRadius: const Radius.circular(10),
                        progressColor: Colors.green,
                        backgroundColor: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: projectTasks.length,
                        itemBuilder: (context, index) {
                          final task = projectTasks[index];
                          return CheckboxListTile(
                            title: Text(task.title),
                            value: task.isCompleted,
                            onChanged: (bool? value) {
                              if (value != null) {
                                context.read<TaskBloc>().add(
                                  UpdateTask(task.copyWith(isCompleted: value)),
                                );
                              }
                            },
                            secondary: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                context.read<TaskBloc>().add(DeleteTask(task.id));
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }
                return const Text("Failed to load tasks.");
              },
            ),

            const SizedBox(height: 30),
            
            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _launchUrl(widget.repo.htmlUrl),
                icon: const Icon(Icons.open_in_new),
                label: const Text("View on GitHub"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
