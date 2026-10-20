import 'package:flutter/material.dart';

import '../models/clearance_models.dart';
import '../state/clearance_controller.dart';
import '../widgets/ccis_widgets.dart';

/// Administrator screens added from the revised access-flow chart. They are
/// intentionally distinct from personnel record processing.
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({
    super.key,
    required this.controller,
    required this.onManagePersonnel,
    required this.onOpenAudit,
  });

  final ClearanceController controller;
  final VoidCallback onManagePersonnel;
  final VoidCallback onOpenAudit;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => _AdminPageFrame(
        eyebrow: 'System administration',
        title: 'Administration dashboard',
        subtitle: 'Manage authorized personnel and review protected activity.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            LayoutBuilder(
              builder: (context, constraints) => Wrap(
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  SizedBox(
                    width: _metricWidth(constraints.maxWidth),
                    height: 132,
                    child: MetricCard(
                      value: '${controller.activePersonnelCount}',
                      label: 'Active personnel',
                      icon: Icons.verified_user_outlined,
                      tone: StatusTone.success,
                      onTap: onManagePersonnel,
                    ),
                  ),
                  SizedBox(
                    width: _metricWidth(constraints.maxWidth),
                    height: 132,
                    child: MetricCard(
                      value: '${controller.inactivePersonnelCount}',
                      label: 'Inactive accounts',
                      icon: Icons.person_off_outlined,
                      tone: StatusTone.warning,
                      onTap: onManagePersonnel,
                    ),
                  ),
                  SizedBox(
                    width: _metricWidth(constraints.maxWidth),
                    height: 132,
                    child: MetricCard(
                      value: '${controller.auditLog.length}',
                      label: 'Audited activities',
                      icon: Icons.history_outlined,
                      tone: StatusTone.info,
                      onTap: onOpenAudit,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 17),
            SectionTitle(
              title: 'Access management',
              actionLabel: 'Manage personnel',
              onAction: onManagePersonnel,
            ),
            CcisPanel(
              onTap: onManagePersonnel,
              semanticLabel: 'Manage personnel accounts',
              child: Row(
                children: <Widget>[
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(Icons.manage_accounts_outlined,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Authorized CCIS personnel',
                            style: TextStyle(fontWeight: FontWeight.w800)),
                        SizedBox(height: 3),
                        Text(
                            'Create, update, activate, or deactivate personnel accounts.'),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SectionTitle(
                title: 'Recent audit activity',
                actionLabel: 'View all',
                onAction: onOpenAudit),
            for (final entry in controller.auditLog.take(3)) ...<Widget>[
              _AuditTile(entry: entry),
              const SizedBox(height: 9),
            ],
            const SizedBox(height: 4),
            const AlertPanel(
              title: 'Protected administrative actions',
              message:
                  'Login, logout, account creation, and updates retain an audit entry with the action, actor, date, and time.',
              tone: StatusTone.info,
            ),
          ],
        ),
      ),
    );
  }
}

class AdminPersonnelPage extends StatefulWidget {
  const AdminPersonnelPage({super.key, required this.controller});

  final ClearanceController controller;

  @override
  State<AdminPersonnelPage> createState() => _AdminPersonnelPageState();
}

