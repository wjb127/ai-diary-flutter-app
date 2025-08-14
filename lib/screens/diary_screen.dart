import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/diary_service.dart';
import '../services/localization_service.dart';
import '../models/diary_model.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final DiaryService _diaryService = DiaryService();
  bool _isLoading = false;
  String? _generatedDiary;
  DiaryEntry? _existingDiary;
  bool _showCalendar = false; // 달력 표시 여부
  
  // 문체 선택 관련
  String _selectedStyle = 'emotional'; // 기본값: 감성적
  
  Map<String, String> _getStyleOptions(AppLocalizations localizations) {
    return {
      'emotional': localizations.emotionalStyle,
      'epic': localizations.epicStyle,
      'poetic': localizations.poeticStyle,
      'humorous': localizations.humorousStyle,
      'philosophical': localizations.philosophicalStyle,
      'minimalist': localizations.minimalistStyle,
      'detective': localizations.detectiveStyle,
      'fairytale': localizations.fairytaleStyle,
      'scifi': localizations.scifiStyle,
      'historical': localizations.historicalStyle,
    };
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        final localizations = AppLocalizations(localizationService.currentLanguage);
        final styleOptions = _getStyleOptions(localizations);
        
        return Scaffold(
          appBar: AppBar(
            title: Text(
              localizations.navDiary,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              // 언어 전환 버튼 추가
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => localizationService.toggleLanguage(),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            localizationService.isKorean ? '🇰🇷' : '🇺🇸',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            localizationService.isKorean ? 'KOR' : 'ENG',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // 날짜 선택 섹션
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0), // 16->12로 축소
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 날짜 선택 헤더
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 왼쪽 화살표
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedDay = _selectedDay.subtract(const Duration(days: 1));
                                _focusedDay = _selectedDay;
                              });
                              _loadDiaryForDate(_selectedDay);
                            },
                            icon: const Icon(Icons.chevron_left),
                            color: const Color(0xFF6366F1),
                            iconSize: 32,
                          ),
                          
                          // 중앙 날짜 표시 (클릭 시 달력 표시)
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showCalendar = !_showCalendar;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6366F1).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF6366F1).withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 18,
                                      color: Color(0xFF6366F1),
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        localizations.formatSelectedDate(_selectedDay),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF6366F1),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      _showCalendar ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                      size: 18,
                                      color: const Color(0xFF6366F1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          // 오른쪽 화살표
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedDay = _selectedDay.add(const Duration(days: 1));
                                _focusedDay = _selectedDay;
                              });
                              _loadDiaryForDate(_selectedDay);
                            },
                            icon: const Icon(Icons.chevron_right),
                            color: const Color(0xFF6366F1),
                            iconSize: 32,
                          ),
                        ],
                      ),
                      
                      // 달력 (조건부 표시)
                      if (_showCalendar) ...[
                        const SizedBox(height: 8), // 16->8로 축소
                        TableCalendar<String>(
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: _focusedDay,
                          calendarFormat: CalendarFormat.month,
                          startingDayOfWeek: StartingDayOfWeek.monday,
                          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                              _showCalendar = false; // 날짜 선택 후 달력 닫기
                            });
                            _loadDiaryForDate(selectedDay);
                          },
                          calendarStyle: const CalendarStyle(
                            outsideDaysVisible: false,
                            selectedDecoration: BoxDecoration(
                              color: Color(0xFF6366F1),
                              shape: BoxShape.circle,
                          ),
                          todayDecoration: BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                            markerDecoration: BoxDecoration(
                              color: Color(0xFFF59E0B),
                              shape: BoxShape.circle,
                            ),
                          ),
                          headerStyle: const HeaderStyle(
                            titleCentered: true,
                            formatButtonVisible: false,
                            titleTextStyle: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // 일기 작성 섹션
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.diaryTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8), // 16->8로 축소
                      
                      // 제목 입력
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: localizations.titleLabel,
                          hintText: localizations.titleHint,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                        ),
                      ),
                      
                      const SizedBox(height: 8), // 16->8로 축소
                      
                      // 내용 입력
                      TextField(
                        controller: _contentController,
                        maxLines: 5, // 8->5로 축소 (화면 공간 절약)
                        decoration: InputDecoration(
                          labelText: localizations.contentLabel,
                          hintText: localizations.contentHint,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          alignLabelWithHint: true,
                        ),
                      ),
                      
                      const SizedBox(height: 12), // 20->12로 축소
                      
                      // 문체 선택 드롭다운
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedStyle,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6366F1)),
                            style: const TextStyle(color: Color(0xFF1E293B), fontSize: 16),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedStyle = newValue;
                                });
                              }
                            },
                            items: styleOptions.entries.map<DropdownMenuItem<String>>((entry) {
                              return DropdownMenuItem<String>(
                                value: entry.key,
                                child: Text(entry.value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 6), // 12->6으로 축소
                      
                      // AI 각색 버튼
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _generateDiary,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      localizations.aiEnhancing,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.auto_awesome, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text(
                                      localizations.enhanceWithAI,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // AI 각색된 일기 결과
              if (_generatedDiary != null) ...[
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              color: Color(0xFF6366F1),
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              localizations.aiEnhancedTitle,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            _generatedDiary!,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // 복사 및 공유 버튼들
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _copyToClipboard(_generatedDiary!),
                                icon: const Icon(Icons.copy, size: 18),
                                label: Text(localizations.isKorean ? '복사' : 'Copy'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  side: const BorderSide(color: Color(0xFF6366F1)),
                                  foregroundColor: const Color(0xFF6366F1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _shareAIDiary(),
                                icon: const Icon(Icons.share, size: 18),
                                label: Text(localizations.isKorean ? '공유' : 'Share'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  side: const BorderSide(color: Color(0xFF8B5CF6)),
                                  foregroundColor: const Color(0xFF8B5CF6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // 저장 버튼
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveDiary,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              localizations.saveDiary,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // 앱 진입 시 오늘 날짜 일기 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDiaryForDate(_selectedDay);
    });
  }

  Future<void> _loadDiaryForDate(DateTime date) async {
    try {
      final diary = await _diaryService.getDiaryByDate(date);
      setState(() {
        _existingDiary = diary;
        if (diary != null) {
          _titleController.text = diary.title;
          _contentController.text = diary.originalContent;
          _generatedDiary = diary.generatedContent;
        } else {
          // 새로운 일기의 경우 날짜 + diary 형태로 기본 제목 설정
          final formattedDate = DateFormat('yyyy.MM.dd').format(date);
          _titleController.text = '$formattedDate diary';
          _contentController.clear();
          _generatedDiary = null;
        }
      });
    } catch (e) {
      // 로그인되지 않은 상태일 수 있으므로 조용히 처리
      setState(() {
        _existingDiary = null;
        // 오류 상황에서도 기본 제목 설정
        final formattedDate = DateFormat('yyyy.MM.dd').format(date);
        _titleController.text = '$formattedDate diary';
        _contentController.clear();
        _generatedDiary = null;
      });
    }
  }

  Future<void> _generateDiary() async {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    final localizations = AppLocalizations(localizationService.currentLanguage);
    
    if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.fillAllFields),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 사용자가 입력한 언어를 감지하여 AI 프롬프트 언어 결정
      final isKoreanInput = _isKoreanText(_titleController.text + ' ' + _contentController.text);
      final aiLanguage = isKoreanInput ? 'ko' : 'en';
      
      final generatedContent = await _diaryService.generateDiaryWithAI(
        title: _titleController.text.trim(),
        originalContent: _contentController.text.trim(),
        style: _selectedStyle,
        language: aiLanguage,
      );

      setState(() {
        _generatedDiary = generatedContent;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${localizations.diaryGenerationFailed}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveDiary() async {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    final localizations = AppLocalizations(localizationService.currentLanguage);
    
    try {
      if (_existingDiary != null && _generatedDiary != null) {
        // 기존 일기 업데이트
        await _diaryService.updateDiaryWithGenerated(
          diaryId: _existingDiary!.id,
          generatedContent: _generatedDiary!,
        );
      } else if (_generatedDiary != null) {
        // 새 일기 생성
        final newDiary = await _diaryService.createDiary(
          date: _selectedDay,
          title: _titleController.text.trim(),
          originalContent: _contentController.text.trim(),
        );
        
        // AI 각색 내용으로 업데이트
        await _diaryService.updateDiaryWithGenerated(
          diaryId: newDiary.id,
          generatedContent: _generatedDiary!,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.diarySaved),
          backgroundColor: const Color(0xFF10B981),
        ),
      );

      // 저장 후 해당 날짜 일기 다시 로드
      await _loadDiaryForDate(_selectedDay);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${localizations.diarySaveFailed}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 클립보드에 복사하는 함수
  Future<void> _copyToClipboard(String content) async {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    
    try {
      await Clipboard.setData(ClipboardData(text: content));
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizationService.isKorean 
                ? '✅ 클립보드에 복사되었습니다' 
                : '✅ Copied to clipboard'
          ),
          backgroundColor: const Color(0xFF10B981),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizationService.isKorean 
                ? '❌ 복사에 실패했습니다' 
                : '❌ Failed to copy'
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // AI 일기를 공유하는 함수
  Future<void> _shareAIDiary() async {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    
    if (_generatedDiary == null) return;

    try {
      final title = _titleController.text.isNotEmpty 
          ? _titleController.text 
          : (localizationService.isKorean ? '내 AI 일기' : 'My AI Diary');
          
      final dateStr = DateFormat('yyyy년 MM월 dd일').format(_selectedDay);
      
      final shareText = localizationService.isKorean
          ? '''📝 $title ($dateStr)

$_generatedDiary

✨ AI 일기장으로 작성된 일기입니다'''
          : '''📝 $title ($dateStr)

$_generatedDiary

✨ Created with AI Diary App''';

      await Share.share(
        shareText,
        subject: title,
      );

      // 공유 완료 메시지
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              localizationService.isKorean 
                  ? '✅ 공유 준비 완료' 
                  : '✅ Ready to share'
            ),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizationService.isKorean 
                ? '❌ 공유에 실패했습니다' 
                : '❌ Failed to share'
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
  
  // 한국어 텍스트인지 감지하는 함수
  bool _isKoreanText(String text) {
    final koreanRegex = RegExp(r'[가-힣]');
    final koreanMatches = koreanRegex.allMatches(text).length;
    final totalChars = text.replaceAll(RegExp(r'\s+'), '').length;
    
    // 텍스트의 30% 이상이 한국어면 한국어로 판단
    return totalChars > 0 && (koreanMatches / totalChars) > 0.3;
  }
}