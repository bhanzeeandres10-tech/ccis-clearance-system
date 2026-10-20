import 'package:flutter/material.dart';

import 'admin_pages.dart';
import '../models/clearance_models.dart';
import '../state/clearance_controller.dart';
import '../theme/ccis_theme.dart';
import '../widgets/ccis_widgets.dart';

enum AppSection {
  home,
  clearance,
  updates,
  profile,
  students,
  records,
  adminPersonnel,
  audit,
}

/// The responsive authenticated shell. Mobile uses a wireframe-style bottom
/// bar; larger screens keep the same journeys in a compact or expanded rail.
class CcisAppShell extends StatefulWidget {
  const CcisAppShell({super.key, required this.controller});

  final ClearanceController controller;

  @override
  State<CcisAppShell> createState() => _CcisAppShellState();
}

class _CcisAppShellState extends State<CcisAppShell> {
  late AppSection _section;

  @override
  void initState() {
    super.initState();
    _section = widget.controller.role == UserRole.student
        ? AppSection.home
        : AppSection.home;
  }

  List<_Destination> get _destinations {
    if (widget.controller.role == UserRole.student) {
      return const <_Destination>[
        _Destination(AppSection.home, 'Home', Icons.home_outlined, Icons.home),
        _Destination(
          AppSection.clearance,
          'Clearance',
          Icons.assignment_outlined,
          Icons.assignment,
        ),
        _Destination(
          AppSection.updates,
          'Updates',
          Icons.notifications_none_rounded,
          Icons.notifications_rounded,
        ),
        _Destination(
            AppSection.profile, 'Profile', Icons.person_outline, Icons.person),
      ];
    }
    if (widget.controller.role == UserRole.personnel) {
      return const <_Destination>[
        _Destination(AppSection.home, 'Home', Icons.home_outlined, Icons.home),
        _Destination(AppSection.students, 'Students', Icons.people_outline,
            Icons.people),
        _Destination(AppSection.records, 'Records', Icons.assignment_outlined,
            Icons.assignment),
        _Destination(
          AppSection.updates,
          'Updates',
          Icons.notifications_none_rounded,
          Icons.notifications_rounded,
        ),
      ];
    }
    return const <_Destination>[
      _Destination(AppSection.home, 'Home', Icons.home_outlined, Icons.home),
      _Destination(
        AppSection.adminPersonnel,
        'Personnel',
        Icons.manage_accounts_outlined,
        Icons.manage_accounts,
      ),
      _Destination(
          AppSection.audit, 'Audit', Icons.history_outlined, Icons.history),
    ];
  }

  void _select(AppSection value) {
    setState(() => _section = value);
  }

