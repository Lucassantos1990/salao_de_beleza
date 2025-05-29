import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking.dart';

class BookingHistoryScreen extends StatefulWidget {
  @override
  _BookingHistoryScreenState createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  List<Booking> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final response = await Supabase.instance.client
          .from('bookings')
          .select()
          .eq('user_id', userId)
          .order('date_time', ascending: false);

      setState(() {
        _bookings = (response as List<dynamic>)
            .map<Booking>((b) => Booking.fromMap(b))
            .toList();
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar agendamentos')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Meus Agendamentos')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
          ? Center(child: Text('Nenhum agendamento encontrado'))
          : ListView.builder(
              itemCount: _bookings.length,
              itemBuilder: (context, index) {
                final booking = _bookings[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(booking.serviceName),
                    subtitle: Text(
                      '${booking.formattedDate} às ${booking.formattedTime}\n'
                      'Com: ${booking.professionalName}',
                    ),
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () {
                      // Detalhes do agendamento
                    },
                  ),
                );
              },
            ),
    );
  }
}
