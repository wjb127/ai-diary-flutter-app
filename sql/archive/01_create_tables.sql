-- AI Diary App Database Schema
-- 이 파일을 Supabase SQL Editor에서 실행하세요

-- diary_entries 테이블 생성
CREATE TABLE IF NOT EXISTS diary_entries (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  title TEXT NOT NULL,
  original_content TEXT NOT NULL,
  generated_content TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  UNIQUE(user_id, date)
);

-- 코멘트 추가
COMMENT ON TABLE diary_entries IS 'AI 일기장 데이터를 저장하는 테이블';
COMMENT ON COLUMN diary_entries.id IS '고유 식별자 (UUID)';
COMMENT ON COLUMN diary_entries.user_id IS '사용자 ID (auth.users 참조)';
COMMENT ON COLUMN diary_entries.date IS '일기 날짜 (하루에 하나의 일기만 작성 가능)';
COMMENT ON COLUMN diary_entries.title IS '일기 제목';
COMMENT ON COLUMN diary_entries.original_content IS '사용자가 작성한 원본 내용';
COMMENT ON COLUMN diary_entries.generated_content IS 'AI가 각색한 내용';
COMMENT ON COLUMN diary_entries.created_at IS '생성 시간';
COMMENT ON COLUMN diary_entries.updated_at IS '수정 시간 (자동 업데이트)';

-- 인덱스 생성 (성능 최적화)
CREATE INDEX IF NOT EXISTS idx_diary_entries_user_date 
  ON diary_entries(user_id, date DESC);

CREATE INDEX IF NOT EXISTS idx_diary_entries_created_at 
  ON diary_entries(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_diary_entries_user_created 
  ON diary_entries(user_id, created_at DESC);