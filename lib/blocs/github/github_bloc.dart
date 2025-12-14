import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:productivity_app/models/github_repo_model.dart';
import 'package:productivity_app/repositories/github_repository.dart';

part 'github_event.dart';
part 'github_state.dart';

class GithubBloc extends Bloc<GithubEvent, GithubState> {
  final GithubRepository githubRepository;

  GithubBloc({required this.githubRepository}) : super(GithubInitial()) {
    on<GithubFetchRepos>(_onGithubFetchRepos);
  }

  Future<void> _onGithubFetchRepos(
      GithubFetchRepos event, Emitter<GithubState> emit) async {
    emit(GithubLoading());
    try {
      final repos = await githubRepository.getRepositories(
        event.username,
        token: event.token,
      );
      emit(GithubLoaded(repos));
    } catch (e) {
      emit(GithubError(e.toString()));
    }
  }
}
