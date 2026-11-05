import 'package:flutter/material.dart';

import '../models/student.dart';
import '../utils/constants.dart';
import 'multi_select_chips.dart';

/// The shared form for creating and editing a student profile. It edits a
/// working copy and hands the finished [Student] back through [onSubmit];
/// both the first-run setup screen and the edit screen reuse it so the two
/// never drift apart.
class ProfileEditor extends StatefulWidget {
  final Student initial;
  final String submitLabel;

  /// Called with the updated student when the form is valid and submitted.
  /// Should return true once the save succeeds (so the button can reset).
  final Future<bool> Function(Student updated) onSubmit;

  const ProfileEditor({
    super.key,
    required this.initial,
    required this.onSubmit,
    this.submitLabel = 'Save',
  });

  @override
  State<ProfileEditor> createState() => _ProfileEditorState();
}

class _ProfileEditorState extends State<ProfileEditor> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _education;
  late final TextEditingController _bio;

  late String? _location;
  late Set<String> _skills;
  late Set<String> _interests;
  late Set<String> _goals;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final Student s = widget.initial;
    _name = TextEditingController(text: s.name);
    _education = TextEditingController(text: s.education);
    _bio = TextEditingController(text: s.bio);
    _location = s.location.isEmpty ? null : s.location;
    _skills = s.skills.toSet();
    _interests = s.interests.toSet();
    _goals = s.careerGoals.toSet();
  }

  @override
  void dispose() {
    _name.dispose();
    _education.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _toggle(Set<String> set, String value) {
    setState(() {
      if (!set.remove(value)) set.add(value);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_location == null) {
      _snack('Please choose your location.');
      return;
    }
    if (_skills.isEmpty || _interests.isEmpty || _goals.isEmpty) {
      _snack('Add at least one skill, interest and career goal.');
      return;
    }

    final Student updated = widget.initial.copyWith(
      name: _name.text.trim(),
      education: _education.text.trim(),
      bio: _bio.text.trim(),
      location: _location,
      skills: _skills.toList(),
      interests: _interests.toList(),
      careerGoals: _goals.toList(),
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
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Full name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (String? v) =>
                (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _education,
            decoration: const InputDecoration(
              labelText: 'Education (e.g. B.Tech CSE, Sem 7)',
              prefixIcon: Icon(Icons.school_outlined),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _bio,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Short bio',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.notes_outlined),
            ),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            initialValue: _location,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Preferred location',
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
          const SizedBox(height: 24),
          MultiSelectChips(
            label: 'Skills',
            options: kSkills,
            selected: _skills,
            onToggle: (String v) => _toggle(_skills, v),
          ),
          const SizedBox(height: 24),
          MultiSelectChips(
            label: 'Interests',
            options: kInterests,
            selected: _interests,
            onToggle: (String v) => _toggle(_interests, v),
          ),
          const SizedBox(height: 24),
          MultiSelectChips(
            label: 'Career goals',
            options: kCareerGoals,
            selected: _goals,
            onToggle: (String v) => _toggle(_goals, v),
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
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
