import 'package:flutter/material.dart';

import '../models/clearance_models.dart';
import '../theme/ccis_theme.dart';

enum StatusTone { neutral, info, success, warning, danger }

/// A compact identity mark used in the application header and sign-in surface.
class CcisBrandMark extends StatelessWidget {
  const CcisBrandMark({super.key, this.size = 42});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * .30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF285783), CcisTheme.navy],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: .32)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: CcisTheme.navy.withValues(alpha: .18),
            blurRadius: size * .42,
            offset: Offset(0, size * .15),
          ),
        ],
      ),
      child: Icon(
        Icons.verified_user_outlined,
        color: Colors.white,
        size: size * .52,
        semanticLabel: 'CCIS Clearance',
      ),
    );
  }
}

class CcisPanel extends StatelessWidget {
  const CcisPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.onTap,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final panel = AnimatedContainer(
      duration: _motionDuration(context, 220),
      curve: Curves.easeOutCubic,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor.withValues(alpha: .86)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.dark ? .16 : .045,
            ),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
    if (onTap == null) return panel;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: panel,
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.trailing,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 9),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.15,
                  ),
            ),
          ),
          if (trailing != null) trailing!,
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    this.tone = StatusTone.neutral,
    this.compact = false,
  });

  factory StatusPill.attendance(AttendanceStatus value, {Key? key}) {
    final tone = switch (value) {
      AttendanceStatus.complete => StatusTone.success,
      AttendanceStatus.excused => StatusTone.info,
      AttendanceStatus.partial => StatusTone.warning,
      AttendanceStatus.pending => StatusTone.neutral,
    };
    return StatusPill(key: key, label: value.label, tone: tone);
  }

  factory StatusPill.requirement(RequirementStatus value, {Key? key}) {
    final tone = switch (value) {
      RequirementStatus.verified => StatusTone.success,
      RequirementStatus.approved => StatusTone.success,
      RequirementStatus.deficient => StatusTone.danger,
      RequirementStatus.inProgress => StatusTone.info,
      RequirementStatus.pending => StatusTone.warning,
    };
    return StatusPill(key: key, label: value.label, tone: tone);
  }

  final String label;
  final StatusTone tone;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = _toneColors(context, tone);
    return AnimatedContainer(
      duration: _motionDuration(context, 180),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.foreground,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class ClearanceProgressCard extends StatelessWidget {
  const ClearanceProgressCard({
    super.key,
    required this.progress,
    required this.verifiedItems,
    required this.totalItems,
    required this.statusLabel,
    this.onTap,
  });

  final double progress;
  final int verifiedItems;
  final int totalItems;
  final String statusLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final safeProgress = progress.clamp(0.0, 1.0).toDouble();
    return Semantics(
      button: onTap != null,
      label: 'CCIS clearance progress ${(safeProgress * 100).round()} percent',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(19),
          child: AnimatedContainer(
            duration: _motionDuration(context, 300),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: CcisTheme.navy,
              borderRadius: BorderRadius.circular(19),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFF1D517F), CcisTheme.navy],
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: CcisTheme.navy.withValues(alpha: .30),
                  blurRadius: 20,
                  offset: const Offset(0, 9),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Expanded(
                      child: Text(
                        'CCIS clearance',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '${(safeProgress * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: safeProgress),
                  duration: _motionDuration(context, 650),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: value,
                      minHeight: 7,
                      backgroundColor: Colors.white.withValues(alpha: .22),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        '$verifiedItems of $totalItems requirements verified',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: .79)),
                      ),
                    ),
                    Text(
                      statusLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class IdentityCard extends StatelessWidget {
  const IdentityCard(
      {super.key, required this.student, this.showProgram = true});

  final StudentRecord student;
  final bool showProgram;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return CcisPanel(
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF192C43)
          : CcisTheme.paleBlue,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 21,
            backgroundColor: colorScheme.primary.withValues(alpha: .14),
            child: Text(
              student.initials,
              style: TextStyle(
                  color: colorScheme.primary, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  student.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  showProgram ? student.identityLabel : student.id,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EventRequirementCard extends StatelessWidget {
  const EventRequirementCard({
    super.key,
    required this.event,
    required this.onTap,
    this.personnelView = false,
  });

  final ClearanceEvent event;
  final VoidCallback onTap;
  final bool personnelView;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Hero(
      tag: 'event-${event.id}',
      child: Material(
        color: Colors.transparent,
        child: CcisPanel(
          semanticLabel: '${event.title}, ${event.requirementStatus.label}',
          onTap: onTap,
          color: isDark ? const Color(0xFF182535) : const Color(0xFFF8FBFE),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(Icons.event_available_outlined,
                    color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      event.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      event.requirementStatus.isSatisfied
                          ? '${event.recordedCheckpointCount}/${event.requiredDays * 4} checkpoints · verified'
                          : event.attendanceSummary,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  StatusPill.requirement(event.requirementStatus),
                  const SizedBox(height: 4),
                  Icon(
                    personnelView ? Icons.arrow_forward : Icons.chevron_right,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AttendanceDayTile extends StatelessWidget {
  const AttendanceDayTile({
    super.key,
    required this.day,
    required this.onTap,
  });

  final AttendanceDay day;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CcisPanel(
      semanticLabel: '${day.label}, ${day.status.label}',
      onTap: onTap,
      color: day.status == AttendanceStatus.complete
          ? _toneColors(context, StatusTone.success).background
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: <Widget>[
          Icon(
            day.status == AttendanceStatus.excused
                ? Icons.health_and_safety_outlined
                : Icons.calendar_month_outlined,
            color: _toneColors(context, _attendanceTone(day.status)).foreground,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(day.label,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(
                  day.status == AttendanceStatus.excused
                      ? day.excuseNote
                      : '${day.date} · ${day.checkpointSummary}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusPill.attendance(day.status),
          const SizedBox(width: 3),
          const Icon(Icons.chevron_right, size: 20),
        ],
      ),
    );
  }
}

class AttendanceCheckpointPanel extends StatelessWidget {
  const AttendanceCheckpointPanel({super.key, required this.day});

  final AttendanceDay day;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _CheckpointGroup(
          icon: Icons.wb_sunny_outlined,
          title: 'Morning',
          timeIn: day.morningTimeIn,
          timeOut: day.morningTimeOut,
        ),
        const SizedBox(height: 12),
        _CheckpointGroup(
          icon: Icons.light_mode_outlined,
          title: 'Afternoon',
          timeIn: day.afternoonTimeIn,
          timeOut: day.afternoonTimeOut,
        ),
      ],
    );
  }
}

class _CheckpointGroup extends StatelessWidget {
  const _CheckpointGroup({
    required this.icon,
    required this.title,
    required this.timeIn,
    required this.timeOut,
  });

  final IconData icon;
  final String title;
  final String? timeIn;
  final String? timeOut;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF182535)
        : const Color(0xFFF3F7FB);
    return CcisPanel(
      color: surface,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon,
                  size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 10),
          _TimeRow(label: 'Time In', value: timeIn),
          const Divider(height: 16),
          _TimeRow(label: 'Time Out', value: timeOut),
        ],
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final missing = value == null || value!.trim().isEmpty;
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Text(
          missing ? 'Not recorded' : value!,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: missing ? CcisTheme.danger : null,
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}

class AlertPanel extends StatelessWidget {
  const AlertPanel({
    super.key,
    required this.title,
    required this.message,
    this.tone = StatusTone.info,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final StatusTone tone;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = _toneColors(context, tone);
    return CcisPanel(
      color: colors.background,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon ?? Icons.info_outline, size: 20, color: colors.foreground),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colors.foreground,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        height: 1.35,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                if (actionLabel != null) ...<Widget>[
                  const SizedBox(height: 3),
                  TextButton(
                    onPressed: onAction,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      visualDensity: VisualDensity.compact,
                      foregroundColor: colors.foreground,
                    ),
                    child: Text(actionLabel!),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.tone = StatusTone.info,
    this.onTap,
  });

  final String value;
  final String label;
  final IconData icon;
  final StatusTone tone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = _toneColors(context, tone);
    return CcisPanel(
      onTap: onTap,
      color: colors.background,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: colors.foreground),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: colors.foreground,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return child;
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, nestedChild) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 18 * (1 - value)),
          child: nestedChild,
        ),
      ),
      child: child,
    );
  }
}

class _ToneColors {
  const _ToneColors(this.background, this.foreground);

  final Color background;
  final Color foreground;
}

_ToneColors _toneColors(BuildContext context, StatusTone tone) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  return switch (tone) {
    StatusTone.success => _ToneColors(
        dark ? const Color(0xFF153F32) : const Color(0xFFE4F5EB),
        dark ? const Color(0xFF8FDDAD) : CcisTheme.success,
      ),
    StatusTone.warning => _ToneColors(
        dark ? const Color(0xFF493515) : const Color(0xFFFFF4D7),
        dark ? const Color(0xFFFFD27D) : CcisTheme.warning,
      ),
    StatusTone.danger => _ToneColors(
        dark ? const Color(0xFF4A252B) : const Color(0xFFFFE9E8),
        dark ? const Color(0xFFFFB4AB) : CcisTheme.danger,
      ),
    StatusTone.info => _ToneColors(
        dark ? const Color(0xFF1D3653) : CcisTheme.paleBlue,
        dark ? const Color(0xFF9FCBFF) : CcisTheme.blue,
      ),
    StatusTone.neutral => _ToneColors(
        dark ? const Color(0xFF263545) : const Color(0xFFEFF3F7),
        dark ? const Color(0xFFC5D1DF) : const Color(0xFF52687D),
      ),
  };
}

StatusTone _attendanceTone(AttendanceStatus value) => switch (value) {
      AttendanceStatus.complete => StatusTone.success,
      AttendanceStatus.excused => StatusTone.info,
      AttendanceStatus.partial => StatusTone.warning,
      AttendanceStatus.pending => StatusTone.neutral,
    };

Duration _motionDuration(BuildContext context, int milliseconds) =>
    MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : Duration(milliseconds: milliseconds);
