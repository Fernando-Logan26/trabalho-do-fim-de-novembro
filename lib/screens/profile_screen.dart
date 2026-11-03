import 'package:flutter/material.dart';
import '../services/app_store.dart';
import '../widgets/common.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({required this.store, super.key});
  final AppStore store;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final form = GlobalKey<FormState>();
  late final values = Map<String, String>.of(widget.store.profile);
  bool saving = false;

  Widget field(String key, String label, {TextInputType? keyboard,
      String? Function(String)? validate, bool optional = false}) {
    return TextFormField(
      initialValue: values[key],
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboard,
      onChanged: (text) => values[key] = text.trim(),
      validator: (text) {
        final value = text?.trim() ?? '';
        if (value.isEmpty) return optional ? null : 'Preencha este campo.';
        return validate?.call(value);
      },
    );
  }

  String? validateCpf(String value) {
    final digits = value.replaceAll(RegExp(r'[.\-\s]'), '');
    if (RegExp(r'^\d{11}$').hasMatch(digits) &&
        digits.split('').toSet().length > 1) {
      final numbers = digits.split('').map(int.parse).toList();
      for (var end = 9; end <= 10; end++) {
        var sum = 0;
        for (var i = 0; i < end; i++) {
          sum += numbers[i] * (end + 1 - i);
        }
        if ((sum * 10 % 11) % 10 != numbers[end]) return 'Confira o CPF.';
      }
      return null;
    }
    return 'Confira o CPF.';
  }

  String? validateBirth(String value) {
    final parts = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(value);
    if (parts != null) {
      final day = int.parse(parts[1]!);
      final month = int.parse(parts[2]!);
      final year = int.parse(parts[3]!);
      final date = DateTime(year, month, day);
      if (year >= 1900 && date.month == month && date.day == day &&
          !date.isAfter(DateTime.now())) return null;
    }
    return 'Informe uma data válida no formato DD/MM/AAAA.';
  }

  Future<void> save() async {
    if (saving || !form.currentState!.validate()) return;
    setState(() => saving = true);
    try {
      await widget.store.saveProfile(values);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() => saving = false);
        message(context, 'Não foi possível salvar o cadastro.');
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Meu cadastro')),
    body: SafeArea(child: SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Form(key: form, child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Seus dados de cadastro ficam neste aparelho.'),
          field('cpf', 'CPF', keyboard: TextInputType.number, validate: validateCpf),
          field('name', 'Nome completo', keyboard: TextInputType.name),
          field('address', 'Endereço', keyboard: TextInputType.streetAddress),
          DropdownButtonFormField<String>(
            initialValue: values['sex'],
            decoration: const InputDecoration(labelText: 'Sexo'),
            items: ['Feminino', 'Masculino', 'Outro', 'Prefiro não informar']
                .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (s) { if (s != null) values['sex'] = s; },
            validator: (s) => s == null ? 'Selecione uma opção.' : null,
          ),
          field('birth', 'Data de nascimento (DD/MM/AAAA)',
              keyboard: TextInputType.datetime, validate: validateBirth),
          field('phone', 'Telefone com DDD (opcional)', optional: true,
              keyboard: TextInputType.phone, validate: (v) =>
                  RegExp(r'^\d{10,11}$').hasMatch(v.replaceAll(RegExp(r'[()\s-]'), ''))
                      ? null : 'Confira o telefone e o DDD.'),
          field('mobile', 'Celular com DDD', keyboard: TextInputType.phone,
              validate: (v) => RegExp(r'^\d{11}$').hasMatch(v.replaceAll(RegExp(r'[()\s-]'), ''))
                  ? null : 'Informe o celular com DDD e 11 dígitos.'),
          field('email', 'E-mail', keyboard: TextInputType.emailAddress,
              validate: (v) => RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v)
                  ? null : 'Confira o e-mail.'),
          FilledButton(onPressed: saving ? null : save, child: const Text('Salvar cadastro')),
        ].map((w) => Padding(padding: const EdgeInsets.only(bottom: 14), child: w)).toList(),
      )),
    )),
  );
}
