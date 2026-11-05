import 'package:flutter/material.dart';

import '../models/recruiter.dart';
import '../utils/constants.dart';

/// Shared form for creating and editing a recruiter's company profile. Reused
/// by the first-run setup screen and the edit screen so they can't drift.
class RecruiterProfileEditor extends StatefulWidget {
  final Recruiter initial;
  final String submitLabel;
  final Future<bool> Function(Recruiter updated) onSubmit;

  const RecruiterProfileEditor({
    super.key,
    required this.initial,
    required this.onSubmit,
    this.submitLabel = 'Save',
  });

  @override
  State<RecruiterProfileEditor> createState() => _RecruiterProfileEditorState();
}

class _RecruiterProfileEditorState extends State<RecruiterProfileEditor> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _company;
  late final TextEditingController _about;
  late final TextEditingController _website;
  late String? _location;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final Recruiter r = widget.initial;
    _name = TextEditingController(text: r.name);
    _company = TextEditingController(text: r.companyName);
    _about = TextEditingController(text: r.about);
    _website = TextEditingController(text: r.website);
    _location = r.location.isEmpty ? null : r.location;
  }

  @override
  void dispose() {
    _name.dispose();
    _company.dispose();
    _about.dispose();
    _website.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_location == null) {
      _snack('Please choose your location.');
      return;
    }
    final Recruiter updated = widget.initial.copyWith(
      name: _name.text.trim(),
      companyName: _company.text.trim(),
      about: _about.text.trim(),
      website: _website.text.trim(),
      location: _location,
    );
    setState(() => _saving = true);
    final bool ok = await widget.onSubmit(updated);
    if (mounted) setState(() => _saving = false);
    if (!ok && mounted) _snack('Could not save. Please try again.');
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          TextFormField(
            controller: _company,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Company name',
              prefixIcon: Icon(Icons.business_outlined),
            ),
            validator: (String? v) => (v == null || v.trim().isEmpty)
                ? 'Enter your company name'
                : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Your name (contact person)',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (String? v) =>
                (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _location,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Location',
              prefixIcon: Icon(Icons.place_outlined),
            ),
            items: kLocations
                .map((String loc) => DropdownMenuItem<String>(
                      value: loc,
                      child: Text(loc),
                    ))
                .toList(),
            onChanged: (String? v) => setState(() => _location = v),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _website,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Website (optional)',
              prefixIcon: Icon(Icons.link_outlined),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _about,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'About the company',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.notes_outlined),
            ),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _saving ? null : _submit,
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.submitLabel),
          ),
        ],
      ),
    );
  }
}
