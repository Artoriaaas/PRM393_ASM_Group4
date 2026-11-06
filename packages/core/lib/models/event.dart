class Event {
  const Event({
    required this.id,
    required this.title,
    required this.clubName,
    required this.location,
    required this.startsAt,
    required this.endsAt,
    this.deadline,
    this.description = '',
    this.coverKey = '',
    this.topic = '',
    this.audience = '',
    this.preparation = '',
    this.activities = const [],
    this.mode = 'required',
    this.status = 'published',
    this.capacity = 0,
    this.activeCount = 0,
    this.clubId = '',
    this.visibility = 'public',
    this.updatedAt,
  });
  final String coverKey;
  final String id,
      title,
      clubName,
      location,
      description,
      topic,
      audience,
      preparation,
      mode,
      status,
      clubId,
      visibility;
  final DateTime startsAt, endsAt;
  final DateTime? deadline;
  final List<String> activities;
  final int capacity, activeCount;
  final DateTime? updatedAt;
  bool get isFree => mode == 'free';
  int get available =>
      (capacity - activeCount).clamp(0, capacity < 0 ? 0 : capacity);
  String? unavailable(DateTime now) {
    if (status != 'published') return 'Sự kiện đã hủy';
    if (now.isAfter(startsAt) || now.isAtSameMomentAs(startsAt)) {
      return 'Sự kiện đã bắt đầu';
    }
    if (isFree) return null;
    if (deadline == null || !now.isBefore(deadline!)) {
      return 'Đã hết hạn đăng ký';
    }
    if (available == 0) return 'Sự kiện đã hết chỗ';
    return null;
  }
}

class Participant {
  const Participant({
    required this.name,
    required this.email,
    this.group = 'student',
    this.cohort = '',
    this.organization = '',
    this.phone = '',
  });
  final String name, email, group, cohort, organization, phone;
  Map<String, dynamic> toJson() => {
    'name': name.trim(),
    'email': email.trim(),
    'group': group,
    'cohort': group == 'student' ? cohort.trim() : '',
    'organization': group == 'guest' ? organization.trim() : '',
    'phone': phone.trim(),
  };
  factory Participant.fromJson(Map<String, dynamic> data) => Participant(
    name: data['name'] as String? ?? '',
    email: data['email'] as String? ?? '',
    group: data['group'] as String? ?? 'student',
    cohort: data['cohort'] as String? ?? '',
    organization: data['organization'] as String? ?? '',
    phone: data['phone'] as String? ?? '',
  );
  Map<String, String> validate() {
    final errors = <String, String>{};
    if (name.trim().isEmpty) errors['name'] = 'Vui lòng nhập họ tên.';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email.trim())) {
      errors['email'] = 'Vui lòng nhập email đúng định dạng.';
    }
    if (!['student', 'guest'].contains(group)) {
      errors['group'] = 'Chọn nhóm tham gia.';
    }
    if (group == 'student' && cohort.trim().isEmpty) {
      errors['cohort'] = 'Vui lòng nhập khóa K.';
    }
    if (name.trim().length > 100) errors['name'] = 'Họ tên tối đa 100 ký tự.';
    if (email.trim().length > 254) errors['email'] = 'Email quá dài.';
    if (group == 'student' && cohort.trim().length > 30) {
      errors['cohort'] = 'Khóa K tối đa 30 ký tự.';
    }
    if (organization.trim().length > 160) {
      errors['organization'] = 'Trường / tổ chức tối đa 160 ký tự.';
    }
    if (phone.trim().length > 30) {
      errors['phone'] = 'Số điện thoại tối đa 30 ký tự.';
    }
    return errors;
  }
}

class Registration {
  const Registration({
    required this.id,
    required this.eventId,
    required this.status,
    required this.generation,
    required this.participant,
    this.uid = '',
    this.clubId = '',
    this.checkInAt,
    this.createdAt,
    this.reason,
    this.reviewedBy,
    this.reviewedAt,
    this.qrHash,
    this.lastOperationId = '',
  });
  final String id, eventId, status;
  final int generation;
  final Participant participant;
  final String uid, clubId;
  final DateTime? checkInAt, createdAt;
  final String? reason, reviewedBy;
  final DateTime? reviewedAt;
  final String? qrHash;
  final String lastOperationId;
  bool get active =>
      status == 'pending' || status == 'approved' || status == 'active';
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get canCheckIn => status == 'approved' || status == 'active';
  bool get isRejected => status == 'rejected';
  bool get isCancelled => status == 'cancelled';
  bool get isCheckedIn => checkInAt != null;
}

class BookingResult {
  const BookingResult({required this.status, this.registrationId, this.code});
  final String status;
  final String? registrationId, code;
  bool get terminal => [
    'confirmed',
    'existing',
    'cancelled',
    'checked-in',
    'rejected',
  ].contains(status);
  bool get successful =>
      ['confirmed', 'existing', 'cancelled', 'checked-in'].contains(status);
  factory BookingResult.fromJson(Map<String, dynamic> d) => BookingResult(
    status: d['status'] as String? ?? 'unknown',
    registrationId: d['registrationId'] as String?,
    code: d['code'] as String?,
  );
}

String bookingMessage(String? code) => switch (code) {
  'event-full' => 'Sự kiện đã hết chỗ.',
  'registration-expired' => 'Đã hết hạn đăng ký.',
  'event-cancelled' => 'Sự kiện đã hủy.',
  'free-entry' => 'Sự kiện tham gia tự do, không cần đăng ký.',
  'registration-inactive' => 'Không có đăng ký đang hoạt động.',
  'stale-generation' => 'Đăng ký đã thay đổi. Hãy tải lại chi tiết.',
  'cannot-cancel' =>
    'Không thể hủy khi đã điểm danh, sự kiện đã bắt đầu hoặc đã hủy.',
  'invalid-participant' => 'Kiểm tra lại các trường thông tin tham gia.',
  'invalid-qr' => 'Mã QR không hợp lệ.',
  'wrong-event' => 'Mã QR không đúng sự kiện.',
  'session-closed' => 'Phiên điểm danh đang đóng.',
  'event-not-found' => 'Không tìm thấy sự kiện.',
  'not-approved' => 'Đơn đăng ký đang chờ CLB duyệt, chưa thể điểm danh.',
  'operation-conflict' =>
    'Nội dung thao tác đã thay đổi. Hãy kiểm tra kết quả cũ trước.',
  _ => 'Chưa thể hoàn tất thao tác. Hãy tải lại dữ liệu và thử lại.',
};
