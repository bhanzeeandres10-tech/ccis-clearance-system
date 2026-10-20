import 'package:flutter/material.dart';

import '../models/clearance_models.dart';

/// In-memory state for the interactive CCIS Clearance prototype.
///
/// It models the flow from the supplied chart: personnel record four
/// checkpoints, complete/excuse every required day, verify the event, resolve
/// other CCIS requirements, then approve the clearance. Replacing the demo
/// lists with repositories later will not require screens to own this logic.
class ClearanceController extends ChangeNotifier {
  ClearanceController() : this.demo();

  ClearanceController.demo()
      : _students = _demoStudents(),
        _notifications = _demoNotifications(),
        _personnel = _demoPersonnel(),
        _auditLog = _demoAuditLog();

  final List<StudentRecord> _students;
  final List<NotificationItem> _notifications;
  final List<PersonnelAccount> _personnel;
  final List<AuditEntry> _auditLog;

  UserRole _role = UserRole.student;
  bool _isSignedIn = false;
  ThemeMode _themeMode = ThemeMode.system;
  String _selectedStudentId = '2023-01428';
  String? _lastSignInError;

  UserRole get role => _role;
  bool get isSignedIn => _isSignedIn;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  String? get lastSignInError => _lastSignInError;
  bool get isAdministrator => _isSignedIn && _role == UserRole.admin;
  bool get isPersonnel => _isSignedIn && _role == UserRole.personnel;
  bool get isStudent => _isSignedIn && _role == UserRole.student;

  List<StudentRecord> get students =>
      List<StudentRecord>.unmodifiable(_students);
  List<NotificationItem> get notifications =>
      List<NotificationItem>.unmodifiable(_notifications);
  List<PersonnelAccount> get personnel =>
      List<PersonnelAccount>.unmodifiable(_personnel);
  List<AuditEntry> get auditLog => List<AuditEntry>.unmodifiable(_auditLog);
  int get activePersonnelCount => _personnel
      .where((person) => person.status == AccountStatus.active)
      .length;
  int get inactivePersonnelCount => _personnel
      .where((person) => person.status == AccountStatus.inactive)
      .length;

  List<StudentRecord> searchStudents(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return students;
    return students
        .where(
          (student) =>
              student.name.toLowerCase().contains(normalized) ||
              student.id.toLowerCase().contains(normalized) ||
              student.program.toLowerCase().contains(normalized),
        )
        .toList(growable: false);
  }

  int get unreadNotifications =>
      _notifications.where((notification) => !notification.isRead).length;

  StudentRecord get selectedStudent =>
      _students.firstWhere((student) => student.id == _selectedStudentId);

  int get pendingAttendanceCount => _students
      .expand((student) => student.events)
      .expand((event) => event.days)
      .where((day) =>
          day.status == AttendanceStatus.pending ||
          day.status == AttendanceStatus.partial)
      .length;

  int get openDeficiencyCount => _students.fold<int>(
        0,
        (total, student) => total + student.openDeficiencyCount,
      );

  int get approvedClearanceCount =>
      _students.where((student) => student.isApproved).length;

  /// The prototype accepts any nonempty credentials, but exposes an error state
  /// so the login UI can represent the invalid-credential branch of the flow.
  bool signIn({
    required UserRole role,
    required String username,
    required String password,
  }) {
    if (username.trim().isEmpty || password.trim().isEmpty) {
      _lastSignInError = 'Enter both your username and password.';
      notifyListeners();
      return false;
    }

    _role = role;
    _isSignedIn = true;
    _lastSignInError = null;
    if (role == UserRole.student) {
      _selectedStudentId = '2023-01428';
    }
    _addAudit(
      action: 'Login',
      actor: role.label,
      detail: '$username signed in to the CCIS CLEARANCE demo.',
    );
    notifyListeners();
    return true;
  }

  void signOut() {
    if (_isSignedIn) {
      _addAudit(
        action: 'Logout',
        actor: _role.label,
        detail: 'Session ended from the CCIS CLEARANCE demo.',
      );
    }
    _isSignedIn = false;
    _lastSignInError = null;
    notifyListeners();
  }