  @override
  Widget build(BuildContext context) {
    final destinations = _destinations;
    final effectiveSection =
        destinations.any((item) => item.section == _section)
            ? _section
            : destinations.first.section;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        final isWide = constraints.maxWidth >= 1180;
        final content = AnimatedSwitcher(
          duration: _motion(context, 240),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(.018, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                  parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            ),
          ),
          // Keep each destination constrained to the entire Scaffold body.
          // The default AnimatedSwitcher Stack uses loose constraints and can
          // collapse a page after navigation on narrow web viewports.
          layoutBuilder: (currentChild, previousChildren) => Stack(
            fit: StackFit.expand,
            children: <Widget>[
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          ),
          child: KeyedSubtree(
            key: ValueKey<AppSection>(effectiveSection),
            child: _buildSection(effectiveSection),
          ),
        );

        if (isMobile) {
          return Scaffold(
            appBar: _mobileAppBar(effectiveSection),
            body: content,
            bottomNavigationBar:
                _mobileNavigation(destinations, effectiveSection),
          );
        }

        return Scaffold(
          body: SafeArea(
            child: Row(
              children: <Widget>[
                _desktopRail(destinations, effectiveSection, extended: isWide),
                VerticalDivider(
                    width: 1, color: Theme.of(context).dividerColor),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      _desktopHeader(effectiveSection),
                      Expanded(child: content),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  AppBar _mobileAppBar(AppSection section) => AppBar(
        titleSpacing: 16,
        title: Row(
          children: <Widget>[
            const CcisBrandMark(size: 34),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('CCIS CLEARANCE', style: TextStyle(fontSize: 14)),
                  Text(
                    _sectionSubtitle(section),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Switch color theme',
            onPressed: widget.controller.toggleTheme,
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: widget.controller.signOut,
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      );

  Widget _desktopHeader(AppSection section) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF101B29) : Colors.white,
        border:
            Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _sectionTitle(section),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Text(
                  _sectionSubtitle(section),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          _RoleBadge(role: widget.controller.role),
          const SizedBox(width: 12),
          IconButton.filledTonal(
            tooltip: 'Switch color theme',
            onPressed: widget.controller.toggleTheme,
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
          const SizedBox(width: 4),
          IconButton.outlined(
            tooltip: 'Sign out',
            onPressed: widget.controller.signOut,
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
    );
  }

  Widget _desktopRail(
    List<_Destination> destinations,
    AppSection current, {
    required bool extended,
  }) {
    final theme = Theme.of(context);
    return Container(
      color: theme.navigationRailTheme.backgroundColor,
      child: NavigationRail(
        extended: extended,
        minExtendedWidth: 232,
        selectedIndex:
            destinations.indexWhere((item) => item.section == current),
        onDestinationSelected: (index) => _select(destinations[index].section),
        leading: Padding(
          padding: const EdgeInsets.fromLTRB(16, 19, 16, 14),
          child: extended
              ? const Row(
                  children: <Widget>[
                    CcisBrandMark(size: 39),
                    SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        'CCIS\nCLEARANCE',
                        style: TextStyle(
                            fontWeight: FontWeight.w900, height: 1.05),
                      ),
                    ),
                  ],
                )
              : const CcisBrandMark(size: 39),
        ),
        destinations: destinations
            .map(
              (item) => NavigationRailDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: Text(item.label),
              ),
            )
            .toList(growable: false),
        trailing: Padding(
          padding: const EdgeInsets.all(14),
          child: extended
              ? OutlinedButton.icon(
                  onPressed: widget.controller.signOut,
                  icon: const Icon(Icons.logout_outlined, size: 18),
                  label: const Text('Sign out'),
                )
              : IconButton(
                  tooltip: 'Sign out',
                  onPressed: widget.controller.signOut,
                  icon: const Icon(Icons.logout_outlined),
                ),
        ),
      ),
    );
  }

  Widget _mobileNavigation(
      List<_Destination> destinations, AppSection current) {
    return NavigationBar(
      selectedIndex: destinations.indexWhere((item) => item.section == current),
      onDestinationSelected: (index) => _select(destinations[index].section),
      destinations: destinations
          .map(
            (item) => NavigationDestination(
              icon: item.section == AppSection.updates &&
                      widget.controller.unreadNotifications > 0
                  ? Badge(
                      label: Text('${widget.controller.unreadNotifications}'),
                      child: Icon(item.icon),
                    )
                  : Icon(item.icon),
              selectedIcon: Icon(item.selectedIcon),
              label: item.label,
            ),
          )
          .toList(growable: false),
    );
  }

  Widget _buildSection(AppSection section) {
    return switch (section) {
      AppSection.home => switch (widget.controller.role) {
          UserRole.student => _StudentDashboard(
              controller: widget.controller,
              onOpenClearance: () => _select(AppSection.clearance),
              onOpenEvent: _openEvent,
              onOpenUpdates: () => _select(AppSection.updates),
            ),
          UserRole.personnel => _PersonnelDashboard(
              controller: widget.controller,
              onOpenStudents: () => _select(AppSection.students),
              onOpenRecord: () => _select(AppSection.records),
            ),
          UserRole.admin => AdminDashboard(
              controller: widget.controller,
              onManagePersonnel: () => _select(AppSection.adminPersonnel),
              onOpenAudit: () => _select(AppSection.audit),
            ),
        },
      AppSection.clearance => _StudentClearancePage(
          controller: widget.controller,
          onOpenEvent: _openEvent,
        ),
      AppSection.updates => _UpdatesPage(controller: widget.controller),
      AppSection.profile => _ProfilePage(controller: widget.controller),
      AppSection.students => _StudentDirectory(
          controller: widget.controller,
          onOpenRecord: () => _select(AppSection.records),
        ),
      AppSection.records => _PersonnelRecordPage(
          controller: widget.controller,
          onOpenEvent: _openEvent,
          onOpenDeficiencies: _openDeficiencies,
          onOpenRequirements: _openRequirements,
          onOpenReview: _openReview,
        ),
      AppSection.adminPersonnel =>
        AdminPersonnelPage(controller: widget.controller),
      AppSection.audit => AuditLogPage(controller: widget.controller),
    };
  }

  void _openEvent(ClearanceEvent event) {
    Navigator.of(context).push(
      _ccisRoute(
        EventDetailPage(
          controller: widget.controller,
          eventId: event.id,
          personnelView: widget.controller.role == UserRole.personnel,
        ),
      ),
    );
  }

  void _openDeficiencies() {
    Navigator.of(context).push(
      _ccisRoute(DeficiencyManagerPage(controller: widget.controller)),
    );
  }

  void _openReview() {
    Navigator.of(context).push(
      _ccisRoute(ReviewClearancePage(controller: widget.controller)),
    );
  }

  void _openRequirements() {
    Navigator.of(context).push(
      _ccisRoute(RequirementManagerPage(controller: widget.controller)),
    );
  }

  String _sectionTitle(AppSection section) => switch (section) {
        AppSection.home => switch (widget.controller.role) {
            UserRole.student => 'Student dashboard',
            UserRole.personnel => 'Personnel dashboard',
            UserRole.admin => 'Administration dashboard',
          },
        AppSection.clearance => 'Clearance overview',
        AppSection.updates => 'Updates',
        AppSection.profile => 'Student profile',
        AppSection.students => 'Student search',
        AppSection.records => 'Student clearance record',
        AppSection.adminPersonnel => 'Manage personnel',
        AppSection.audit => 'Audit log',
      };

  String _sectionSubtitle(AppSection section) => switch (section) {
        AppSection.home => switch (widget.controller.role) {
            UserRole.student => 'CCIS student services',
            UserRole.personnel => 'Authorized CCIS personnel',
            UserRole.admin => 'System administration',
          },
        AppSection.clearance => 'CCIS student services',
        AppSection.profile => 'CCIS student services',
        AppSection.updates => 'CCIS clearance activity',
        AppSection.students => 'Authorized CCIS personnel',
        AppSection.records => 'Authorized CCIS personnel',
        AppSection.adminPersonnel => 'System administration',
        AppSection.audit => 'System administration',
      };
}

class _StudentDashboard extends StatelessWidget {
  const _StudentDashboard({
    required this.controller,
    required this.onOpenClearance,
    required this.onOpenEvent,
    required this.onOpenUpdates,
  });

  final ClearanceController controller;
  final VoidCallback onOpenClearance;
  final ValueChanged<ClearanceEvent> onOpenEvent;
  final VoidCallback onOpenUpdates;

  @override
  Widget build(BuildContext context) {
    final student = controller.selectedStudent;
    final latest = controller.notifications.first;
    return _PageScroll(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          final overview = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FadeSlideIn(
                child: _PageIntro(
                  eyebrow: 'RMMC-MI / CCIS',
                  title: 'Good morning, ${student.name.split(' ').first}.',
                  subtitle: 'Keep track of your CCIS clearance in one place.',
                ),
              ),
              const SizedBox(height: 17),
              FadeSlideIn(
                child: ClearanceProgressCard(
                  progress: student.clearanceProgress,
                  verifiedItems: student.verifiedClearanceItems,
                  totalItems: student.totalClearanceItems,
                  statusLabel: student.isApproved ? 'Approved' : 'In progress',
                  onTap: onOpenClearance,
                ),
              ),
              const SizedBox(height: 15),
              if (student.openDeficiencyCount > 0)
                FadeSlideIn(
                  child: AlertPanel(
                    title: '${student.openDeficiencyCount} open deficiencies',
                    message:
                        'CCIS records still need attention before final clearance approval.',
                    tone: StatusTone.warning,
                    icon: Icons.error_outline,
                    actionLabel: 'Review clearance',
                    onAction: onOpenClearance,
                  ),
                ),
              const SizedBox(height: 12),
              SectionTitle(
                  title: 'Latest update',
                  actionLabel: 'View all',
                  onAction: onOpenUpdates),
              _NotificationCard(
                notification: latest,
                onTap: () {
                  controller.markNotificationRead(latest.id);
                  onOpenUpdates();
                },
              ),
            ],
          );

          final events = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SectionTitle(
                title: 'Your event requirements',
                actionLabel: 'View all',
                onAction: onOpenClearance,
              ),
              for (final event in student.events) ...<Widget>[
                EventRequirementCard(
                    event: event, onTap: () => onOpenEvent(event)),
                const SizedBox(height: 10),
              ],
            ],
          );

          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[overview, const SizedBox(height: 14), events],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(flex: 5, child: overview),
              const SizedBox(width: 22),
              Expanded(flex: 6, child: events),
            ],
          );
        },
      ),
    );
  }
}

