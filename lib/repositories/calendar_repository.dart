import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:productivity_app/models/calendar_event_model.dart';

class CalendarRepository {
  final FirebaseFirestore _firestore;

  CalendarRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> addEvent(CalendarEventModel event) async {
    await _firestore.collection('events').add(event.toMap());
  }

  Stream<List<CalendarEventModel>> getEvents(String userId) {
    return _firestore
        .collection('events')
        .where('userId', isEqualTo: userId)
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CalendarEventModel.fromSnapshot(doc))
          .toList();
    });
  }

  Future<void> deleteEvent(String eventId) async {
    await _firestore.collection('events').doc(eventId).delete();
  }
}
