import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/service.dart';


class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;


// Busca todos os serviços
  Future<List<Service>> getServices() async {
    final response = await _supabase
        .from('services')
        .select()
        .order('name', ascending: true);

    return (response as List)
        .map((data) => Service.fromMap(data))
        .toList();
  }
  
  // Busca serviços por categoria
  Future<List<Service>> getServicesByCategory(String category) async {
    final response = await _supabase
        .from('services')
        .select()
        .eq('category', category)
        .order('price', ascending: true);

    return (response as List)
        .map((data) => Service.fromMap(data))
        .toList();
}

}