class _StudentClearancePage extends StatelessWidget {
  const _StudentClearancePage(
      {required this.controller, required this.onOpenEvent});

  final ClearanceController controller;
  final ValueChanged<ClearanceEvent> onOpenEvent;

  @override
  Widget build(BuildContext context) {
    final student = controller.selectedStudent;
    return _PageScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _PageIntro(
            eyebrow: 'CCIS clearance',
            title: 'Clearance overview',
            subtitle:
                'Review event attendance, requirements, and any next steps.',
          ),
          const SizedBox(height: 16),
          IdentityCard(student: student),
          const SizedBox(height: 12),
          _TermCard(student: student),
          const SizedBox(height: 12),
          ClearanceProgressCard(
            progress: student.clearanceProgress,
            verifiedItems: student.verifiedClearanceItems,
            totalItems: student.totalClearanceItems,
            statusLabel: student.isApproved ? 'Approved' : 'In progress',
          ),
          const SizedBox(height: 15),
          const SectionTitle(title: 'Event requirements'),
          for (final event in student.events) ...<Widget>[
            EventRequirementCard(event: event, onTap: () => onOpenEvent(event)),
            const SizedBox(height: 10),
          ],
          if (student.requirements.isNotEmpty) ...<Widget>[
            const SizedBox(height: 4),
            SectionTitle(
                title: 'Open deficiencies',
                trailing: Text('${student.openDeficiencyCount} records')),
            for (final requirement in student.requirements) ...<Widget>[
              _RequirementTile(requirement: requirement),
              const SizedBox(height: 10),
            ],
          ],
          const SizedBox(height: 4),
          AlertPanel(
            title: 'What happens next?',
            message: student.canApprove || student.isApproved
                ? 'Your attendance and CCIS requirements are ready for an authorized final review.'
                : 'Complete or resolve the outstanding CCIS items, then wait for authorized verification.',
            tone: StatusTone.info,
          ),
          const SizedBox(height: 12),
          _ViewOnlyHint(),
        ],
      ),
    );
  }
}

class _UpdatesPage extends StatelessWidget {
  const _UpdatesPage({required this.controller});

  final ClearanceController controller;

