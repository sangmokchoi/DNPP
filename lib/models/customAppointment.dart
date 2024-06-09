import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnpp/models/pingpongList.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CustomAppointment {
  String? id;
  String pingpongCourtName;
  String pingpongCourtAddress;
  String userUid;
  List<Appointment> appointments; // Change this line

  CustomAppointment({
    required this.appointments, // Change this line
    required this.pingpongCourtName,
    required this.pingpongCourtAddress,
    required this.userUid,
  });


  factory CustomAppointment.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    return CustomAppointment(
      pingpongCourtName: data?['pingpongCourtName'],
      pingpongCourtAddress: data?['pingpongCourtAddress'],
      userUid: data?['userUid'],
      appointments: (data?['appointments'] as List<dynamic>?)!
          .map((appointmentData) => Appointment(
                startTime: appointmentData['startTime'],
                endTime: appointmentData['endTime'],
                subject: appointmentData['subject'],
                color: Color(appointmentData['color']).withOpacity(1),
                id: appointmentData['id'],
                isAllDay: appointmentData['isAllDay'],
                notes: appointmentData['notes'],
                recurrenceRule: appointmentData['recurrenceRule'],
                recurrenceId: appointmentData['recurrenceId'],
                recurrenceExceptionDates: appointmentData?['recurrenceExceptionDates'],
              ))
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (pingpongCourtName != null) "pingpongCourtName": pingpongCourtName,
      if (pingpongCourtAddress != null)
        "pingpongCourtAddress": pingpongCourtAddress,
      if (userUid != null) "userUid": userUid,
      if (appointments != null)
        "appointments": appointments // Change this line
            ?.map((appointment) => {
                  'startTime': appointment.startTime,
                  'endTime': appointment.endTime,
                  'subject': appointment.subject,
                  'color': appointment.color.value,
                  'id': appointment.id,
                  'isAllDay': appointment.isAllDay,
                  'notes': appointment.notes,
                  'recurrenceRule': appointment.recurrenceRule,
                  'recurrenceId': appointment.recurrenceId,
                  'recurrenceExceptionDates': appointment.recurrenceExceptionDates,
                })
            .toList(),
    };
  }
}
