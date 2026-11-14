import 'package:eventhub_core/eventhub_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('different activity lists remain different structured drafts', () {
    const first = AiEventSuggestion(
      topic: 'Thiết kế',
      description: 'Thực hành',
      audience: 'Sinh viên',
      preparation: 'Laptop',
      activities: ['Phác thảo'],
    );
    const second = AiEventSuggestion(
      topic: 'Thiết kế',
      description: 'Thực hành',
      audience: 'Sinh viên',
      preparation: 'Laptop',
      activities: ['Kiểm thử'],
    );
    expect(first, isNot(second));
    expect(first, AiEventSuggestion.fromJson(first.toJson()));
  });
  test('screens names and identifiers before AI transmission', () {
    for (final text in [
      'Workshop cùng Nguyễn Minh Anh',
      'giao lưu với nguyễn minh anh',
      'Workshop của John Smith',
      'Khách mời: linh',
      'Diễn giả: alex',
      'Họ tên: minh',
      'MSSV: SE123456',
      'CCCD: 012345678901',
      'Liên hệ: 0912345678',
      'Email test@example.com',
      'Trang cá nhân https://example.com',
      'Liên hệ @minhanh',
    ]) {
      expect(AiContentPrivacy.containsPersonalData(text), isTrue, reason: text);
    }
  });
  test('keeps general custom event ideas available', () {
    for (final text in [
      'Workshop Flutter và Firebase cho người mới',
      'Trí Tuệ Nhân Tạo và Khoa Học Dữ Liệu',
      'Workshop Thiết Kế Trải Nghiệm Người Dùng',
      'Hoạt động đổi sách nhằm khuyến khích đọc sách',
      'Giao lưu cầu lông cho người mới',
      'Workshop chụp ảnh bằng điện thoại',
      'Lý thuyết và thực hành vũ đạo',
      'Lễ hội âm nhạc',
    ]) {
      expect(
        AiContentPrivacy.containsPersonalData(text),
        isFalse,
        reason: text,
      );
    }
  });
  test(
    'structured output cannot recycle personal data into future prompts',
    () {
      final data = <String, dynamic>{
        'topic': 'Thiết kế',
        'description': 'Thực hành theo nhóm.',
        'audience': 'Sinh viên',
        'preparation': 'Laptop',
        'activities': ['Phác thảo'],
      };
      for (final key in [
        'topic',
        'description',
        'audience',
        'preparation',
        'activities',
      ]) {
        expect(
          () => AiEventSuggestion.fromJson({
            ...data,
            key: key == 'activities' ? ['Nguyễn Minh Anh'] : 'Nguyễn Minh Anh',
          }),
          throwsFormatException,
        );
      }
    },
  );
}
