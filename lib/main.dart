import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:productivity_app/blocs/auth/auth_bloc.dart';
import 'package:productivity_app/blocs/calendar/calendar_bloc.dart';
import 'package:productivity_app/blocs/github/github_bloc.dart';
import 'package:productivity_app/blocs/task/task_bloc.dart';
import 'package:productivity_app/firebase_options.dart';
import 'package:productivity_app/pages/login_page.dart';
import 'package:productivity_app/repositories/auth_repository.dart';
import 'package:productivity_app/repositories/calendar_repository.dart';
import 'package:productivity_app/repositories/github_repository.dart';
import 'package:productivity_app/repositories/task_repository.dart';
import 'package:productivity_app/pages/onboarding_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider(create: (context) => GithubRepository()),
        RepositoryProvider(create: (context) => CalendarRepository()),
        RepositoryProvider(create: (context) => TaskRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: RepositoryProvider.of<AuthRepository>(context),
            )..add(AuthStarted()),
          ),
          BlocProvider(
            create: (context) => GithubBloc(
              githubRepository: RepositoryProvider.of<GithubRepository>(context),
            ),
          ),
          BlocProvider(
            create: (context) => CalendarBloc(
              calendarRepository: RepositoryProvider.of<CalendarRepository>(context),
            ),
          ),
          BlocProvider(
            create: (context) => TaskBloc(
              taskRepository: RepositoryProvider.of<TaskRepository>(context),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Productivity App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return const OnboardingPage();
              }
              if (state is AuthUnauthenticated) {
                return const LoginPage();
              }
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            },
          ),
        ),
      ),
    );
  }
}