  void setThemeMode(ThemeMode value) {
    if (_themeMode == value) return;
    _themeMode = value;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void selectStudent(String studentId) {
    if (!_students.any((student) => student.id == studentId)) return;
    if (_selectedStudentId == studentId) return;
    _selectedStudentId = studentId;
    notifyListeners();
  }

  /// Admin-only creation of an authorized CCIS personnel record.
  bool createPersonnel({
    required String firstName,
    required String middleInitial,
    required String lastName,
  }) {
    if (!_isAdmin || firstName.trim().isEmpty || lastName.trim().isEmpty) {
      return false;
    }
    final account = PersonnelAccount(
      id: 'ccis-${DateTime.now().microsecondsSinceEpoch}',
      firstName: firstName.trim(),
      middleInitial: middleInitial.trim(),
      lastName: lastName.trim(),
      createdAtLabel: 'Just now',
    );
    _personnel.insert(0, account);
    _addAudit(
      action: 'Create personnel',
      actor: 'Administrator',
      detail: '${account.displayName} was added as authorized CCIS personnel.',
    );
    notifyListeners();
    return true;
  }

  /// Admin-only activation control for an existing authorized person.
  bool setPersonnelStatus(String accountId, AccountStatus status) {
    if (!_isAdmin) return false;
    final index = _personnel.indexWhere((person) => person.id == accountId);
    if (index < 0 || _personnel[index].status == status) return false;
    final account = _personnel[index].copyWith(status: status);
    _personnel[index] = account;
    _addAudit(
      action: 'Update personnel',
      actor: 'Administrator',
      detail: '${account.displayName} is now ${status.label.toLowerCase()}.',
    );
    notifyListeners();
    return true;
  }

  void markNotificationRead(String notificationId) {
    final index =
        _notifications.indexWhere((item) => item.id == notificationId);
    if (index < 0 || _notifications[index].isRead) return;
    _notifications[index] = _notifications[index].copyWith(isRead: true);
    notifyListeners();
  }

  void markAllNotificationsRead() {
    var changed = false;
    for (var index = 0; index < _notifications.length; index++) {
      if (!_notifications[index].isRead) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  AttendanceDay? attendanceDay(String eventId, String dayId) {
    final event = selectedStudent.eventById(eventId);
    if (event == null) return null;
    for (final day in event.days) {
      if (day.id == dayId) return day;
    }
    return null;
  }

  ClearanceEvent? clearanceEvent(String eventId) =>
      selectedStudent.eventById(eventId);

  /// Saves all four checkpoints for the selected student's event day.
  ///
  /// The calculated [AttendanceDay.status] drives whether the result is
  /// Pending, Partial, or Complete; it is never stored separately.
  bool saveAttendance({
    required String eventId,
    required String dayId,
    required String morningTimeIn,
    required String morningTimeOut,
    required String afternoonTimeIn,
    required String afternoonTimeOut,
    String remarks = '',
  }) {
    if (!_canPersonnelEdit) return false;

    final student = selectedStudent;
    final event = student.eventById(eventId);
    if (event == null) return false;
    final dayIndex = event.days.indexWhere((day) => day.id == dayId);
    if (dayIndex < 0) return false;

    final savedDay = event.days[dayIndex].copyWith(
      morningTimeIn: morningTimeIn.trim(),
      morningTimeOut: morningTimeOut.trim(),
      afternoonTimeIn: afternoonTimeIn.trim(),
      afternoonTimeOut: afternoonTimeOut.trim(),
      remarks: remarks.trim(),
      excused: false,
      excuseNote: '',
    );
    final updatedDays = List<AttendanceDay>.from(event.days)
      ..[dayIndex] = savedDay;
    var updatedEvent = event.copyWith(days: updatedDays);
    if (!updatedEvent.allRequiredDaysComplete &&
        updatedEvent.requirementStatus.isSatisfied) {
      updatedEvent = updatedEvent.copyWith(
        requirementStatus: RequirementStatus.inProgress,
        verificationNote: '',
      );
    }
    _replaceSelectedEvent(updatedEvent);

    _addNotification(
      title: '${event.title} · ${savedDay.label} updated',
      message:
          'Attendance is ${savedDay.status.label.toLowerCase()}: ${savedDay.checkpointSummary}.',
      kind: savedDay.status == AttendanceStatus.complete
          ? NotificationKind.success
          : NotificationKind.warning,
    );
    _addAudit(
      action: 'Update attendance',
      actor: 'CCIS personnel',
      detail: '${student.name}: ${event.title} ${savedDay.label} was updated.',
    );
    notifyListeners();
    return true;
  }

  /// Marks or restores an authorized exception for a single attendance day.
  bool setAttendanceExcused({
    required String eventId,
    required String dayId,
    required bool excused,
    String note = '',
  }) {
    if (!_canPersonnelEdit) return false;
    final student = selectedStudent;
    final event = student.eventById(eventId);
    if (event == null) return false;
    final dayIndex = event.days.indexWhere((day) => day.id == dayId);
    if (dayIndex < 0) return false;

    final updatedDay = event.days[dayIndex].copyWith(
      excused: excused,
      excuseNote: excused ? note.trim() : '',
    );
    final updatedDays = List<AttendanceDay>.from(event.days)
      ..[dayIndex] = updatedDay;
    var updatedEvent = event.copyWith(days: updatedDays);
    if (!updatedEvent.allRequiredDaysComplete &&
        updatedEvent.requirementStatus.isSatisfied) {
      updatedEvent = updatedEvent.copyWith(
        requirementStatus: RequirementStatus.inProgress,
        verificationNote: '',
      );
    }
    _replaceSelectedEvent(updatedEvent);

    _addNotification(
      title: '${event.title} · ${updatedDay.label}',
      message: excused
          ? 'An authorized attendance exception was recorded.'
          : 'The authorized attendance exception was removed.',
      kind: excused ? NotificationKind.information : NotificationKind.warning,
    );
    _addAudit(
      action: 'Update attendance exception',
      actor: 'CCIS personnel',
      detail:
          '${student.name}: ${event.title} ${updatedDay.label} exception was updated.',
    );
    notifyListeners();
    return true;
  }

  bool canVerifyEvent(String eventId) {
    if (!_canPersonnelEdit) return false;
    final event = selectedStudent.eventById(eventId);
    return event?.isEligibleForVerification ?? false;
  }

  /// Verifies an event only after every required day is Complete or Excused.
  bool verifyEvent(String eventId, {String note = ''}) {
    if (!canVerifyEvent(eventId)) return false;
    final student = selectedStudent;
    final event = selectedStudent.eventById(eventId)!;
    _replaceSelectedEvent(
      event.copyWith(
        requirementStatus: RequirementStatus.verified,
        verificationNote: note.trim().isEmpty
            ? 'Attendance requirement verified by authorized CCIS personnel.'
            : note.trim(),
      ),
    );
    _addNotification(
      title: '${event.title} requirement verified',
      message:
          'All required attendance days are complete or have an authorized exception.',
      kind: NotificationKind.success,
    );
    _addAudit(
      action: 'Verify requirement',
      actor: 'CCIS personnel',
      detail: '${student.name}: ${event.title} was verified.',
    );
    notifyListeners();
    return true;
  }

  /// Resolves a non-event CCIS deficiency, allowing the overall approval guard
  /// to advance when all remaining requirements are also verified.
  bool resolveDeficiency(String requirementId, {String note = ''}) {
    if (!_canPersonnelEdit) return false;
    final student = selectedStudent;
    final index = student.requirements.indexWhere(
      (requirement) => requirement.id == requirementId,
    );
    if (index < 0) return false;
    final requirement = student.requirements[index];
    if (!requirement.isDeficient) return false;

    final updatedRequirements = List<Requirement>.from(student.requirements)
      ..[index] = requirement.copyWith(
        status: RequirementStatus.verified,
        note: note.trim().isEmpty
            ? 'Resolved and verified by authorized CCIS personnel.'
            : note.trim(),
      );
    _replaceSelectedStudent(
        student.copyWith(requirements: updatedRequirements));
    _addNotification(
      title: '${requirement.title} resolved',
      message: 'Your CCIS clearance item is now verified.',
      kind: NotificationKind.success,
    );
    _addAudit(
      action: 'Resolve deficiency',
      actor: 'CCIS personnel',
      detail: '${student.name}: ${requirement.title} was resolved.',
    );
    notifyListeners();
    return true;
  }

  bool canApproveSelectedStudent() =>
      _canPersonnelEdit && selectedStudent.canApprove;

  /// The final approval guard intentionally requires all event requirements and
  /// other CCIS requirements to be verified before an approval can be saved.
  bool approveSelectedStudent() {
    if (!canApproveSelectedStudent()) return false;
    final student = selectedStudent;
    _replaceSelectedStudent(
      student.copyWith(
        isApproved: true,
        approvedBy: 'Nina R. Dela Cruz · CCIS',
        approvedDateLabel: '18 September 2026 · 10:20 AM',
      ),
    );
    _addNotification(
      title: 'CCIS clearance approved',
      message:
          'Your CCIS clearance has been approved by authorized CCIS personnel.',
      kind: NotificationKind.success,
    );
    _addAudit(
      action: 'Approve clearance',
      actor: 'CCIS personnel',
      detail: '${student.name}: CCIS clearance was approved.',
    );
    notifyListeners();
    return true;
  }

  /// Personnel manage a student's requirement state and, when applicable, its
  /// departmental fine amount. This is intentionally guarded from students
  /// and administrators to match the supplied access flow.
  bool updateRequirement({
    required String requirementId,
    required RequirementStatus status,
    String note = '',
    double? amount,
  }) {
    if (!_canPersonnelEdit) return false;
    final student = selectedStudent;
    final index =
        student.requirements.indexWhere((item) => item.id == requirementId);
    if (index < 0) return false;
    final previous = student.requirements[index];
    final updated = previous.copyWith(
      status: status,
      note: note.trim().isEmpty ? previous.note : note.trim(),
      amount: amount,
    );
    final requirements = List<Requirement>.from(student.requirements)
      ..[index] = updated;
    _replaceSelectedStudent(student.copyWith(requirements: requirements));
    _addNotification(
      title: '${updated.title} updated',
      message:
          'Your CCIS requirement is now ${updated.status.label.toLowerCase()}.',
      kind: updated.status.isSatisfied
          ? NotificationKind.success
          : NotificationKind.information,
    );
    _addAudit(
      action: 'Update requirement',
      actor: 'CCIS personnel',
      detail:
          '${student.name}: ${updated.title} is ${updated.status.label.toLowerCase()}.',
    );
    notifyListeners();
    return true;
  }

  /// Adds a new requirement or fine to the selected student's CCIS record.
  bool addRequirement({
    required String title,
    required String category,
    String note = '',
    double? amount,
  }) {
    if (!_canPersonnelEdit || title.trim().isEmpty || category.trim().isEmpty) {
      return false;
    }
    final student = selectedStudent;
    final requirement = Requirement(
      id: 'requirement-${DateTime.now().microsecondsSinceEpoch}',
      title: title.trim(),
      category: category.trim(),
      status: RequirementStatus.pending,
      note: note.trim(),
      amount: amount,
    );
    _replaceSelectedStudent(
      student.copyWith(
          requirements: <Requirement>[...student.requirements, requirement]),
    );
    _addNotification(
      title: 'New CCIS requirement',
      message: '${requirement.title} has been added to your clearance record.',
      kind: NotificationKind.information,
    );
    _addAudit(
      action: 'Create requirement',
      actor: 'CCIS personnel',
      detail: '${student.name}: ${requirement.title} was added.',
    );
    notifyListeners();
    return true;
  }

  bool get _canPersonnelEdit =>
      _isSignedIn && _role == UserRole.personnel && !selectedStudent.isApproved;

  bool get _isAdmin => _isSignedIn && _role == UserRole.admin;

  void _replaceSelectedEvent(ClearanceEvent updatedEvent) {
    final student = selectedStudent;
    final eventIndex =
        student.events.indexWhere((event) => event.id == updatedEvent.id);
    if (eventIndex < 0) return;
    final events = List<ClearanceEvent>.from(student.events)
      ..[eventIndex] = updatedEvent;
    _replaceSelectedStudent(student.copyWith(events: events));
  }

  void _replaceSelectedStudent(StudentRecord updatedStudent) {
    final studentIndex =
        _students.indexWhere((student) => student.id == updatedStudent.id);
    if (studentIndex >= 0) _students[studentIndex] = updatedStudent;
  }

  void _addNotification({
    required String title,
    required String message,
    required NotificationKind kind,
  }) {
    _notifications.insert(
      0,
      NotificationItem(
        id: 'notice-${DateTime.now().microsecondsSinceEpoch}',
        title: title,
        message: message,
        createdAt: DateTime.now(),
        timeLabel: 'Just now',
        kind: kind,
      ),
    );
  }

  void _addAudit({
    required String action,
    required String actor,
    required String detail,
  }) {
    _auditLog.insert(
      0,
      AuditEntry(
        id: 'audit-${DateTime.now().microsecondsSinceEpoch}',
        action: action,
        actor: actor,
        detail: detail,
        timestampLabel: 'Just now',
        createdAt: DateTime.now(),
      ),
    );
  }

  static List<StudentRecord> _demoStudents() => <StudentRecord>[
        StudentRecord(
          id: '2023-01428',
          name: 'Mariel A. Santos',
          initials: 'MS',
          program: 'BSIT',
          yearLevel: '3rd year',
          section: '3A',
          clearance: 'End-of-semester CCIS clearance',
          term: '1st semester · AY 2026–27',
          events: <ClearanceEvent>[
            ClearanceEvent(
              id: 'abre-klase',
              title: 'Abre Klase',
              schedule: '03 August 2026 · Single-day event',
              requiredDays: 1,
              requirementStatus: RequirementStatus.verified,
              verificationNote: 'Verified by Nina R. Dela Cruz · CCIS.',
              days: const <AttendanceDay>[
                AttendanceDay(
                  id: 'abre-day-1',
                  label: 'Event day',
                  date: '03 August 2026',
                  morningTimeIn: '07:42 AM',
                  morningTimeOut: '11:58 AM',
                  afternoonTimeIn: '12:53 PM',
                  afternoonTimeOut: '04:36 PM',
                  remarks: 'Attendance complete.',
                ),
              ],
            ),
            ClearanceEvent(
              id: 'buwan-ng-wika',
              title: 'Buwan ng Wika',
              schedule: '28 August 2026 · Single-day event',
              requiredDays: 1,
              requirementStatus: RequirementStatus.verified,
              verificationNote: 'Verified by Nina R. Dela Cruz · CCIS.',
              days: const <AttendanceDay>[
                AttendanceDay(
                  id: 'buwan-day-1',
                  label: 'Event day',
                  date: '28 August 2026',
                  morningTimeIn: '07:48 AM',
                  morningTimeOut: '12:02 PM',
                  afternoonTimeIn: '12:51 PM',
                  afternoonTimeOut: '04:42 PM',
                  remarks: 'Attendance complete.',
                ),
              ],
            ),
            ClearanceEvent(
              id: 'hinampang',
              title: 'Hinampang',
              schedule: '14–17 September 2026 · Four-day event',
              requiredDays: 4,
              requirementStatus: RequirementStatus.inProgress,
              days: const <AttendanceDay>[
                AttendanceDay(
                  id: 'hinampang-day-1',
                  label: 'Day 1',
                  date: '14 September 2026',
                  morningTimeIn: '07:39 AM',
                  morningTimeOut: '12:01 PM',
                  afternoonTimeIn: '12:49 PM',
                  afternoonTimeOut: '04:48 PM',
                  remarks: 'Attendance complete.',
                ),
                AttendanceDay(
                  id: 'hinampang-day-2',
                  label: 'Day 2',
                  date: '15 September 2026',
                  morningTimeIn: '07:46 AM',
                  morningTimeOut: '11:57 AM',
                  afternoonTimeIn: '12:54 PM',
                  afternoonTimeOut: '',
                  remarks: 'Afternoon time out is still missing.',
                ),
                AttendanceDay(
                  id: 'hinampang-day-3',
                  label: 'Day 3',
                  date: '16 September 2026',
                  excused: true,
                  excuseNote: 'Medical absence; supporting note reviewed.',
                  remarks: 'Authorized exception recorded.',
                ),
                AttendanceDay(
                  id: 'hinampang-day-4',
                  label: 'Day 4',
                  date: '17 September 2026',
                  remarks: 'Attendance is pending.',
                ),
              ],
            ),
          ],
          requirements: const <Requirement>[
            Requirement(
              id: 'ccis-information-sheet',
              title: 'CCIS information sheet',
              category: 'Document record',
              status: RequirementStatus.deficient,
              note: 'Sample document record still needs review.',
            ),
            Requirement(
              id: 'departmental-fine',
              title: 'Sample departmental fine',
              category: 'CCIS deficiency',
              status: RequirementStatus.deficient,
              amount: 120,
              note: 'Confirm the amount and supporting record with CCIS.',
            ),
          ],
        ),
        StudentRecord(
          id: '2022-00816',
          name: 'Adrian M. Reyes',
          initials: 'AR',
          program: 'BSCS',
          yearLevel: '4th year',
          section: '4A',
          clearance: 'End-of-semester CCIS clearance',
          term: '1st semester · AY 2026–27',
          events: <ClearanceEvent>[
            ClearanceEvent(
              id: 'adre-abre',
              title: 'Abre Klase',
              schedule: '03 August 2026 · Single-day event',
              requiredDays: 1,
              requirementStatus: RequirementStatus.verified,
              days: const <AttendanceDay>[
                AttendanceDay(
                  id: 'adre-abre-day',
                  label: 'Event day',
                  date: '03 August 2026',
                  morningTimeIn: '07:40 AM',
                  morningTimeOut: '12:00 PM',
                  afternoonTimeIn: '01:00 PM',
                  afternoonTimeOut: '04:30 PM',
                ),
              ],
            ),
            ClearanceEvent(
              id: 'adre-buwan',
              title: 'Buwan ng Wika',
              schedule: '28 August 2026 · Single-day event',
              requiredDays: 1,
              requirementStatus: RequirementStatus.verified,
              days: const <AttendanceDay>[
                AttendanceDay(
                  id: 'adre-buwan-day',
                  label: 'Event day',
                  date: '28 August 2026',
                  morningTimeIn: '07:42 AM',
                  morningTimeOut: '12:01 PM',
                  afternoonTimeIn: '12:56 PM',
                  afternoonTimeOut: '04:39 PM',
                ),
              ],
            ),
            ClearanceEvent(
              id: 'adre-hinampang',
              title: 'Hinampang',
              schedule: '14–17 September 2026 · Four-day event',
              requiredDays: 4,
              requirementStatus: RequirementStatus.verified,
              days: const <AttendanceDay>[
                AttendanceDay(
                  id: 'adre-h1',
                  label: 'Day 1',
                  date: '14 September 2026',
                  morningTimeIn: '07:42 AM',
                  morningTimeOut: '12:01 PM',
                  afternoonTimeIn: '12:58 PM',
                  afternoonTimeOut: '04:42 PM',
                ),
                AttendanceDay(
                  id: 'adre-h2',
                  label: 'Day 2',
                  date: '15 September 2026',
                  morningTimeIn: '07:40 AM',
                  morningTimeOut: '12:02 PM',
                  afternoonTimeIn: '12:59 PM',
                  afternoonTimeOut: '04:41 PM',
                ),
                AttendanceDay(
                  id: 'adre-h3',
                  label: 'Day 3',
                  date: '16 September 2026',
                  morningTimeIn: '07:43 AM',
                  morningTimeOut: '12:00 PM',
                  afternoonTimeIn: '12:57 PM',
                  afternoonTimeOut: '04:40 PM',
                ),
                AttendanceDay(
                  id: 'adre-h4',
                  label: 'Day 4',
                  date: '17 September 2026',
                  morningTimeIn: '07:45 AM',
                  morningTimeOut: '12:01 PM',
                  afternoonTimeIn: '12:56 PM',
                  afternoonTimeOut: '04:38 PM',
                ),
              ],
            ),
          ],
          requirements: const <Requirement>[
            Requirement(
              id: 'adre-info-sheet',
              title: 'CCIS information sheet',
              category: 'Document record',
              status: RequirementStatus.verified,
              note: 'Verified by CCIS.',
            ),
          ],
        ),
        StudentRecord(
          id: '2023-01107',
          name: 'Leah P. Mendoza',
          initials: 'LM',
          program: 'BSIT',
          yearLevel: '3rd year',
          section: '3B',
          clearance: 'End-of-semester CCIS clearance',
          term: '1st semester · AY 2026–27',
          isApproved: true,
          approvedBy: 'Nina R. Dela Cruz · CCIS',
          approvedDateLabel: '16 September 2026 · 01:12 PM',
          events: <ClearanceEvent>[
            ClearanceEvent(
              id: 'leah-abre',
              title: 'Abre Klase',
              schedule: '03 August 2026 · Single-day event',
              requiredDays: 1,
              requirementStatus: RequirementStatus.verified,
              days: const <AttendanceDay>[
                AttendanceDay(
                  id: 'leah-abre-day',
                  label: 'Event day',
                  date: '03 August 2026',
                  morningTimeIn: '07:38 AM',
                  morningTimeOut: '12:02 PM',
                  afternoonTimeIn: '12:55 PM',
                  afternoonTimeOut: '04:40 PM',
                ),
              ],
            ),
          ],
          requirements: const <Requirement>[
            Requirement(
              id: 'leah-info-sheet',
              title: 'CCIS information sheet',
              category: 'Document record',
              status: RequirementStatus.verified,
              note: 'Verified by CCIS.',
            ),
          ],
        ),
      ];

  static List<PersonnelAccount> _demoPersonnel() => <PersonnelAccount>[
        const PersonnelAccount(
          id: 'ccis-nina',
          firstName: 'Nina',
          middleInitial: 'R',
          lastName: 'Dela Cruz',
          createdAtLabel: '12 June 2026',
        ),
        const PersonnelAccount(
          id: 'ccis-jose',
          firstName: 'Jose',
          middleInitial: 'M',
          lastName: 'Ramos',
          createdAtLabel: '03 July 2026',
        ),
        const PersonnelAccount(
          id: 'ccis-ana',
          firstName: 'Ana',
          middleInitial: 'L',
          lastName: 'Reyes',
          createdAtLabel: '16 August 2026',
          status: AccountStatus.inactive,
        ),
      ];

  static List<AuditEntry> _demoAuditLog() => <AuditEntry>[
        AuditEntry(
          id: 'audit-1',
          action: 'Update attendance',
          actor: 'CCIS personnel',
          detail: 'Mariel A. Santos: Hinampang Day 2 was updated.',
          timestampLabel: '18 Sep 2026 · 08:35 AM',
          createdAt: DateTime(2026, 9, 18, 8, 35),
        ),
        AuditEntry(
          id: 'audit-2',
          action: 'Create personnel',
          actor: 'Administrator',
          detail: 'Jose M. Ramos was added as authorized CCIS personnel.',
          timestampLabel: '03 Jul 2026 · 09:10 AM',
          createdAt: DateTime(2026, 7, 3, 9, 10),
        ),
        AuditEntry(
          id: 'audit-3',
          action: 'Login',
          actor: 'CCIS personnel',
          detail: 'Authorized personnel session opened.',
          timestampLabel: '18 Sep 2026 · 08:00 AM',
          createdAt: DateTime(2026, 9, 18, 8),
        ),
      ];

  static List<NotificationItem> _demoNotifications() => <NotificationItem>[
        NotificationItem(
          id: 'notice-day-2',
          title: 'Day 2 checkout is missing',
          message:
              'Hinampang afternoon Time Out has no record. Contact CCIS for review.',
          createdAt: DateTime(2026, 9, 18, 8, 35),
          timeLabel: '18 Sep 2026 · 08:35 AM',
          kind: NotificationKind.warning,
        ),
        NotificationItem(
          id: 'notice-deficiencies',
          title: '2 deficiencies need attention',
          message:
              'Review your CCIS information sheet and sample departmental fine record.',
          createdAt: DateTime(2026, 9, 18, 8, 20),
          timeLabel: '18 Sep 2026 · 08:20 AM',
          kind: NotificationKind.alert,
        ),
        NotificationItem(
          id: 'notice-exception',
          title: 'Day 3 exception approved',
          message:
              'All Hinampang Day 3 checkpoints are excused. Approved by Nina R. Dela Cruz.',
          createdAt: DateTime(2026, 9, 16, 10, 20),
          timeLabel: '16 Sep 2026 · 10:20 AM',
          kind: NotificationKind.success,
          isRead: true,
        ),
        NotificationItem(
          id: 'notice-buwan',
          title: 'Buwan ng Wika requirement verified',
          message:
              'All four checkpoints are recorded and the event requirement is verified.',
          createdAt: DateTime(2026, 8, 28, 9, 10),
          timeLabel: '28 Aug 2026 · 09:10 AM',
          kind: NotificationKind.success,
          isRead: true,
        ),
      ];
}
