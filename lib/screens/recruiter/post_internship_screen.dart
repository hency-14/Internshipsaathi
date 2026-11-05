import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/internship.dart';
import '../../providers/recruiter_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/multi_select_chips.dart';

/// Create or edit an internship posting. The fields mirror exactly what the
/// matching engine scores (skills, domains, career tracks, location), so a new
/// posting is immediately matchable to students.
class PostInternshipScreen extends StatefulWidget {
  /// When non-null, the form edits this posting instead of creating a new one.
  final Internship? existing;
  const PostInternshipScreen({super.key, this.existing});

  @override
  State<PostInternshipScreen> createState() => _PostInternshipScreenState();
}

class _PostInternshipScreenState extends State<PostInternshipScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _stipend;
  late final TextEditingController _duration;
  late final TextEditingController _description;

  late String? _location;
  late WorkMode _workMode;
  late Set<String> _skills;
  late Set<String> _domains;
  late Set<String> _tracks;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final Internship? e = widget.existing;
    _title = TextEditingController(text: e?.title ?? '');
    _stipend =
        TextEditingController(text: e == null ? '' : e.stipend.toString());
    _duration = TextEditingController(
        text: e == null ? '' : e.durationMonths.toString());
    _description = TextEditingController(text: e?.description ?? '');
    _location = e?.location;
    _workMode = e?.workMode ?? WorkMode.onsite;
    _skills = e?.requiredSkills.toSet() ?? <String>{};
    _domains = e?.domains.toSet() ?? <String>{};
    _tracks = e?.careerTracks.toSet() ?? <String>{};
  }

  @override
  void dispose() {
    _title.dispose();
    _stipend.dispose();
    _duration.dispose();
    _description.dispose();
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
      _snack('Please choose a location.');
      return;
    }
    if (_skills.isEmpty || _domains.isEmpty || _tracks.isEmpty) {
      _snack('Add at least one skill, domain and career track.');
      return;
    }

    final Internship draft = Internship(
      id: widget.existing?.id ?? '', // empty => provider generates a new id
      title: _title.text.trim(),
      company: '', // stamped by the provider from the recruiter profile
      location: _location!,
      workMode: _workMode,
      stipend: int.tryParse(_stipend.text.trim()) ?? 0,
      durationMonths: int.tryParse(_duration.text.trim()) ?? 1,
      description: _description.text.trim(),
      requiredSkills: _skills.toList(),
      domains: _domains.toList(),
      careerTracks: _tracks.toList(),
      postedAt: widget.existing?.postedAt ?? DateTime.now(),
    );

    setState(() => _saving = true);
    await context.read<RecruiterProvider>().savePosting(draft);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Text(_isEdit ? 'Posting updated.' : 'Internship posted!')));
    Navigator.of(context).pop();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(_isEdit ? 'Edit posting' : 'Post an internship')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            TextFormField(
              controller: _title,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Role title (e.g. Flutter Developer Intern)',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              validator: (String? v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
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
            const SizedBox(height: 18),
            Text('Work mode',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SegmentedButton<WorkMode>(
              segments: const <ButtonSegment<WorkMode>>[
                ButtonSegment<WorkMode>(
                    value: WorkMode.onsite, label: Text('On-site')),
                ButtonSegment<WorkMode>(
                    value: WorkMode.hybrid, label: Text('Hybrid')),
                ButtonSegment<WorkMode>(
                    value: WorkMode.remote, label: Text('Remote')),
              ],
              selected: <WorkMode>{_workMode},
              onSelectionChanged: (Set<WorkMode> s) =>
                  setState(() => _workMode = s.first),
            ),
            const SizedBox(height: 18),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _stipend,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Stipend (₹/mo)',
                      prefixIcon: Icon(Icons.currency_rupee),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _duration,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Duration (months)',
                      prefixIcon: Icon(Icons.schedule_outlined),
                    ),
                    validator: (String? v) {
                      final int? n = int.tryParse((v ?? '').trim());
                      if (n == null || n < 1) return 'Enter months';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _description,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.notes_outlined),
              ),
              validator: (String? v) => (v == null || v.trim().length < 10)
                  ? 'Add a short description'
                  : null,
            ),
            const SizedBox(height: 24),
            MultiSelectChips(
              label: 'Required skills',
              options: kSkills,
              selected: _skills,
              onToggle: (String v) => _toggle(_skills, v),
            ),
            const SizedBox(height: 24),
            MultiSelectChips(
              label: 'Domains (match student interests)',
              options: kInterests,
              selected: _domains,
              onToggle: (String v) => _toggle(_domains, v),
            ),
            const SizedBox(height: 24),
            MultiSelectChips(
              label: 'Career tracks (match student goals)',
              options: kCareerGoals,
              selected: _tracks,
              onToggle: (String v) => _toggle(_tracks, v),
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
                  : Text(_isEdit ? 'Save changes' : 'Post internship'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
