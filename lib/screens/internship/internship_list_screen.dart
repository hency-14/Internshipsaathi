import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/internship.dart';
import '../../models/match_result.dart';
import '../../providers/session_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/animations.dart';
import '../../widgets/match_card.dart';
import '../../widgets/ui_kit.dart';
import 'internship_detail_screen.dart';

/// Browse every internship with free-text search plus filters for location,
/// work mode and domain. Results still carry each internship's match score, so
/// the ranking signal is never lost, and pull-to-refresh fetches new postings.
class InternshipListScreen extends StatefulWidget {
  const InternshipListScreen({super.key});

  @override
  State<InternshipListScreen> createState() => _InternshipListScreenState();
}

class _InternshipListScreenState extends State<InternshipListScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';
  String? _location; // null = any
  WorkMode? _mode; // null = any
  String? _domain; // null = any

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _matches(Internship i) {
    if (_location != null && i.location != _location) return false;
    if (_mode != null && i.workMode != _mode) return false;
    if (_domain != null && !i.domains.contains(_domain)) return false;
    if (_query.isEmpty) return true;
    final String q = _query.toLowerCase();
    return i.title.toLowerCase().contains(q) ||
        i.company.toLowerCase().contains(q) ||
        i.location.toLowerCase().contains(q) ||
        i.requiredSkills.any((String s) => s.toLowerCase().contains(q));
  }

  bool get _hasFilters =>
      _location != null || _mode != null || _domain != null;

  void _clearFilters() => setState(() {
        _location = null;
        _mode = null;
        _domain = null;
      });

  @override
  Widget build(BuildContext context) {
    final SessionProvider session = context.watch<SessionProvider>();

    final List<MatchResult> results = session.internships
        .where(_matches)
        .map(session.matchFor)
        .toList()
      ..sort((MatchResult a, MatchResult b) => b.score.compareTo(a.score));

    return Scaffold(
      body: Column(
        children: <Widget>[
          _SearchHeader(
            controller: _search,
            query: _query,
            onChanged: (String v) => setState(() => _query = v.trim()),
            onClear: () {
              _search.clear();
              setState(() => _query = '');
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: <Widget>[
                _FilterChipMenu<String>(
                  label: 'Location',
                  value: _location,
                  options: kLocations,
                  labelOf: (String s) => s,
                  onChanged: (String? v) => setState(() => _location = v),
                ),
                const SizedBox(width: 8),
                _FilterChipMenu<WorkMode>(
                  label: 'Mode',
                  value: _mode,
                  options: WorkMode.values,
                  labelOf: (WorkMode m) => m.label,
                  onChanged: (WorkMode? v) => setState(() => _mode = v),
                ),
                const SizedBox(width: 8),
                _FilterChipMenu<String>(
                  label: 'Domain',
                  value: _domain,
                  options: kInterests,
                  labelOf: (String s) => s,
                  onChanged: (String? v) => setState(() => _domain = v),
                ),
                if (_hasFilters) ...<Widget>[
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear'),
                    onPressed: _clearFilters,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: session.refresh,
              child: results.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const <Widget>[
                        SizedBox(
                          height: 360,
                          child: EmptyState(
                            icon: Icons.manage_search_outlined,
                            title: 'No internships found',
                            message:
                                'Try removing a filter or searching for a '
                                'different role or skill.',
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: results.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (BuildContext context, int index) {
                        final MatchResult r = results[index];
                        return AnimatedEntrance(
                          index: index,
                          child: MatchCard(
                            result: r,
                            applied: session.hasApplied(r.internship.id),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => InternshipDetailScreen(
                                  internshipId: r.internship.id,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Gradient header with the screen title and an embedded white search field.
class _SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchHeader({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return HeroGradientBox(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Browse internships',
                  style: text.headlineSmall?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    filled: false,
                    hintText: 'Search role, company, skill…',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    prefixIcon:
                        Icon(Icons.search, color: Colors.grey.shade600),
                    suffixIcon: query.isEmpty
                        ? null
                        : IconButton(
                            icon: Icon(Icons.clear,
                                color: Colors.grey.shade600),
                            onPressed: onClear,
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A compact chip that opens a menu to pick (or clear) a single filter value.
class _FilterChipMenu<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> options;
  final String Function(T) labelOf;
  final ValueChanged<T?> onChanged;

  const _FilterChipMenu({
    required this.label,
    required this.value,
    required this.options,
    required this.labelOf,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool active = value != null;
    return PopupMenuButton<T?>(
      initialValue: value,
      onSelected: onChanged,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<T?>>[
        PopupMenuItem<T?>(value: null, child: Text('Any $label')),
        const PopupMenuDivider(),
        ...options.map((T o) =>
            PopupMenuItem<T?>(value: o, child: Text(labelOf(o)))),
      ],
      child: Chip(
        label: Text(active ? labelOf(value as T) : label,
            style: TextStyle(
                color: active ? scheme.onPrimaryContainer : null,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500)),
        avatar: Icon(active ? Icons.check : Icons.arrow_drop_down,
            size: 18,
            color: active ? scheme.onPrimaryContainer : null),
        backgroundColor: active ? scheme.primaryContainer : null,
        side: active
            ? BorderSide(color: scheme.primary.withValues(alpha: 0.3))
            : null,
      ),
    );
  }
}