  @override
  Widget build(BuildContext context) {
    final notices = controller.notifications;
    return _PageScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _PageIntro(
            eyebrow: 'CCIS clearance',
            title: 'Notifications',
            subtitle: 'Updates about attendance, deficiencies, and approval.',
            trailing: TextButton.icon(
              onPressed: controller.unreadNotifications == 0
                  ? null
                  : controller.markAllNotificationsRead,
              icon: const Icon(Icons.done_all_outlined, size: 18),
              label: const Text('Mark all read'),
            ),
          ),
          const SizedBox(height: 14),
          if (controller.unreadNotifications > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: StatusPill(
                label: '${controller.unreadNotifications} unread',
                tone: StatusTone.info,
              ),
            ),
          for (var index = 0; index < notices.length; index++) ...<Widget>[
            FadeSlideIn(
              child: _NotificationCard(
                notification: notices[index],
                onTap: () => controller.markNotificationRead(notices[index].id),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage({required this.controller});

  final ClearanceController controller;

  @override
  Widget build(BuildContext context) {
    final student = controller.selectedStudent;
    return _PageScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _PageIntro(
            eyebrow: 'CCIS student services',
            title: 'Student profile',
            subtitle: 'Your academic and account details.',
          ),
          const SizedBox(height: 16),
          IdentityCard(student: student),
          const SizedBox(height: 15),
          const SectionTitle(title: 'Academic information'),
          CcisPanel(
            child: Column(
              children: <Widget>[
                _InfoRow('Full name', student.name),
                _InfoRow('Student no.', student.id),
                _InfoRow('Program', student.program),
                _InfoRow('Year / section', student.academicLabel),
                _InfoRow('Department', student.department, isLast: true),
              ],
            ),
          ),
          const SizedBox(height: 15),
          const SectionTitle(title: 'Appearance'),
          CcisPanel(
            child: SegmentedButton<ThemeMode>(
              segments: const <ButtonSegment<ThemeMode>>[
                ButtonSegment(
                    value: ThemeMode.light,
                    label: Text('Light'),
                    icon: Icon(Icons.light_mode_outlined)),
                ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text('Dark'),
                    icon: Icon(Icons.dark_mode_outlined)),
                ButtonSegment(
                    value: ThemeMode.system,
                    label: Text('System'),
                    icon: Icon(Icons.brightness_auto_outlined)),
              ],
              selected: <ThemeMode>{controller.themeMode},
              showSelectedIcon: false,
              onSelectionChanged: (values) =>
                  controller.setThemeMode(values.first),
            ),
          ),
          const SizedBox(height: 15),
          const SectionTitle(title: 'Account & support'),
          CcisPanel(
            padding: EdgeInsets.zero,
            child: Column(
              children: <Widget>[
                _SettingsTile(
                    icon: Icons.key_outlined, label: 'Change password'),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                _SettingsTile(
                    icon: Icons.support_agent_outlined,
                    label: 'Contact CCIS personnel'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AlertPanel(
            title: 'Official records are protected',
            message:
                'Only authorized CCIS personnel can update attendance and clearance records.',
            tone: StatusTone.info,
          ),
          const SizedBox(height: 15),
          OutlinedButton.icon(
            onPressed: controller.signOut,
            icon: const Icon(Icons.logout_outlined),
            label: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}

class _PersonnelDashboard extends StatelessWidget {
  const _PersonnelDashboard({
    required this.controller,
    required this.onOpenStudents,
    required this.onOpenRecord,
  });

  final ClearanceController controller;
  final VoidCallback onOpenStudents;
  final VoidCallback onOpenRecord;

  @override
  Widget build(BuildContext context) {
    return _PageScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _PageIntro(
            eyebrow: 'Authorized CCIS personnel',
            title: 'Good morning, Nina.',
            subtitle:
                'Review attendance, deficiencies, and final clearance records.',
            trailing: FilledButton.icon(
              onPressed: onOpenStudents,
              icon: const Icon(Icons.search, size: 18),
              label: const Text('Find a student'),
            ),
          ),
          const SizedBox(height: 17),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 880
                  ? 3
                  : constraints.maxWidth >= 510
                      ? 2
                      : 1;
              final items = <Widget>[
                MetricCard(
                  value: '${controller.pendingAttendanceCount}',
                  label: 'Pending attendance review',
                  icon: Icons.fact_check_outlined,
                  tone: StatusTone.info,
                  onTap: onOpenRecord,
                ),
                MetricCard(
                  value: '${controller.openDeficiencyCount}',
                  label: 'Open deficiencies',
                  icon: Icons.error_outline,
                  tone: StatusTone.warning,
                  onTap: onOpenRecord,
                ),
                MetricCard(
                  value: '${controller.approvedClearanceCount}',
                  label: 'CCIS approved',
                  icon: Icons.verified_user_outlined,
                  tone: StatusTone.success,
                  onTap: onOpenRecord,
                ),
              ];
              return _EqualGrid(columns: columns, children: items);
            },
          ),
          const SizedBox(height: 17),
          SectionTitle(
              title: 'Priority queue',
              actionLabel: 'View students',
              onAction: onOpenStudents),
          for (final student in controller.students.take(3)) ...<Widget>[
            _PersonnelStudentTile(
              student: student,
              onTap: () {
                controller.selectStudent(student.id);
                onOpenRecord();
              },
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 4),
          AlertPanel(
            title: 'Authorized CCIS workspace',
            message:
                'Attendance updates save the current event status. Verify and approve only when the required guards are met.',
            tone: StatusTone.info,
          ),
        ],
      ),
    );
  }
}

class _StudentDirectory extends StatefulWidget {
  const _StudentDirectory(
      {required this.controller, required this.onOpenRecord});

  final ClearanceController controller;
  final VoidCallback onOpenRecord;

  @override
  State<_StudentDirectory> createState() => _StudentDirectoryState();
}

class _StudentDirectoryState extends State<_StudentDirectory> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final students = widget.controller.searchStudents(_query);
    return _PageScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _PageIntro(
            eyebrow: 'Authorized CCIS personnel',
            title: 'Student search',
            subtitle:
                'Find a CCIS student to review attendance, requirements, and clearance status.',
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search name or student number',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              FilterChip(
                  label: const Text('All programs'),
                  selected: true,
                  onSelected: (_) {}),
              FilterChip(
                  label: const Text('1st sem 2026–27'),
                  selected: false,
                  onSelected: (_) {}),
            ],
          ),
          const SizedBox(height: 14),
          SectionTitle(
              title: 'Student records',
              trailing: Text('${students.length} students')),
          if (students.isEmpty)
            const _EmptyState(
              icon: Icons.search_off_outlined,
              title: 'No student found',
              message: 'Try another student name or number.',
            )
          else
            for (final student in students) ...<Widget>[
              _PersonnelStudentTile(
                student: student,
                onTap: () {
                  widget.controller.selectStudent(student.id);
                  widget.onOpenRecord();
                },
              ),
              const SizedBox(height: 10),
            ],
          const SizedBox(height: 8),
          AlertPanel(
            title: 'CCIS records only',
            message:
                'Student information here is available only to authorized CCIS personnel for clearance processing.',
            tone: StatusTone.info,
          ),
        ],
      ),
    );
  }
}

class _PersonnelRecordPage extends StatelessWidget {
  const _PersonnelRecordPage({
    required this.controller,
    required this.onOpenEvent,
    required this.onOpenDeficiencies,
    required this.onOpenRequirements,
    required this.onOpenReview,
  });

  final ClearanceController controller;
  final ValueChanged<ClearanceEvent> onOpenEvent;
  final VoidCallback onOpenDeficiencies;
  final VoidCallback onOpenRequirements;
  final VoidCallback onOpenReview;

  @override
  Widget build(BuildContext context) {
    final student = controller.selectedStudent;
    return _PageScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _PageIntro(
            eyebrow: 'Authorized CCIS personnel',
            title: 'Student clearance record',
            subtitle:
                'Review official attendance and applicable CCIS requirements.',
          ),
          const SizedBox(height: 16),
          IdentityCard(student: student),
          const SizedBox(height: 12),
          _TermCard(student: student),
          const SizedBox(height: 12),
          ClearanceProgressCard(
            progress: student.clearanceProgress,
            verifiedItems: student.verifiedClearanceItems,
            totalItems: student.totalClearanceItems,
            statusLabel: student.isApproved ? 'Approved' : 'In progress',
          ),
          const SizedBox(height: 15),
          const SectionTitle(title: 'Requirement review'),
          for (final event in student.events) ...<Widget>[
            EventRequirementCard(
                event: event,
                personnelView: true,
                onTap: () => onOpenEvent(event)),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 2),
          SectionTitle(
            title: 'Open deficiencies',
            trailing: TextButton(
                onPressed: onOpenDeficiencies, child: const Text('Manage')),
          ),
          if (student.openDeficiencyCount == 0)
            AlertPanel(
              title: 'No open deficiencies',
              message:
                  'All CCIS record deficiencies for this student are resolved.',
              tone: StatusTone.success,
              icon: Icons.check_circle_outline,
            )
          else
            for (final requirement in student.requirements
                .where((item) => item.isDeficient)) ...<Widget>[
              _RequirementTile(
                  requirement: requirement,
                  personnelView: true,
                  onTap: onOpenDeficiencies),
              const SizedBox(height: 10),
            ],
          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed: onOpenRequirements,
            icon: const Icon(Icons.tune_outlined),
            label: const Text('Manage requirements and fines'),
          ),
          const SizedBox(height: 9),
          FilledButton.icon(
            onPressed: onOpenReview,
            icon: const Icon(Icons.verified_user_outlined),
            label: const Text('Review final clearance'),
          ),
        ],
      ),
    );
  }
}

