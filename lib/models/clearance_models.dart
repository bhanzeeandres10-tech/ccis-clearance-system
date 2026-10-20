/// Immutable model types used by the CCIS Clearance demo application.
///
/// The models deliberately avoid serialization and external dependencies so the
/// prototype remains easy to replace with an API-backed repository later.

/// Roles follow the revised CCIS CLEARANCE access flow. Admin access is kept
/// separate from personnel access so audit and account-management actions are
/// not mixed with student-record processing.
enum UserRole { admin, personnel, student }

extension UserRoleText on UserRole {
  String get label => switch (this) {
        UserRole.admin => 'Administrator',
        UserRole.student => 'Student',
        UserRole.personnel => 'CCIS personnel',
      };

  String get shortLabel => switch (this) {
        UserRole.admin => 'Admin',
        UserRole.personnel => 'Personnel',
        UserRole.student => 'Student',
      };
}

enum AccountStatus { active, inactive }

extension AccountStatusText on AccountStatus {
  String get label => switch (this) {
        AccountStatus.active => 'Active',
        AccountStatus.inactive => 'Inactive',
      };
}

enum AttendanceStatus { pending, partial, complete, excused }

extension AttendanceStatusText on AttendanceStatus {
  String get label => switch (this) {
        AttendanceStatus.pending => 'Pending',
        AttendanceStatus.partial => 'Partial',
        AttendanceStatus.complete => 'Complete',
        AttendanceStatus.excused => 'Excused',
      };
}

enum RequirementStatus { pending, inProgress, verified, deficient, approved }

extension RequirementStatusText on RequirementStatus {
  String get label => switch (this) {
        RequirementStatus.pending => 'Pending',
        RequirementStatus.inProgress => 'In progress',
        RequirementStatus.verified => 'Verified',
        RequirementStatus.deficient => 'Action required',
        RequirementStatus.approved => 'Approved',
      };

  bool get isSatisfied =>
      this == RequirementStatus.verified || this == RequirementStatus.approved;
}

enum NotificationKind { information, warning, success, alert }

/// An authorized CCIS personnel account managed by the administrator.
///
/// The app keeps this lightweight for the presentation prototype; a production
/// implementation would store credentials only in a dedicated auth provider.
class PersonnelAccount {
  const PersonnelAccount({
    required this.id,
    required this.firstName,
    required this.middleInitial,
    required this.lastName,
    required this.createdAtLabel,
    this.status = AccountStatus.active,
  });

  final String id;
  final String firstName;
  final String middleInitial;
  final String lastName;
  final String createdAtLabel;
  final AccountStatus status;

  String get displayName => middleInitial.isEmpty
      ? '$firstName $lastName'
      : '$firstName $middleInitial. $lastName';

  PersonnelAccount copyWith({
    String? firstName,
    String? middleInitial,
    String? lastName,
    String? createdAtLabel,
    AccountStatus? status,
  }) {
    return PersonnelAccount(
      id: id,
      firstName: firstName ?? this.firstName,
      middleInitial: middleInitial ?? this.middleInitial,
      lastName: lastName ?? this.lastName,
      createdAtLabel: createdAtLabel ?? this.createdAtLabel,
      status: status ?? this.status,
    );
  }
}

/// Auditable activity for administrator review: login, logout, create and
/// update operations all retain a timestamp and the user who initiated them.
class AuditEntry {
  const AuditEntry({
    required this.id,
    required this.action,
    required this.actor,
    required this.detail,
    required this.timestampLabel,
    required this.createdAt,
  });

  final String id;
  final String action;
  final String actor;
  final String detail;
  final String timestampLabel;
  final DateTime createdAt;
}

/// A single day of an attendance event.
///
/// A day becomes Complete only once all four checkpoints have values. An
/// authorized exception takes precedence and is shown as Excused.
class AttendanceDay {
  const AttendanceDay({
    required this.id,
    required this.label,
    required this.date,
    this.morningTimeIn,
    this.morningTimeOut,
    this.afternoonTimeIn,
    this.afternoonTimeOut,
    this.remarks = '',
    this.excused = false,
    this.excuseNote = '',
  });

