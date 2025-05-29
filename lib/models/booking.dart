import 'package:intl/intl.dart';

class Booking {
  final String serviceId;
  final String serviceName;
  final String professionalId;
  final String professionalName;
  final DateTime dateTime;
  final int duration;

  Booking({
    required this.serviceId,
    required this.serviceName,
    required this.professionalId,
    required this.professionalName,
    required this.dateTime,
    required this.duration,
  });

  String get formattedDate => DateFormat('dd/MM/yyyy').format(dateTime);
  String get formattedTime => DateFormat('HH:mm').format(dateTime);

  static fromMap(b) {}
}
