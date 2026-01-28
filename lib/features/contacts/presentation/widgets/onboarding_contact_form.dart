import 'package:flutter/material.dart';

import '../../domain/contact_circle.dart';

class OnboardingContactForm extends StatefulWidget {
  const OnboardingContactForm({
    super.key,
    required this.availableCircles,
    required this.onSubmit,
  });

  final List<ContactCircle> availableCircles;
  final Future<void> Function(String displayName, ContactCircle circle) onSubmit;

  @override
  State<OnboardingContactForm> createState() => _OnboardingContactFormState();
}

class _OnboardingContactFormState extends State<OnboardingContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  ContactCircle? _selectedCircle;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final formState = _formKey.currentState;
    if (formState == null) {
      return;
    }
    if (!formState.validate()) {
      return;
    }
    final circle = _selectedCircle;
    if (circle == null) {
      return;
    }
    await widget.onSubmit(_nameController.text.trim(), circle);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ajouter un proche',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nom',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nom requis';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<ContactCircle>(
            initialValue: _selectedCircle,
            decoration: const InputDecoration(
              labelText: 'Cercle',
              border: OutlineInputBorder(),
            ),
            items: widget.availableCircles
                .map(
                  (circle) => DropdownMenuItem<ContactCircle>(
                    value: circle,
                    child: Text(circle.label),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedCircle = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Cercle requis';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submit,
              child: const Text('Ajouter'),
            ),
          ),
        ],
      ),
    );
  }
}
