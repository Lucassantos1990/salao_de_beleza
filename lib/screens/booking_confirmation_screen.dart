import 'package:flutter/material.dart';
import '../models/booking.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final Booking booking;

  BookingConfirmationScreen({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Confirmação')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumo do Agendamento',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildDetailRow('Serviço:', booking.serviceName),
                    _buildDetailRow('Profissional:', booking.professionalName),
                    _buildDetailRow('Data:', booking.formattedDate),
                    _buildDetailRow('Horário:', booking.formattedTime),
                    _buildDetailRow('Duração:', '${booking.duration} minutos'),
                  ],
                ),
              ),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () => _confirmBooking(context),
              child: Text('Confirmar Agendamento'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 10),
          Text(value),
        ],
      ),
    );
  }

  void _confirmBooking(BuildContext context) {
    // Implementar lógica de confirmação
    Navigator.popUntil(context, ModalRoute.withName('/home'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Agendamento confirmado com sucesso!')),
    );
  }
}