/// Full event status for either student (view-only) or personnel (editable).
class EventDetailPage extends StatelessWidget {
  const EventDetailPage({
    super.key,
    required this.controller,
    required this.eventId,
    required this.personnelView,
  });

  final ClearanceController controller;
  final String eventId;
  final bool personnelView;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: controller,
        builder: (context, _) => _buildPage(context),
      );

  Widget _buildPage(BuildContext context) {
    final event = controller.clearanceEvent(eventId);
    if (event == null) {
      return const Scaffold(
          body: Center(child: Text('This event is no longer available.')));
    }
    final student = controller.selectedStudent;
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(event.title),
        actions: <Widget>[
          IconButton(
            tooltip: 'Switch color theme',
            onPressed: controller.toggleTheme,
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
        ],
      ),
      body: _PageScroll(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Hero(
              tag: 'event-${event.id}',
              child: Material(
                color: Colors.transparent,
                child: CcisPanel(
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: .11),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.event_available_outlined,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(event.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w900)),
                            const SizedBox(height: 3),
                            Text(event.schedule,
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      StatusPill.requirement(event.requirementStatus),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            IdentityCard(student: student, showProgram: false),
            const SizedBox(height: 12),
            CcisPanel(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF192C43)
                  : CcisTheme.paleBlue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          event.requiredDays == 1
                              ? 'Recorded checkpoints'
                              : 'Daily attendance',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      Text(
                        event.requiredDays == 1
                            ? '${event.recordedCheckpointCount}/4'
                            : '${event.completeOrExcusedDayCount}/${event.requiredDays} days',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      minHeight: 7,
                      value: event.requiredDays == 1
                          ? event.recordedCheckpointCount / 4
                          : event.completeOrExcusedDayCount /
                              event.requiredDays,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    event.allRequiredDaysComplete
                        ? 'All required event days are complete or excused.'
                        : 'Morning and afternoon attendance are required for every event day.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            SectionTitle(
                title: event.requiredDays == 1
                    ? 'Attendance details'
                    : 'Event days'),
            for (final day in event.days) ...<Widget>[
              AttendanceDayTile(
                day: day,
                onTap: () => Navigator.of(context).push(
                  _ccisRoute(
                    AttendanceDayPage(
                      controller: controller,
                      eventId: event.id,
                      dayId: day.id,
                      personnelView: personnelView,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 3),
            if (personnelView) ...<Widget>[
              if (controller.canVerifyEvent(event.id))
                FilledButton.icon(
                  onPressed: () {
                    controller.verifyEvent(event.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Event attendance has been verified.')),
                    );
                  },
                  icon: const Icon(Icons.verified_outlined),
                  label: const Text('Verify event requirement'),
                )
              else
                AlertPanel(
                  title: 'Verification not yet available',
                  message: event.requirementStatus.isSatisfied
                      ? 'This event requirement has already been verified.'
                      : 'All required event days must be Complete or Excused before verification.',
                  tone: StatusTone.info,
                ),
            ] else ...<Widget>[
              AlertPanel(
                title: event.requirementStatus.isSatisfied
                    ? 'Requirement verified'
                    : 'Verification pending',
                message: event.requirementStatus.isSatisfied
                    ? event.verificationNote
                    : 'Authorized CCIS personnel will verify this requirement after attendance is complete.',
                tone: event.requirementStatus.isSatisfied
                    ? StatusTone.success
                    : StatusTone.info,
                icon: event.requirementStatus.isSatisfied
                    ? Icons.check_circle_outline
                    : Icons.info_outline,
              ),
              const SizedBox(height: 10),
              _ViewOnlyHint(),
            ],
          ],
        ),
      ),
    );
  }
}

class AttendanceDayPage extends StatelessWidget {
  const AttendanceDayPage({
    super.key,
    required this.controller,
    required this.eventId,
    required this.dayId,
    required this.personnelView,
  });

  final ClearanceController controller;
  final String eventId;
  final String dayId;
  final bool personnelView;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: controller,
        builder: (context, _) => _buildPage(context),
      );

  Widget _buildPage(BuildContext context) {
    final event = controller.clearanceEvent(eventId);
    final day = controller.attendanceDay(eventId, dayId);
    if (event == null || day == null) {
      return const Scaffold(
          body: Center(child: Text('Attendance record not found.')));
    }
    return Scaffold(
      appBar: AppBar(title: Text('${event.title} · ${day.label}')),
      body: _PageScroll(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _PageIntro(
              eyebrow: '${event.title.toUpperCase()} ATTENDANCE',
              title: day.date,
              subtitle: 'CCIS event attendance details',
              trailing: StatusPill.attendance(day.status),
            ),
            const SizedBox(height: 16),
            CcisPanel(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF192C43)
                  : CcisTheme.paleBlue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Expanded(
                          child: Text('Recorded checkpoints',
                              style: TextStyle(fontWeight: FontWeight.w800))),
                      Text(day.checkpointSummary,
                          style: const TextStyle(fontWeight: FontWeight.w900)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                        value: day.recordedCheckpointCount / 4, minHeight: 7),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    day.excused
                        ? 'An authorized exception covers this attendance day.'
                        : 'Morning and afternoon Time In and Time Out are required.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            AttendanceCheckpointPanel(day: day),
            if (day.remarks.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              AlertPanel(
                title: 'Attendance note',
                message: day.remarks,
                tone: day.status == AttendanceStatus.partial
                    ? StatusTone.warning
                    : StatusTone.info,
              ),
            ],
            const SizedBox(height: 15),
            if (personnelView) ...<Widget>[
              FilledButton.icon(
                onPressed: () =>
                    _showAttendanceEditor(context, controller, event, day),
                icon: const Icon(Icons.edit_calendar_outlined),
                label: const Text('Record attendance'),
              ),
              const SizedBox(height: 9),
              OutlinedButton.icon(
                onPressed: () =>
                    _showExceptionDialog(context, controller, event, day),
                icon: Icon(day.excused
                    ? Icons.remove_circle_outline
                    : Icons.health_and_safety_outlined),
                label: Text(day.excused
                    ? 'Remove authorized exception'
                    : 'Record authorized exception'),
              ),
              const SizedBox(height: 12),
              AlertPanel(
                title: 'Authorized editing',
                message:
                    'Saving attendance updates the official status. It does not verify the event requirement yet.',
                tone: StatusTone.info,
              ),
            ] else ...<Widget>[
              _ViewOnlyHint(),
            ],
          ],
        ),
      ),
    );
  }
}

