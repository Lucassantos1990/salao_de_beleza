import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../models/professional.dart';
import '../models/service.dart';

class BookingScreen extends StatefulWidget {
  final Service selectedService;

  BookingScreen({required this.selectedService});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  Professional? _selectedProfessional;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime;
  bool _isLoading = false;
  List<Professional> _professionals = [];
  List<String> _availableTimes = [];

  final _supabase = Supabase.instance.client;
  final _timeSlots = [
    '09:00',
    '10:00',
    '11:00',
    '14:00',
    '15:00',
    '16:00',
  ]; // Horários padrão

  @override
  void initState() {
    super.initState();
    _loadProfessionals();
  }

  Future<void> _loadProfessionals() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase.from('professionals').select().contains(
        'service_ids',
        [widget.selectedService.id],
      );

      setState(() {
        _professionals = (response as List)
            .map((pro) => Professional.fromMap(pro))
            .toList();
        if (_professionals.isNotEmpty) {
          _selectedProfessional = _professionals.first;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar profissionais: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAvailableTimes() async {
    if (_selectedProfessional == null) return;

    setState(() => _isLoading = true);
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

      final response = await _supabase
          .from('bookings')
          .select('time')
          .eq('professional_id', _selectedProfessional!.id)
          .eq('date', formattedDate);

      final bookedTimes = (response as List)
          .map((b) => b['time'] as String)
          .toList();

      setState(() {
        _availableTimes = _timeSlots
            .where((time) => !bookedTimes.contains(time))
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar horários: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTime = null;
      });
      _loadAvailableTimes();
    }
  }

  Future<void> _confirmBooking() async {
    if (_selectedProfessional == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selecione profissional e horário')),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      await _supabase.from('bookings').insert({
        'service_id': widget.selectedService.id,
        'service_name': widget.selectedService.name,
        'professional_id': _selectedProfessional!.id,
        'professional_name': _selectedProfessional!.name,
        'user_id': _supabase.auth.currentUser!.id,
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'time': _selectedTime!.format(context),
        'duration': widget.selectedService.duration,
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Agendamento confirmado!')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao agendar: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agendar ${widget.selectedService.name}')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Seletor de Profissional
                  DropdownButtonFormField<Professional>(
                    value: _selectedProfessional,
                    items: _professionals.map((pro) {
                      return DropdownMenuItem(
                        value: pro,
                        child: Text('${pro.name} (${pro.specialty})'),
                      );
                    }).toList(),
                    onChanged: (pro) {
                      setState(() => _selectedProfessional = pro);
                      _loadAvailableTimes();
                    },
                    decoration: InputDecoration(
                      labelText: 'Profissional',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Seletor de Data
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: Text(
                      'Escolher Data: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Horários Disponíveis
                  if (_selectedProfessional != null) ...[
                    Text(
                      'Horários Disponíveis:',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableTimes.map((time) {
                        return ChoiceChip(
                          label: Text(time),
                          selected: _selectedTime?.format(context) == time,
                          onSelected: (selected) {
                            setState(() {
                              _selectedTime = selected
                                  ? TimeOfDay(
                                      hour: int.parse(time.split(':')[0]),
                                      minute: int.parse(time.split(':')[1]),
                                    )
                                  : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),
                  ],

                  // Botão de Confirmação
                  ElevatedButton(
                    onPressed: _confirmBooking,
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
}
