import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart'; // Nova lib para máscara de telefone

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores dos campos
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  // Novo formato para o telefone
  final _phoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: { "#": RegExp(r'[0-9]') },
  );

  // Estados
  bool _isLoading = false;
  bool _isRegistering = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      _showError('Por favor, insira um e-mail válido');
      return;
    }

    if (_passwordController.text.isEmpty || _passwordController.text.length < 6) {
      _showError('A senha deve ter pelo menos 6 caracteres');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } catch (e) {
      _showError('Erro no login: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signUp() async {
    if (_firstNameController.text.isEmpty) {
      _showError('Por favor, insira seu nome');
      return;
    }

    final phoneDigits = _phoneFormatter.getUnmaskedText();
    if (phoneDigits.length < 11) {
      _showError('Telefone inválido. Use DDD + número (ex: 11999999999)');
      return;
    }

    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      _showError('Por favor, insira um e-mail válido');
      return;
    }

    if (_passwordController.text.isEmpty || _passwordController.text.length < 6) {
      _showError('A senha deve ter pelo menos 6 caracteres');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authResponse = await Supabase.instance.client.auth.signUp(
        email: _emailController.text,
        password: _passwordController.text,
        data: {
          'first_name': _firstNameController.text,
          'last_name': _lastNameController.text,
        },
      );
      if (authResponse.user != null) {
        await Supabase.instance.client.from('user_profiles').insert({
          'id': authResponse.user!.id,
          'first_name': _firstNameController.text,
          'last_name': _lastNameController.text,
          'phone': phoneDigits, 
        });
      }
    } catch (e) {
      _showError('Erro no cadastro: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isRegistering ? 'Cadastro' : 'Login'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            if (_isRegistering) ...[
              _buildTextField(_firstNameController, 'Nome', TextInputType.name),
              SizedBox(height: 15),
              _buildTextField(_lastNameController, 'Sobrenome', TextInputType.name),
              SizedBox(height: 15),
              _buildPhoneField(),
              SizedBox(height: 15),
            ],
            _buildTextField(_emailController, 'E-mail', TextInputType.emailAddress),
            SizedBox(height: 15),
            _buildTextField(_passwordController, 'Senha', TextInputType.visiblePassword,
                obscureText: true),
            SizedBox(height: 25),
            _buildAuthButton(),
            SizedBox(height: 15),
            TextButton(
              onPressed: () => setState(() => _isRegistering = !_isRegistering),
              child: Text(
                _isRegistering 
                    ? 'Já tem conta? Faça login' 
                    : 'Não tem conta? Cadastre-se',
                style: TextStyle(color: Colors.purple),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    TextInputType keyboardType, {
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
    );
  }

  Widget _buildPhoneField() {
    return TextField(
      inputFormatters: [_phoneFormatter],
      decoration: InputDecoration(
        labelText: 'Telefone',
        border: OutlineInputBorder(),
        hintText: '(00) 00000-0000',
      ),
      keyboardType: TextInputType.phone,
    );
  }

  Widget _buildAuthButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : (_isRegistering ? _signUp : _signIn),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Text(
                _isRegistering ? 'Cadastrar' : 'Entrar',
                style: TextStyle(fontSize: 16),
              ),
      ),
    );
  }
}
