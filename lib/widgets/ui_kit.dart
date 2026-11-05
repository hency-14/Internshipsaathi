import 'package:flutter/material.dart';

/// A small shared design system: the brand gradient, score/tier colours, and a
/// handful of reusable building blocks (hero header, gradient button, section
/// heading, pills, badges, empty state). Centralising these keeps every screen
/// visually consistent and lifts the app above a plain stock-Material look.

/// The signature indigo→violet gradient used on heros and primary actions.
const LinearGradient kBrandGradient = LinearGradient(
  colors: <Color>[Color(0xFF6366F1), Color(0xFF8B5CF6)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

/// The brand gradient as a rounded-bottom hero surface with soft shadow and
/// subtle decorative circles for depth. Wrap any hero's content in this so all
/// headers share one polished look.
class HeroGradientBox extends StatelessWidget {
  final Widget child;
  final double radius;
  const HeroGradientBox({super.key, required this.child, this.radius = 30});

  @override
  Widget build(BuildContext context) {
    final BorderRadius br = BorderRadius.vertical(bottom: Radius.circular(radius));
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: br,
        boxShadow: const <BoxShadow>[
          BoxShadow(
              color: Color(0x4D6366F1), blurRadius: 24, offset: Offset(0, 10)),
        ],
      ),
      child: ClipRRect(
        borderRadius: br,
        child: DecoratedBox(
          decoration: const BoxDecoration(gradient: kBrandGradient),
          child: Stack(
            children: <Widget>[
              Positioned(
                top: -50,
                right: -30,
                child: _blob(130, 0.10),
              ),
              Positioned(
                bottom: -60,
                left: -40,
                child: _blob(150, 0.08),
              ),
              Positioned(
                top: 40,
                left: -20,
                child: _blob(60, 0.07),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _blob(double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: opacity),
          shape: BoxShape.circle,
        ),
      );
}

/// A themed colour set for a match tier: a strong [base] (ring / accents) plus
/// a [bg]/[fg] pair guaranteed to read on the current brightness.
class MatchPalette {
  final Color base;
  final Color bg;
  final Color fg;
  const MatchPalette({required this.base, required this.bg, required this.fg});
}

MatchPalette matchPalette(double score, Brightness brightness) {
  final bool dark = brightness == Brightness.dark;
  late final Color light; // vivid colour for dark backgrounds
  late final Color deep; //  deep colour for light backgrounds
  if (score >= 80) {
    light = const Color(0xFF4ADE80);
    deep = const Color(0xFF15803D);
  } else if (score >= 60) {
    light = const Color(0xFF60A5FA);
    deep = const Color(0xFF1D4ED8);
  } else if (score >= 40) {
    light = const Color(0xFFFBBF24);
    deep = const Color(0xFFB45309);
  } else {
    light = const Color(0xFF94A3B8);
    deep = const Color(0xFF475569);
  }
  final Color base = dark ? light : deep;
  return MatchPalette(
    base: base,
    bg: base.withValues(alpha: dark ? 0.20 : 0.12),
    fg: dark ? light : deep,
  );
}

/// A gradient hero at the top of a screen with a large title, optional
/// subtitle, trailing actions (rendered in white) and an optional child row
/// (e.g. stat chips). Its bottom corners curve into the content below.
class GradientHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget? leading;
  final Widget? child;
  final EdgeInsets padding;

  const GradientHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const <Widget>[],
    this.leading,
    this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 8, 12, 22),
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return HeroGradientBox(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  if (leading != null) ...<Widget>[
                    leading!,
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          style: text.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (subtitle != null) ...<Widget>[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: text.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  ...actions.map((Widget a) => IconTheme(
                        data: const IconThemeData(color: Colors.white),
                        child: a,
                      )),
                ],
              ),
              if (child != null) ...<Widget>[
                const SizedBox(height: 16),
                child!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A translucent stat capsule for use inside a [GradientHeader].
class HeaderStat extends StatelessWidget {
  final IconData icon;
  final String label;
  const HeaderStat({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// A full-width primary button painted with the brand gradient. Falls back to a
/// muted surface when [onPressed] is null, and can show a spinner while busy.
class GradientButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool busy;

  const GradientButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.busy = false,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final String label = widget.label;
    final IconData? icon = widget.icon;
    final VoidCallback? onPressed = widget.onPressed;
    final bool busy = widget.busy;
    final bool enabled = onPressed != null && !busy;
    return Listener(
      onPointerDown: enabled ? (_) => setState(() => _down = true) : null,
      onPointerUp: enabled ? (_) => setState(() => _down = false) : null,
      onPointerCancel: enabled ? (_) => setState(() => _down = false) : null,
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Opacity(
          opacity: enabled ? 1 : 0.6,
          child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: enabled ? kBrandGradient : null,
          color: enabled ? null : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          boxShadow: enabled
              ? const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x4D6366F1),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: enabled ? onPressed : null,
            child: SizedBox(
              height: 54,
              child: Center(
                child: busy
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          if (icon != null) ...<Widget>[
                            Icon(icon, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
          ),
        ),
      ),
    );
  }
}

/// A section heading: a small coloured accent bar + bold title, optionally with
/// a trailing widget.
class SectionHeading extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget? trailing;
  const SectionHeading({
    super.key,
    required this.title,
    this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    return Row(
      children: <Widget>[
        if (icon != null) ...<Widget>[
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(width: 8),
        ] else ...<Widget>[
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              gradient: kBrandGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
        ],
        Text(
          title,
          style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        if (trailing != null) ...<Widget>[const Spacer(), trailing!],
      ],
    );
  }
}

/// A colour-coded tier badge driven by a match score.
class TierBadge extends StatelessWidget {
  final double score;
  final String label;
  const TierBadge({super.key, required this.score, required this.label});

  @override
  Widget build(BuildContext context) {
    final MatchPalette p =
        matchPalette(score, Theme.of(context).brightness);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: p.bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: p.base, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: p.fg,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// A bordered icon+label pill for facts (location, mode, stipend …).
class InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const InfoPill({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: scheme.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

/// A friendly empty-state: a tinted icon badge, a title and a message.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: scheme.primary),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            if (action != null) ...<Widget>[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// A rounded-square company monogram (logo stand-in) with the brand gradient.
class CompanyMonogram extends StatelessWidget {
  final String company;
  final double size;
  const CompanyMonogram({super.key, required this.company, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final String letter = company.trim().isEmpty
        ? '?'
        : company.trim().characters.first.toUpperCase();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: kBrandGradient,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x336366F1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          fontSize: size * 0.42,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}