  final String id;
  final String label;
  final String date;
  final String? morningTimeIn;
  final String? morningTimeOut;
  final String? afternoonTimeIn;
  final String? afternoonTimeOut;
  final String remarks;
  final bool excused;
  final String excuseNote;

  List<String?> get checkpoints => <String?>[
        morningTimeIn,
        morningTimeOut,
        afternoonTimeIn,
        afternoonTimeOut,
      ];

  int get recordedCheckpointCount => checkpoints
      .where((value) => value != null && value.trim().isNotEmpty)
      .length;

  AttendanceStatus get status {
    if (excused) return AttendanceStatus.excused;
    if (recordedCheckpointCount == 0) return AttendanceStatus.pending;
    if (recordedCheckpointCount == checkpoints.length) {
      return AttendanceStatus.complete;
    }
    return AttendanceStatus.partial;
  }

  bool get isCompleteOrExcused =>
      status == AttendanceStatus.complete || status == AttendanceStatus.excused;

  String get checkpointSummary => '$recordedCheckpointCount/4 recorded';

  AttendanceDay copyWith({
    String? label,
    String? date,
    String? morningTimeIn,
    String? morningTimeOut,
    String? afternoonTimeIn,
    String? afternoonTimeOut,
    String? remarks,
    bool? excused,
    String? excuseNote,
  }) {
    return AttendanceDay(
      id: id,
      label: label ?? this.label,
      date: date ?? this.date,
      // Passing an empty string intentionally clears a checkpoint. Omitting it
      // (null) preserves the existing value.
      morningTimeIn: morningTimeIn ?? this.morningTimeIn,
      morningTimeOut: morningTimeOut ?? this.morningTimeOut,
      afternoonTimeIn: afternoonTimeIn ?? this.afternoonTimeIn,
      afternoonTimeOut: afternoonTimeOut ?? this.afternoonTimeOut,
      remarks: remarks ?? this.remarks,
      excused: excused ?? this.excused,
      excuseNote: excuseNote ?? this.excuseNote,
    );
  }
}

/// An event requirement such as Abre Klase, Buwan ng Wika, or Hinampang.
class ClearanceEvent {
  const ClearanceEvent({
    required this.id,
    required this.title,
    required this.schedule,
    required this.requiredDays,
    required this.days,
    this.requirementStatus = RequirementStatus.pending,
    this.verificationNote = '',
  });

  final String id;
  final String title;
  final String schedule;
  final int requiredDays;
  final List<AttendanceDay> days;
  final RequirementStatus requirementStatus;
  final String verificationNote;

  int get completeOrExcusedDayCount =>
      days.where((day) => day.isCompleteOrExcused).length;

  int get recordedCheckpointCount =>
      days.fold<int>(0, (total, day) => total + day.recordedCheckpointCount);

  bool get allRequiredDaysComplete =>
      days.length >= requiredDays &&
      days.every((day) => day.isCompleteOrExcused);

  bool get isEligibleForVerification =>
      allRequiredDaysComplete && !requirementStatus.isSatisfied;

  String get attendanceSummary =>
      '$completeOrExcusedDayCount of $requiredDays days complete';

  ClearanceEvent copyWith({
    String? title,
    String? schedule,
    int? requiredDays,
    List<AttendanceDay>? days,
    RequirementStatus? requirementStatus,
    String? verificationNote,
  }) {
    return ClearanceEvent(
      id: id,
      title: title ?? this.title,
      schedule: schedule ?? this.schedule,
      requiredDays: requiredDays ?? this.requiredDays,
      days: days ?? this.days,
      requirementStatus: requirementStatus ?? this.requirementStatus,
      verificationNote: verificationNote ?? this.verificationNote,
    );
  }
}

/// A non-event CCIS clearance requirement or an open deficiency.
class Requirement {
  const Requirement({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    this.note = '',
    this.amount,
  });

