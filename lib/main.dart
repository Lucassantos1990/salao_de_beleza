import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/database_service.dart';
import 'screens/booking_confirmation_screen.dart';
import 'screens/booking_history_screen.dart';
import '../models/booking.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Supabase
  await Supabase.initialize(
    url: 'https://llmrrtzizxnnbaopcvql.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxsbXJydHppenhubmJhb3BjdnFsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYyMDYxNjYsImV4cCI6MjA2MTc4MjE2Nn0.1IjjlDnsnCXUJ1VqkA-8HHinGJM4TUyQX67EYXPUGrA',
  );

  // Configura o MultiProvider
  runApp(
    MultiProvider(
      providers: [
        Provider(
          create: (_) => DatabaseService(),
        ), // Adiciona o DatabaseService
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Salão de Beleza',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AuthWrapper(),
      routes: {
        '/booking-confirmation': (context) => BookingConfirmationScreen(
          booking: ModalRoute.of(context)!.settings.arguments as Booking,
        ),
        '/booking-history': (context) => BookingHistoryScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authState = Supabase.instance.client.auth.onAuthStateChange;

    return StreamBuilder(
      stream: authState,
      builder: (context, snapshot) {
        final session = snapshot.data?.session;
        return session != null ? HomeScreen() : LoginScreen();
      },
    );
  }
}
