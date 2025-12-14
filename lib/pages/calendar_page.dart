import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:productivity_app/blocs/auth/auth_bloc.dart';
import 'package:productivity_app/blocs/calendar/calendar_bloc.dart';
import 'package:productivity_app/blocs/calendar/calendar_event.dart';
import 'package:productivity_app/pages/add_event_page.dart';

import '../widgets/calendar.dart';
import '../widgets/calendar_appbar.dart';
import '../widgets/calendar_widget.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<CalendarBloc>().add(LoadEvents(authState.userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEventPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 26.0, vertical: 25.0),
            child: Column(
              children: const [
                CalendarAppBar(),
                SizedBox(
                  height: 4,
                ),
                CalendarDaysWidget(),
                SizedBox(
                  height: 4,
                ),
                Calendar(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
