import 'package:equatable/equatable.dart';
import 'package:productivity_app/models/calendar_event_model.dart';

abstract class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object> get props => [];
}

class LoadEvents extends CalendarEvent {
  final String userId;
  const LoadEvents(this.userId);

  @override
  List<Object> get props => [userId];
}

class AddEvent extends CalendarEvent {
  final CalendarEventModel event;
  const AddEvent(this.event);

  @override
  List<Object> get props => [event];
}

class DeleteEvent extends CalendarEvent {
  final String eventId;
  const DeleteEvent(this.eventId);

  @override
  List<Object> get props => [eventId];
}

class UpdateEvents extends CalendarEvent {
  final List<CalendarEventModel> events;
  const UpdateEvents(this.events);

  @override
  List<Object> get props => [events];
}
