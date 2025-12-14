part of 'github_bloc.dart';

abstract class GithubEvent extends Equatable {
  const GithubEvent();

  @override
  List<Object> get props => [];
}

class GithubFetchRepos extends GithubEvent {
  final String username;
  final String? token;

  const GithubFetchRepos(this.username, {this.token});

  @override
  List<Object> get props => [username, token ?? ''];
}
