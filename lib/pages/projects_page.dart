import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:productivity_app/blocs/github/github_bloc.dart';
import 'package:productivity_app/models/github_repo_model.dart';
import 'package:productivity_app/pages/project_details_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({Key? key}) : super(key: key);

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  @override
  void initState() {
    super.initState();
    _loadRepos();
  }

  Future<void> _loadRepos() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('github_username');
    final token = prefs.getString('github_token');
    
    if (username != null && username.isNotEmpty) {
      context.read<GithubBloc>().add(GithubFetchRepos(username, token: token));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Projects"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: BlocBuilder<GithubBloc, GithubState>(
        builder: (context, state) {
          if (state is GithubLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GithubLoaded) {
            if (state.repos.isEmpty) {
              return const Center(child: Text("No repositories found."));
            }
            return ListView.builder(
              itemCount: state.repos.length,
              itemBuilder: (context, index) {
                final repo = state.repos[index];
                return _buildRepoCard(repo);
              },
            );
          } else if (state is GithubError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 10),
                  Text("Error: ${state.message}"),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _loadRepos,
                    child: const Text("Retry"),
                  )
                ],
              ),
            );
          }
          return const Center(child: Text("Please configure your GitHub username."));
        },
      ),
    );
  }

  Widget _buildRepoCard(GithubRepoModel repo) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProjectDetailsPage(repo: repo),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              children: [
                const Icon(Icons.folder_open, color: Colors.blueGrey),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    repo.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        "${repo.stargazersCount}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              ],
            ),
            if (repo.description.isNotEmpty && repo.description != 'No Description') ...[
              const SizedBox(height: 8),
              Text(
                repo.description,
                style: TextStyle(color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                if (repo.language != 'Unknown') ...[
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.purple,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(repo.language),
                ],
              ],
            )
          ],
        ),
      ),
    ));
  }
}