class _AdminPersonnelPageState extends State<AdminPersonnelPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage personnel')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreatePersonnel(context),
        icon: const Icon(Icons.person_add_alt_1_outlined),
        label: const Text('Add personnel'),
      ),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          final people = widget.controller.personnel.where((person) {
            final query = _query.trim().toLowerCase();
            return query.isEmpty ||
                person.displayName.toLowerCase().contains(query) ||
                person.id.toLowerCase().contains(query);
          }).toList();
          return _AdminPageFrame(
            eyebrow: 'System administration',
            title: 'Authorized personnel',
            subtitle:
                'Create and update personnel access for CCIS clearance processing.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextField(
                  onChanged: (value) => setState(() => _query = value),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search personnel name or ID',
                  ),
                ),
                const SizedBox(height: 15),
                SectionTitle(
                    title: 'Personnel accounts',
                    trailing: Text('${people.length} records')),
                if (people.isEmpty)
                  const _AdminEmptyState(
                    icon: Icons.search_off_outlined,
                    title: 'No personnel found',
                    message: 'Try a different search term.',
                  )
                else
                  for (final person in people) ...<Widget>[
                    _PersonnelAccountTile(
                      person: person,
                      onToggle: () => widget.controller.setPersonnelStatus(
                        person.id,
                        person.status == AccountStatus.active
                            ? AccountStatus.inactive
                            : AccountStatus.active,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                const SizedBox(height: 72),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCreatePersonnel(BuildContext context) {
    final first = TextEditingController();
    final middle = TextEditingController();
    final last = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create personnel account'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                  controller: first,
                  decoration: const InputDecoration(labelText: 'First name')),
              const SizedBox(height: 10),
              TextField(
                  controller: middle,
                  maxLength: 1,
                  decoration: const InputDecoration(
                      labelText: 'Middle initial (optional)')),
              const SizedBox(height: 10),
              TextField(
                  controller: last,
                  decoration: const InputDecoration(labelText: 'Last name')),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final saved = widget.controller.createPersonnel(
                firstName: first.text,
                middleInitial: middle.text,
                lastName: last.text,
              );
              if (!saved) return;
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Personnel account created and audited.')),
              );
            },
            child: const Text('Create account'),
          ),
        ],
      ),
    ).whenComplete(() {
      first.dispose();
      middle.dispose();
      last.dispose();
    });
  }
}

class AuditLogPage extends StatelessWidget {
  const AuditLogPage({super.key, required this.controller});

