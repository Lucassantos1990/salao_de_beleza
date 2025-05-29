import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final userMetadata = user?.userMetadata ?? {};

    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.purple[100],
            child: Icon(Icons.person, size: 50, color: Colors.purple),
          ),
          SizedBox(height: 20),
          Text(
            '${userMetadata['first_name'] ?? 'Usuário'} ${userMetadata['last_name'] ?? ''}',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(user?.email ?? ''),
          SizedBox(height: 30),
          ListTile(
            leading: Icon(Icons.phone),
            title: Text('Telefone'),
            subtitle: Text(userMetadata['phone'] ?? 'Não cadastrado'),
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('Meus Agendamentos'),
            onTap: () {
              // Navegar para agendamentos
            },
          ),
        ],
      ),
    );
  }
}