class DeficiencyManagerPage extends StatelessWidget {
  const DeficiencyManagerPage({super.key, required this.controller});

  final ClearanceController controller;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: controller,
        builder: (context, _) => _buildPage(context),
      );

  Widget _buildPage(BuildContext context) {
    final student = controller.selectedStudent;
    final deficiencies =
        student.requirements.where((item) => item.isDeficient).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Manage deficiencies')),
      body: _PageScroll(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const _PageIntro(
              eyebrow: 'Authorized CCIS personnel',
              title: 'Manage deficiencies',
              subtitle:
                  'Resolve supporting CCIS records before final clearance approval.',
            ),
            const SizedBox(height: 16),
            IdentityCard(student: student),
            const SizedBox(height: 14),
            if (deficiencies.isEmpty)
              const AlertPanel(
                title: 'No open deficiencies',
                message:
                    'This student has no unresolved CCIS record deficiencies.',
                tone: StatusTone.success,
                icon: Icons.check_circle_outline,
              )
            else
              for (final item in deficiencies) ...<Widget>[
                _RequirementTile(
                  requirement: item,
                  personnelView: true,
                  onTap: () => _resolveDeficiency(context, controller, item),
                ),
                const SizedBox(height: 10),
              ],
            const SizedBox(height: 4),
            AlertPanel(
              title: 'CCIS approval remains unavailable',
              message:
                  'All applicable event requirements must be verified and every deficiency must be resolved before final approval.',
              tone: StatusTone.warning,
            ),
          ],
        ),
      ),
    );
  }
}

class ReviewClearancePage extends StatelessWidget {
  const ReviewClearancePage({super.key, required this.controller});

