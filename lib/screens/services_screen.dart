import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/service.dart';
import 'booking_screen.dart'; // Importe a tela de agendamento

class ServicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return FutureBuilder<List<Service>>(
      future: _fetchServices(supabase),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erro ao carregar serviços'));
        }

        final services = snapshot.data ?? [];

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            return Card(
              margin: EdgeInsets.only(bottom: 16),
              child: ListTile(
                title: Text(service.name),
                subtitle: Text(
                  'R\$${service.price.toStringAsFixed(2)} • ${service.duration} min',
                ),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BookingScreen(selectedService: service),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<List<Service>> _fetchServices(SupabaseClient supabase) async {
    final response = await supabase.from('services').select();
    return (response as List).map((data) => Service.fromMap(data)).toList();
  }
}