  final ClearanceController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audit log')),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => _AdminPageFrame(
          eyebrow: 'System administration',
          title: 'Audit activity',
          subtitle:
              'Protected records of login, logout, create, and update actions.',
          child: Column(
            children: <Widget>[
              for (final entry in controller.auditLog) ...<Widget>[
                _AuditTile(entry: entry),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Personnel use this page to manage the status of CCIS requirements and
/// fines. Updates immediately change the student's visible progress cards.
class RequirementManagerPage extends StatelessWidget {
  const RequirementManagerPage({super.key, required this.controller});

  final ClearanceController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage requirements')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddRequirement(context, controller),
        icon: const Icon(Icons.add_task_outlined),
        label: const Text('Add requirement'),
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final student = controller.selectedStudent;
          return _AdminPageFrame(
            eyebrow: 'Authorized CCIS personnel',
            title: 'Requirements and fines',
            subtitle:
                'Update the selected student’s CCIS requirement status and fine records.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CcisPanel(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: .08),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(child: Text(student.initials)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(student.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800))),
                      Text(student.id,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                const SectionTitle(title: 'CCIS requirements'),
                for (final requirement in student.requirements) ...<Widget>[
                  _ManagedRequirementTile(
                    requirement: requirement,
                    onEdit: () =>
                        _showEditRequirement(context, controller, requirement),
                  ),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 72),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AdminPageFrame extends StatelessWidget {
  const _AdminPageFrame({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(constraints.maxWidth >= 768 ? 28 : 16,
              18, constraints.maxWidth >= 768 ? 28 : 16, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1160),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    eyebrow.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .5,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(title,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 18),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PersonnelAccountTile extends StatelessWidget {
  const _PersonnelAccountTile({required this.person, required this.onToggle});

  final PersonnelAccount person;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final active = person.status == AccountStatus.active;
    return CcisPanel(
      child: Row(
        children: <Widget>[
          CircleAvatar(
              child: Text('${person.firstName[0]}${person.lastName[0]}')),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(person.displayName,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text('Created ${person.createdAtLabel}',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              StatusPill(
                  label: person.status.label,
                  tone: active ? StatusTone.success : StatusTone.warning),
              const SizedBox(height: 4),
              TextButton(
                  onPressed: onToggle,
                  child: Text(active ? 'Deactivate' : 'Activate')),
            ],
          ),
        ],
      ),
    );
  }
}

class _AuditTile extends StatelessWidget {
  const _AuditTile({required this.entry});

  final AuditEntry entry;

  @override
  Widget build(BuildContext context) {
    return CcisPanel(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.history_outlined,
                color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(entry.action,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(entry.detail,
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 6),
                Text('${entry.actor} · ${entry.timestampLabel}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ManagedRequirementTile extends StatelessWidget {
  const _ManagedRequirementTile(
      {required this.requirement, required this.onEdit});

  final Requirement requirement;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return CcisPanel(
      onTap: onEdit,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
              requirement.hasAmount
                  ? Icons.receipt_long_outlined
                  : Icons.assignment_outlined,
              color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(requirement.title,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(requirement.category,
                    style: Theme.of(context).textTheme.bodySmall),
                if (requirement.hasAmount) ...<Widget>[
                  const SizedBox(height: 3),
                  Text('Fine: ₱${requirement.amount!.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              StatusPill.requirement(requirement.status),
              const SizedBox(height: 4),
              const Icon(Icons.edit_outlined, size: 19),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminEmptyState extends StatelessWidget {
  const _AdminEmptyState(
      {required this.icon, required this.title, required this.message});

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return CcisPanel(
      child: Column(
        children: <Widget>[
          Icon(icon, size: 34, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

double _metricWidth(double available) {
  if (available >= 880) return (available - 20) / 3;
  if (available >= 520) return (available - 10) / 2;
  return available;
}

void _showAddRequirement(BuildContext context, ClearanceController controller) {
  final title = TextEditingController();
  final category = TextEditingController(text: 'CCIS requirement');
  final note = TextEditingController();
  final amount = TextEditingController();
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Add requirement or fine'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
                controller: title,
                decoration:
                    const InputDecoration(labelText: 'Requirement title')),
            const SizedBox(height: 10),
            TextField(
                controller: category,
                decoration: const InputDecoration(labelText: 'Category')),
            const SizedBox(height: 10),
            TextField(
                controller: amount,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration:
                    const InputDecoration(labelText: 'Fine amount (optional)')),
            const SizedBox(height: 10),
            TextField(
                controller: note,
                maxLines: 2,
                decoration:
                    const InputDecoration(labelText: 'Note (optional)')),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final parsedAmount = double.tryParse(amount.text.trim());
            final saved = controller.addRequirement(
              title: title.text,
              category: category.text,
              note: note.text,
              amount: parsedAmount,
            );
            if (!saved) return;
            Navigator.of(dialogContext).pop();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Requirement added and student notified.')));
          },
          child: const Text('Add requirement'),
        ),
      ],
    ),
  ).whenComplete(() {
    title.dispose();
    category.dispose();
    note.dispose();
    amount.dispose();
  });
}

void _showEditRequirement(BuildContext context, ClearanceController controller,
    Requirement requirement) {
  final note = TextEditingController(text: requirement.note);
  final amount =
      TextEditingController(text: requirement.amount?.toStringAsFixed(2) ?? '');
  var status = requirement.status;
  showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text('Update ${requirement.title}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DropdownButtonFormField<RequirementStatus>(
                initialValue: status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: RequirementStatus.values
                    .map((value) => DropdownMenuItem(
                        value: value, child: Text(value.label)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setDialogState(() => status = value);
                },
              ),
              const SizedBox(height: 10),
              TextField(
                  controller: amount,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      labelText: 'Fine amount (optional)')),
              const SizedBox(height: 10),
              TextField(
                  controller: note,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Update note')),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final saved = controller.updateRequirement(
                requirementId: requirement.id,
                status: status,
                note: note.text,
                amount: double.tryParse(amount.text.trim()),
              );
              if (!saved) return;
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                      'Requirement updated. Student progress refreshed.')));
            },
            child: const Text('Save update'),
          ),
        ],
      ),
    ),
  ).whenComplete(() {
    note.dispose();
    amount.dispose();
  });
}
