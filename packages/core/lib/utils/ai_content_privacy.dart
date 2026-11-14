/// Conservative local screening for event drafting. No text is sent to a
/// separate classifier. This is not a universal named-entity recognizer.
abstract final class AiContentPrivacy {
  static final _contact = RegExp(
    r'[\w.+-]+@[\w.-]+\.[A-Za-z]{2,}|(?:\+?\d[\s().-]*){9,}|https?://|www\.|@[\w.]+',
    caseSensitive: false,
  );
  static final _identityLabel = RegExp(
    r'(họ\s*(và\s*)?tên|tên\s*(người|diễn\s*giả|khách\s*mời)|diễn\s*giả|khách\s*mời|liên\s*hệ|cccd|cmnd|mã\s*số\s*sinh\s*viên|mssv|địa\s*chỉ\s*(nhà|riêng)|speaker|full\s*name|contact|passport)\s*[:：-]?\s+[\p{L}\p{N}]+',
    unicode: true,
    caseSensitive: false,
  );
  static final _capitalName = RegExp(
    r'\p{Lu}\p{Ll}+(?:[ -]+\p{Lu}\p{Ll}+){1,4}',
    unicode: true,
  );
  // Generic event/technical phrases can be title-cased without identifying a person.
  static const _generic = {
    'trí',
    'tuệ',
    'nhân',
    'máy',
    'dữ',
    'liệu',
    'phân',
    'tích',
    'khoa',
    'kinh',
    'tế',
    'toán',
    'workshop',
    'flutter',
    'firebase',
    'google',
    'gemini',
    'android',
    'dart',
    'python',
    'javascript',
    'typescript',
    'react',
    'native',
    'microsoft',
    'excel',
    'power',
    'point',
    'thiết',
    'kế',
    'công',
    'nghệ',
    'âm',
    'nhạc',
    'thuật',
    'thể',
    'thao',
    'hoạt',
    'động',
    'tình',
    'nguyện',
    'môi',
    'trường',
    'hướng',
    'nghiệp',
    'việc',
    'làm',
    'người',
    'mới',
    'sinh',
    'viên',
    'giao',
    'lưu',
    'cầu',
    'lông',
    'đọc',
    'sách',
    'chụp',
    'ảnh',
    'điện',
    'thoại',
    'nhập',
    'môn',
    'thực',
    'hành',
    'trải',
    'nghiệm',
    'tư',
    'duy',
    'sáng',
    'tạo',
    'kỹ',
    'năng',
    'học',
    'tập',
    'trao',
    'đổi',
    'chia',
    'sẻ',
    'câu',
    'lạc',
    'bộ',
    'ngày',
    'hội',
    'buổi',
    'khóa',
    'fpt',
    'university',
    'campus',
    'user',
    'experience',
    'research',
    'prototype',
    'test',
  };
  static const _surnames = {
    'nguyễn',
    'nguyen',
    'trần',
    'tran',
    'lê',
    'le',
    'phạm',
    'pham',
    'hoàng',
    'hoang',
    'huỳnh',
    'huynh',
    'phan',
    'vũ',
    'vu',
    'võ',
    'vo',
    'đặng',
    'dang',
    'bùi',
    'bui',
    'đỗ',
    'do',
    'hồ',
    'ho',
    'ngô',
    'ngo',
    'dương',
    'duong',
    'lý',
    'ly',
  };
  static const _genericSurnamePhrases = {
    'vũ đạo',
    'vu dao',
    'võ thuật',
    'vo thuat',
    'lễ hội',
    'le hoi',
    'lý thuyết',
    'ly thuyet',
    'hỗ trợ',
    'ho tro',
    'hồ sơ',
    'ho so',
  };

  static bool containsPersonalData(String text) {
    if (_contact.hasMatch(text) || _identityLabel.hasMatch(text)) return true;
    for (final match in _capitalName.allMatches(text)) {
      final words = match.group(0)!.toLowerCase().split(RegExp(r'[ -]+'));
      if (words.where((w) => !_generic.contains(w)).length >= 2) return true;
    }
    // Also catch common Vietnamese full names entered entirely in lowercase.
    final words = text.toLowerCase().split(RegExp(r'[^\p{L}]+', unicode: true));
    for (var i = 0; i + 2 < words.length; i++) {
      if (!_surnames.contains(words[i])) continue;
      if (_genericSurnamePhrases.contains('${words[i]} ${words[i + 1]}'))
        continue;
      if (words[i + 1].length >= 2 &&
          words[i + 2].length >= 2 &&
          !_generic.contains(words[i + 1]) &&
          !_generic.contains(words[i + 2]))
        return true;
    }
    return false;
  }
}
