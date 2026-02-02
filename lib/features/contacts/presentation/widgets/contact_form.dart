import 'package:flutter/material.dart';

import '../../domain/contact_circle.dart';

class ContactForm extends StatelessWidget {
  const ContactForm({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.selectedCircle,
    required this.nameErrorText,
    required this.circleErrorText,
    required this.isSubmitting,
    required this.onNameChanged,
    required this.onPhoneChanged,
    required this.onEmailChanged,
    required this.onCircleSelected,
    required this.onSubmit,
    required this.onCancel,
  });

  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final ContactCircle? selectedCircle;
  final String? nameErrorText;
  final String? circleErrorText;
  final bool isSubmitting;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onPhoneChanged;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<ContactCircle> onCircleSelected;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedText = theme.colorScheme.onSurface.withOpacity(0.6);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  child: Icon(
                    Icons.person,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 36,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.edit,
                    size: 14,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Nom complet',
            style: theme.textTheme.labelLarge?.copyWith(
              color: mutedText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: nameController,
            textInputAction: TextInputAction.next,
            onChanged: onNameChanged,
            decoration: InputDecoration(
              hintText: 'Ex: Maman',
              errorText: nameErrorText,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Numero',
            style: theme.textTheme.labelLarge?.copyWith(
              color: mutedText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: phoneController,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.phone,
            onChanged: onPhoneChanged,
            decoration: const InputDecoration(
              hintText: '+33 6 12 34 56 78',
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Email',
            style: theme.textTheme.labelLarge?.copyWith(
              color: mutedText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: emailController,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            onChanged: onEmailChanged,
            decoration: const InputDecoration(
              hintText: 'exemple@mail.com',
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Categorie',
            style: theme.textTheme.labelLarge?.copyWith(
              color: mutedText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ContactCircle.values
                .map(
                  (circle) => ChoiceChip(
                    label: Text(circle.label),
                    selected: selectedCircle == circle,
                    onSelected: (_) => onCircleSelected(circle),
                  ),
                )
                .toList(),
          ),
          if (circleErrorText != null) ...[
            const SizedBox(height: 8),
            Text(
              circleErrorText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isSubmitting ? null : onSubmit,
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Enregistrer'),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: isSubmitting ? null : onCancel,
              child: const Text('Annuler'),
            ),
          ),
        ],
      ),
    );
  }
}
