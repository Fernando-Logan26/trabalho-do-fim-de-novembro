import 'package:flutter/material.dart';
import '../services/app_store.dart';
import 'profile_screen.dart';

Future<bool> requestLogin(BuildContext context, AppStore store) async {
  if (store.signedIn) return true;
  await Navigator.push<void>(
    context,
    MaterialPageRoute(builder: (_) => LoginScreen(store: store)),
  );
  return store.signedIn;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({required this.store, super.key});
  final AppStore store;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email = '', password = '', cpf = '';
  String? error;
  bool busy = false;

  Future<void> submit() async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final ok = await widget.store.signIn(email, password, legacyCpf: cpf);
      if (!mounted) return;
      if (ok) {
        Navigator.pop(context);
      } else {
        setState(
          () => error = widget.store.needsActivation
              ? 'Confira o e-mail e o CPF cadastrados e use uma senha de pelo menos 8 caracteres.'
              : 'E-mail ou senha incorretos.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => error = 'Não foi possível entrar. Tente novamente.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> register() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => ProfileScreen(store: widget.store)),
    );
    if (mounted && widget.store.signedIn) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final activate = widget.store.needsActivation;
    return Scaffold(
      appBar: AppBar(title: const Text('Entrar')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            const Text(
              'Você pode explorar o app como visitante. Entre para registrar uma ocorrência.',
            ),
            const SizedBox(height: 20),
            if (widget.store.hasProfile) ...[
              if (activate)
                const Text(
                  'Primeiro acesso após a atualização: confirme os dados do seu cadastro e crie uma senha.',
                ),
              TextField(
                decoration: const InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
                onChanged: (s) => email = s,
              ),
              if (activate)
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'CPF cadastrado',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (s) => cpf = s,
                ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: activate
                      ? 'Crie uma senha (mínimo 8 caracteres)'
                      : 'Senha',
                ),
                obscureText: true,
                onChanged: (s) => password = s,
              ),
              if (error != null)
                Text(
                  error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              FilledButton(
                onPressed: busy ? null : submit,
                child: Text(busy ? 'Aguarde…' : 'Entrar no aplicativo'),
              ),
            ] else ...[
              const Text('Crie seu cadastro neste aparelho para começar.'),
              FilledButton(
                onPressed: register,
                child: const Text('Criar cadastro'),
              ),
            ],
            TextButton(
              onPressed: busy ? null : () => Navigator.pop(context),
              child: const Text('Continuar como visitante'),
            ),
          ],
        ),
      ),
    );
  }
}
