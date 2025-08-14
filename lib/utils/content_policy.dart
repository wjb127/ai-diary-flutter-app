// AI 콘텐츠 정책 관리 유틸리티

class ContentPolicy {
  // 금지된 키워드 목록 (애플/구글 정책 준수)
  static final List<String> prohibitedKeywords = [
    // 폭력적인 내용
    '살인', '자살', '자해', '폭력', '테러',
    // 성적인 내용
    '성적', '음란', '포르노',
    // 차별적인 내용
    '인종차별', '혐오', '차별',
    // 불법 활동
    '마약', '도박', '불법',
    // 위험한 활동
    '위험한', '해로운',
  ];

  // 콘텐츠 필터링
  static bool isContentSafe(String content) {
    final lowerContent = content.toLowerCase();
    for (final keyword in prohibitedKeywords) {
      if (lowerContent.contains(keyword)) {
        return false;
      }
    }
    return true;
  }

  // AI 생성 콘텐츠 워터마크 추가
  static String addAIWatermark(String content) {
    return '''$content

━━━━━━━━━━━━━━━━━━━━
✨ AI가 각색한 일기입니다
원본 내용을 바탕으로 Claude AI가 문학적으로 재구성했습니다.''';
  }

  // 연령 제한 확인
  static bool isAgeAppropriate(int age) {
    return age >= 12; // 12세 이상 사용 권장
  }

  // 개인정보 필터링
  static String filterPersonalInfo(String content) {
    // 전화번호 패턴 마스킹
    content = content.replaceAllMapped(
      RegExp(r'\d{3}-\d{3,4}-\d{4}'),
      (match) => '***-****-****',
    );
    
    // 이메일 패턴 마스킹
    content = content.replaceAllMapped(
      RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'),
      (match) => '****@****.***',
    );
    
    // 주민번호 패턴 마스킹
    content = content.replaceAllMapped(
      RegExp(r'\d{6}-\d{7}'),
      (match) => '******-*******',
    );
    
    return content;
  }

  // 콘텐츠 경고 메시지
  static String getContentWarning() {
    return '''
⚠️ 중요 안내

이 앱은 AI 기술을 사용하여 일기를 각색합니다.
• AI가 생성한 콘텐츠는 창작물입니다
• 실제 사실과 다를 수 있습니다
• 12세 이상 사용을 권장합니다
• 개인정보는 자동으로 필터링됩니다
''';
  }

  // 앱스토어 설명용 AI 공시
  static String getAIDisclosure() {
    return '''
AI 기술 사용 공시:
본 앱은 Anthropic의 Claude AI를 사용하여 사용자가 작성한 일기를 문학적으로 각색합니다. 
모든 AI 생성 콘텐츠는 명확하게 표시되며, 원본 콘텐츠는 사용자가 직접 작성합니다.
유해 콘텐츠 필터링 시스템을 통해 안전한 콘텐츠만 생성됩니다.
''';
  }
}