  final String id;
  final String title;
  final String category;
  final RequirementStatus status;
  final String note;
  final double? amount;

  bool get hasAmount => amount != null && amount! > 0;
  bool get isDeficient => status == RequirementStatus.deficient;
  bool get isSatisfied => status.isSatisfied;

  Requirement copyWith({
    String? title,
    String? category,
    RequirementStatus? status,
    String? note,
    double? amount,
    bool clearAmount = false,
  }) {
    return Requirement(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      status: status ?? this.status,
      note: note ?? this.note,
      amount: clearAmount ? null : amount ?? this.amount,
    );
  }
}

/// The clearance view for one CCIS student.
class StudentRecord {
  const StudentRecord({
    required this.id,
    required this.name,
    required this.initials,
    required this.program,
    required this.yearLevel,
    required this.section,
    required this.clearance,
    required this.term,
    required this.events,
    required this.requirements,
    this.department = 'College of Computing and Information Sciences (CCIS)',
    this.isApproved = false,
    this.approvedBy,
    this.approvedDateLabel,
  });

  /// The student number used by personnel search and selection.
  final String id;
  final String name;
  final String initials;
  final String program;
  final String yearLevel;
  final String section;
  final String clearance;
  final String term;
  final String department;
  final List<ClearanceEvent> events;
  final List<Requirement> requirements;
  final bool isApproved;
  final String? approvedBy;
  final String? approvedDateLabel;

  String get clearancePurpose => clearance;
  String get academicLabel => '$yearLevel · $section';
  String get identityLabel => '$id · $program $section';

  int get verifiedEventCount =>
      events.where((event) => event.requirementStatus.isSatisfied).length;

  int get verifiedRequirementCount =>
      requirements.where((requirement) => requirement.isSatisfied).length;

  int get totalClearanceItems => events.length + requirements.length;

  int get verifiedClearanceItems =>
      verifiedEventCount + verifiedRequirementCount;

  double get clearanceProgress => totalClearanceItems == 0
      ? 0
      : verifiedClearanceItems / totalClearanceItems;

  int get openDeficiencyCount =>
      requirements.where((requirement) => requirement.isDeficient).length;

  bool get allEventsVerified =>
      events.every((event) => event.requirementStatus.isSatisfied);

  bool get allOtherRequirementsVerified =>
      requirements.every((requirement) => requirement.isSatisfied);

  bool get canApprove =>
      !isApproved && allEventsVerified && allOtherRequirementsVerified;

  ClearanceEvent? eventById(String eventId) {
    for (final event in events) {
      if (event.id == eventId) return event;
    }
    return null;
  }

  StudentRecord copyWith({
    String? name,
    String? initials,
    String? program,
    String? yearLevel,
    String? section,
    String? clearance,
    String? term,
    String? department,
    List<ClearanceEvent>? events,
    List<Requirement>? requirements,
    bool? isApproved,
    String? approvedBy,
    String? approvedDateLabel,
  }) {
    return StudentRecord(
      id: id,
      name: name ?? this.name,
      initials: initials ?? this.initials,
      program: program ?? this.program,
      yearLevel: yearLevel ?? this.yearLevel,
      section: section ?? this.section,
      clearance: clearance ?? this.clearance,
      term: term ?? this.term,
      department: department ?? this.department,
      events: events ?? this.events,
      requirements: requirements ?? this.requirements,
      isApproved: isApproved ?? this.isApproved,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedDateLabel: approvedDateLabel ?? this.approvedDateLabel,
    );
  }
}

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.timeLabel,
    this.kind = NotificationKind.information,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final String timeLabel;
  final NotificationKind kind;
  final bool isRead;

  NotificationItem copyWith({
    String? title,
    String? message,
    DateTime? createdAt,
    String? timeLabel,
    NotificationKind? kind,
    bool? isRead,
  }) {
    return NotificationItem(
      id: id,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      timeLabel: timeLabel ?? this.timeLabel,
      kind: kind ?? this.kind,
      isRead: isRead ?? this.isRead,
    );
  }
}