  final ClearanceController controller;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: controller,
        builder: (context, _) => _buildPage(context),
      );

  Widget _buildPage(BuildContext context) {
    final student = controller.selectedStudent;
    final canApprove = controller.canApproveSelectedStudent();
    return Scaffold(
      appBar: AppBar(title: const Text('Review CCIS clearance')),
      body: _PageScroll(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const _PageIntro(
              eyebrow: 'Authorized CCIS personnel',
              title: 'Review CCIS clearance',
              subtitle: 'Confirm the final requirements before approval.',
            ),
            const SizedBox(height: 16),
            IdentityCard(student: student),
            const SizedBox(height: 15),
            CcisPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Applicable CCIS requirements',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  for (final event in student.events)
                    _ReviewRow(
                        title: event.title,
                        passed: event.requirementStatus.isSatisfied),
                  for (final item in student.requirements)
                    _ReviewRow(title: item.title, passed: item.isSatisfied),
                ],
              ),
            ),
            const SizedBox(height: 14),
            CcisPanel(
              color: canApprove || student.isApproved
                  ? _reviewSurface(context, true)
                  : _reviewSurface(context, false),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    student.isApproved
                        ? 'CCIS clearance approved'
                        : 'Approval prerequisites',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  _ReviewRow(
                      title: 'All event requirements verified',
                      passed: student.allEventsVerified),
                  _ReviewRow(
                      title: 'No unresolved CCIS deficiencies',
                      passed: student.openDeficiencyCount == 0),
                  _ReviewRow(
                      title: 'Other CCIS requirements verified',
                      passed: student.allOtherRequirementsVerified),
                  if (student.isApproved) ...<Widget>[
                    const SizedBox(height: 8),
                    Text(
                      'Approved by ${student.approvedBy}\n${student.approvedDateLabel}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 15),
            if (student.isApproved)
              const AlertPanel(
                title: 'Final approval is saved',
                message:
                    'The student has been notified of the approved CCIS clearance.',
                tone: StatusTone.success,
                icon: Icons.verified_outlined,
              )
            else ...<Widget>[
              FilledButton.icon(
                onPressed: canApprove
                    ? () {
                        controller.approveSelectedStudent();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'CCIS clearance approved and student notified.')),
                        );
                      }
                    : null,
                icon: const Icon(Icons.verified_user_outlined),
                label: const Text('Approve CCIS clearance'),
              ),
              if (!canApprove) ...<Widget>[
                const SizedBox(height: 10),
                const AlertPanel(
                  title: 'Final approval unavailable',
                  message:
                      'Complete event verification and resolve all CCIS deficiencies before approval.',
                  tone: StatusTone.warning,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _PageScroll extends StatelessWidget {
  const _PageScroll({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            constraints.maxWidth >= 768 ? 28 : 16,
            18,
            constraints.maxWidth >= 768 ? 28 : 16,
            32,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1160),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _PageIntro extends StatelessWidget {
  const _PageIntro({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                eyebrow.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .45,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.65,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...<Widget>[const SizedBox(width: 10), trailing!],
      ],
    );
  }
}

class _TermCard extends StatelessWidget {
  const _TermCard({required this.student});

  final StudentRecord student;

  @override
  Widget build(BuildContext context) {
    return CcisPanel(
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF182535)
          : const Color(0xFFF2F6FA),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: <Widget>[
          _InfoRow('Purpose', student.clearancePurpose),
          _InfoRow('Term', student.term, isLast: true),
        ],
      ),
    );
  }
}

class _RequirementTile extends StatelessWidget {
  const _RequirementTile({
    required this.requirement,
    this.personnelView = false,
    this.onTap,
  });

  final Requirement requirement;
  final bool personnelView;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tone = requirement.isDeficient
        ? StatusTone.warning
        : requirement.isSatisfied
            ? StatusTone.success
            : StatusTone.info;
    return CcisPanel(
      onTap: onTap,
      semanticLabel: '${requirement.title}, ${requirement.status.label}',
      color: requirement.isDeficient ? _reviewSurface(context, false) : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: _toneBackground(context, tone),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              requirement.hasAmount
                  ? Icons.receipt_long_outlined
                  : Icons.description_outlined,
              color: _toneForeground(context, tone),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(requirement.title,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                    ),
                    StatusPill.requirement(requirement.status),
                  ],
                ),
                const SizedBox(height: 3),
                Text(requirement.category,
                    style: Theme.of(context).textTheme.bodySmall),
                if (requirement.note.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 3),
                  Text(
                    requirement.note,
                    maxLines: personnelView ? 3 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
                if (requirement.hasAmount) ...<Widget>[
                  const SizedBox(height: 3),
                  Text('Amount: ₱${requirement.amount!.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                ],
              ],
            ),
          ),
          if (onTap != null) ...<Widget>[
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right)
          ],
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification, required this.onTap});

  final NotificationItem notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tone = switch (notification.kind) {
      NotificationKind.information => StatusTone.info,
      NotificationKind.warning => StatusTone.warning,
      NotificationKind.success => StatusTone.success,
      NotificationKind.alert => StatusTone.danger,
    };
    return CcisPanel(
      onTap: onTap,
      semanticLabel: notification.title,
      color: notification.isRead
          ? null
          : _toneBackground(context, StatusTone.info),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _toneBackground(context, tone),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(_notificationIcon(notification.kind),
                color: _toneForeground(context, tone), size: 20),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                        child: Text(notification.title,
                            style:
                                const TextStyle(fontWeight: FontWeight.w800))),
                    if (!notification.isRead)
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(notification.message,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(height: 1.35)),
                const SizedBox(height: 7),
                Text(
                  notification.timeLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
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

class _PersonnelStudentTile extends StatelessWidget {
  const _PersonnelStudentTile({required this.student, required this.onTap});

  final StudentRecord student;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pending =
        student.openDeficiencyCount > 0 || !student.allEventsVerified;
    return CcisPanel(
      onTap: onTap,
      semanticLabel: 'Open ${student.name} record',
      child: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundColor:
                Theme.of(context).colorScheme.primary.withValues(alpha: .12),
            child: Text(student.initials,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(student.name,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(student.identityLabel,
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                  student.isApproved
                      ? 'CCIS clearance approved'
                      : pending
                          ? '${student.openDeficiencyCount} deficiencies · ${student.verifiedClearanceItems}/${student.totalClearanceItems} verified'
                          : 'Ready for final CCIS review',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusPill(
            label: student.isApproved
                ? 'Approved'
                : pending
                    ? 'Needs review'
                    : 'Ready',
            tone: student.isApproved
                ? StatusTone.success
                : pending
                    ? StatusTone.warning
                    : StatusTone.info,
          ),
          const SizedBox(width: 3),
          const Icon(Icons.chevron_right, size: 20),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            switch (role) {
              UserRole.student => Icons.school_outlined,
              UserRole.personnel => Icons.verified_user_outlined,
              UserRole.admin => Icons.admin_panel_settings_outlined,
            },
            size: 17,
          ),
          const SizedBox(width: 6),
          Text(role.label, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value, {this.isLast = false});

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(value,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.title, required this.passed});

  final String title;
  final bool passed;

  @override
  Widget build(BuildContext context) {
    final color = passed ? CcisTheme.success : CcisTheme.warning;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: <Widget>[
          Icon(passed ? Icons.check_circle_outline : Icons.pending_outlined,
              color: color, size: 20),
          const SizedBox(width: 9),
          Expanded(
              child: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w700))),
          Text(passed ? 'Verified' : 'Pending',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w800, fontSize: 12)),
        ],
      ),
    );
  }
}

class _ViewOnlyHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(Icons.lock_outline,
            size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            'View only. Contact authorized CCIS personnel for attendance corrections.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState(
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
          const SizedBox(height: 3),
          Text(message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _EqualGrid extends StatelessWidget {
  const _EqualGrid({required this.columns, required this.children});

  final int columns;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    const spacing = 10.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            (constraints.maxWidth - (columns - 1) * spacing) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children
              .map((child) => SizedBox(width: width, height: 138, child: child))
              .toList(growable: false),
        );
      },
    );
  }
}

class _Destination {
  const _Destination(this.section, this.label, this.icon, this.selectedIcon);

  final AppSection section;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

Route<void> _ccisRoute(Widget page) {
  return PageRouteBuilder<void>(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 190),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (MediaQuery.of(context).disableAnimations) return child;
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position:
              Tween<Offset>(begin: const Offset(.035, 0), end: Offset.zero)
                  .animate(curved),
          child: child,
        ),
      );
    },
  );
}

void _showAttendanceEditor(
  BuildContext context,
  ClearanceController controller,
  ClearanceEvent event,
  AttendanceDay day,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) =>
        _AttendanceEditorSheet(controller: controller, event: event, day: day),
  );
}

