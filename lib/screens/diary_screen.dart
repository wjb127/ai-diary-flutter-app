import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../services/diary_service.dart';
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
  final Map<String, String> _styleOptions = {
    'emotional': '🌸 감성적 문체',
    'epic': '⚔️ 대서사시 문체',
    'poetic': '📜 시적 문체',
    'humorous': '😄 유머러스한 문체',
    'philosophical': '🤔 철학적 문체',
    'minimalist': '⬜ 미니멀리스트',
    'detective': '🔍 탐정 소설 스타일',
    'fairytale': '🧚 동화 스타일',
    'scifi': '🚀 SF 소설 스타일',
    'historical': '📚 역사 기록 스타일',
  };

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI 일기장',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                  padding: const EdgeInsets.all(16.0),
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
                                        DateFormat('yyyy년 MM월 dd일').format(_selectedDay),
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
                        const SizedBox(height: 16),
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
                      const Text(
                        '오늘의 일기 ✍️',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // 제목 입력
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: '일기 제목',
                          hintText: '오늘의 제목을 입력해주세요',
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
                      
                      const SizedBox(height: 16),
                      
                      // 내용 입력
                      TextField(
                        controller: _contentController,
                        maxLines: 8,
                        decoration: InputDecoration(
                          labelText: '오늘 있었던 일',
                          hintText: '오늘 하루는 어떠셨나요? 자유롭게 적어보세요!\n완벽하지 않아도 괜찮아요 😊',
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
                      
                      const SizedBox(height: 20),
                      
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
                            items: _styleOptions.entries.map<DropdownMenuItem<String>>((entry) {
                              return DropdownMenuItem<String>(
                                value: entry.key,
                                child: Text(entry.value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
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
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'AI가 일기를 각색하고 있어요...',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.auto_awesome, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'AI로 일기 각색하기',
                                      style: TextStyle(
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
                        const Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: Color(0xFF6366F1),
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'AI가 각색한 일기',
                              style: TextStyle(
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
                            child: const Text(
                              '일기 저장하기',
                              style: TextStyle(
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
          _titleController.clear();
          _contentController.clear();
          _generatedDiary = null;
        }
      });
    } catch (e) {
      // 로그인되지 않은 상태일 수 있으므로 조용히 처리
      setState(() {
        _existingDiary = null;
        _titleController.clear();
        _contentController.clear();
        _generatedDiary = null;
      });
    }
  }

  Future<void> _generateDiary() async {
    if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('제목과 내용을 모두 입력해주세요!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final generatedContent = await _diaryService.generateDiaryWithAI(
        title: _titleController.text.trim(),
        originalContent: _contentController.text.trim(),
        style: _selectedStyle,
      );

      setState(() {
        _generatedDiary = generatedContent;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('AI 일기 생성 실패: $e'),
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
        const SnackBar(
          content: Text('일기가 성공적으로 저장되었습니다! 🎉'),
          backgroundColor: Color(0xFF10B981),
        ),
      );

      // 저장 후 해당 날짜 일기 다시 로드
      await _loadDiaryForDate(_selectedDay);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('일기 저장 실패: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}