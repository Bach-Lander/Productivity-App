import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:productivity_app/blocs/calendar/calendar_event.dart';
import 'package:productivity_app/blocs/calendar/calendar_state.dart';
import 'package:productivity_app/repositories/calendar_repository.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final CalendarRepository _calendarRepository;
  StreamSubscription? _eventsSubscription;

  CalendarBloc({required CalendarRepository calendarRepository})
      : _calendarRepository = calendarRepository,
        super(CalendarLoading()) {
    on<LoadEvents>(_onLoadEvents);
    on<UpdateEvents>(_onUpdateEvents);
    on<AddEvent>(_onAddEvent);
    on<DeleteEvent>(_onDeleteEvent);
  }

  void _onLoadEvents(LoadEvents event, Emitter<CalendarState> emit) {
    _eventsSubscription?.cancel();
    _eventsSubscription = _calendarRepository.getEvents(event.userId).listen(
      (events) => add(UpdateEvents(events)),
      onError: (error) => print(error), // Handle error appropriately
    );
  }

  void _onUpdateEvents(UpdateEvents event, Emitter<CalendarState> emit) {
    emit(CalendarLoaded(events: event.events));
  }

  Future<void> _onAddEvent(AddEvent event, Emitter<CalendarState> emit) async {
    try {
      await _calendarRepository.addEvent(event.event);
    } catch (e) {
      emit(CalendarError(e.toString()));
    }
  }

  Future<void> _onDeleteEvent(DeleteEvent event, Emitter<CalendarState> emit) async {
    try {
      await _calendarRepository.deleteEvent(event.eventId);
    } catch (e) {
      emit(CalendarError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _eventsSubscription?.cancel();
    return super.close();
  }
}