void _showExceptionDialog(
  BuildContext context,
  ClearanceController controller,
  ClearanceEvent event,
  AttendanceDay day,
) {
  if (day.excused) {
    controller.setAttendanceExcused(
        eventId: event.id, dayId: day.id, excused: false);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authorized exception removed.')));
    return;
  }
  final note = TextEditingController();
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Record authorized exception'),
      content: TextField(
        controller: note,
        maxLines: 3,
        decoration: const InputDecoration(
            hintText: 'Reason or supporting-note reference'),
      ),
      actions: <Widget>[
        TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            controller.setAttendanceExcused(
              eventId: event.id,
              dayId: day.id,
              excused: true,
              note: note.text,
            );
            Navigator.of(dialogContext).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Authorized exception recorded.')),
            );
          },
          child: const Text('Save exception'),
        ),
      ],
    ),
  ).whenComplete(note.dispose);
}

void _resolveDeficiency(
  BuildContext context,
  ClearanceController controller,
  Requirement requirement,
) {
  final note = TextEditingController();
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('Resolve ${requirement.title}'),
      content: TextField(
        controller: note,
        maxLines: 3,
        decoration:
            const InputDecoration(hintText: 'Resolution note (optional)'),
      ),
      actions: <Widget>[
        TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            controller.resolveDeficiency(requirement.id, note: note.text);
            Navigator.of(dialogContext).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${requirement.title} resolved.')),
            );
          },
          child: const Text('Mark verified'),
        ),
      ],
    ),
  ).whenComplete(note.dispose);
}

class _AttendanceEditorSheet extends StatefulWidget {
  const _AttendanceEditorSheet({
    required this.controller,
    required this.event,
    required this.day,
  });

  final ClearanceController controller;
  final ClearanceEvent event;
  final AttendanceDay day;

  @override
  State<_AttendanceEditorSheet> createState() => _AttendanceEditorSheetState();
}

class _AttendanceEditorSheetState extends State<_AttendanceEditorSheet> {
  late final TextEditingController _morningIn;
  late final TextEditingController _morningOut;
  late final TextEditingController _afternoonIn;
  late final TextEditingController _afternoonOut;
  late final TextEditingController _remarks;

  @override
  void initState() {
    super.initState();
    _morningIn = TextEditingController(text: widget.day.morningTimeIn ?? '');
    _morningOut = TextEditingController(text: widget.day.morningTimeOut ?? '');
    _afternoonIn =
        TextEditingController(text: widget.day.afternoonTimeIn ?? '');
    _afternoonOut =
        TextEditingController(text: widget.day.afternoonTimeOut ?? '');
    _remarks = TextEditingController(text: widget.day.remarks);
  }

  @override
  void dispose() {
    _morningIn.dispose();
    _morningOut.dispose();
    _afternoonIn.dispose();
    _afternoonOut.dispose();
    _remarks.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final sheetColor = Theme.of(context).colorScheme.surface;
    return AnimatedPadding(
      duration: _motion(context, 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 680),
        decoration: BoxDecoration(
          color: sheetColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Record attendance',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 3),
              Text(
                  '${widget.event.title} · ${widget.day.label} · ${widget.day.date}',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 18),
              const Text('Morning attendance',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 9),
              Row(
                children: <Widget>[
                  Expanded(child: _timeField('Time In', _morningIn)),
                  const SizedBox(width: 10),
                  Expanded(child: _timeField('Time Out', _morningOut)),
                ],
              ),
              const SizedBox(height: 15),
              const Text('Afternoon attendance',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 9),
              Row(
                children: <Widget>[
                  Expanded(child: _timeField('Time In', _afternoonIn)),
                  const SizedBox(width: 10),
                  Expanded(child: _timeField('Time Out', _afternoonOut)),
                ],
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _remarks,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Record remarks'),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save record'),
              ),
              const SizedBox(height: 9),
              Center(
                child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel changes')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timeField(String label, TextEditingController textController) {
    return TextField(
      controller: textController,
      keyboardType: TextInputType.datetime,
      decoration: InputDecoration(labelText: label, hintText: '07:45 AM'),
    );
  }

  void _save() {
    widget.controller.saveAttendance(
      eventId: widget.event.id,
      dayId: widget.day.id,
      morningTimeIn: _morningIn.text,
      morningTimeOut: _morningOut.text,
      afternoonTimeIn: _afternoonIn.text,
      afternoonTimeOut: _afternoonOut.text,
      remarks: _remarks.text,
    );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attendance record saved.')),
    );
  }
}

IconData _notificationIcon(NotificationKind kind) => switch (kind) {
      NotificationKind.information => Icons.info_outline,
      NotificationKind.warning => Icons.error_outline,
      NotificationKind.success => Icons.check_circle_outline,
      NotificationKind.alert => Icons.priority_high_rounded,
    };

Color _toneBackground(BuildContext context, StatusTone tone) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  return switch (tone) {
    StatusTone.success =>
      dark ? const Color(0xFF153F32) : const Color(0xFFE4F5EB),
    StatusTone.warning =>
      dark ? const Color(0xFF493515) : const Color(0xFFFFF4D7),
    StatusTone.danger =>
      dark ? const Color(0xFF4A252B) : const Color(0xFFFFE9E8),
    StatusTone.info => dark ? const Color(0xFF1D3653) : CcisTheme.paleBlue,
    StatusTone.neutral =>
      dark ? const Color(0xFF263545) : const Color(0xFFEFF3F7),
  };
}

Color _toneForeground(BuildContext context, StatusTone tone) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  return switch (tone) {
    StatusTone.success => dark ? const Color(0xFF8FDDAD) : CcisTheme.success,
    StatusTone.warning => dark ? const Color(0xFFFFD27D) : CcisTheme.warning,
    StatusTone.danger => dark ? const Color(0xFFFFB4AB) : CcisTheme.danger,
    StatusTone.info => dark ? const Color(0xFF9FCBFF) : CcisTheme.blue,
    StatusTone.neutral =>
      dark ? const Color(0xFFC5D1DF) : const Color(0xFF52687D),
  };
}

Color _reviewSurface(BuildContext context, bool positive) => positive
    ? _toneBackground(context, StatusTone.success)
    : _toneBackground(context, StatusTone.warning);

Duration _motion(BuildContext context, int milliseconds) =>
    MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : Duration(milliseconds: milliseconds);
