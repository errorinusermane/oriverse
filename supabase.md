# Oriverse - Supabase Database 설계

## 데이터베이스 스키마 정의

### 1. users (사용자)
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- 기본 정보
  email TEXT UNIQUE NOT NULL,
  username TEXT UNIQUE,
  
  -- 언어 설정
  native_language_id UUID REFERENCES languages(id) NOT NULL,
  learning_language_id UUID REFERENCES languages(id) NOT NULL,
  
  -- 프로필
  avatar_url TEXT,
  bio TEXT,
  
  -- 학습 진행상황
  current_lesson_id UUID REFERENCES lessons(id),
  lessons_completed INTEGER DEFAULT 0,
  total_points INTEGER DEFAULT 0,
  streak_days INTEGER DEFAULT 0,
  last_active_date DATE DEFAULT CURRENT_DATE,
  
  -- 구독 및 결제
  subscription_tier TEXT DEFAULT 'free' CHECK (subscription_tier IN ('free', 'premium')),
  subscription_expires_at TIMESTAMP WITH TIME ZONE,
  stripe_customer_id TEXT UNIQUE,
  
  -- 소통 제한 (무료 사용자)
  daily_voice_broadcasts_count INTEGER DEFAULT 0,
  daily_broadcasts_reset_at DATE DEFAULT CURRENT_DATE,
  conversation_count_with_users JSONB DEFAULT '{}', -- {user_id: count}
  
  -- 권한
  is_premium BOOLEAN DEFAULT FALSE,
  is_banned BOOLEAN DEFAULT FALSE
);

-- 인덱스
CREATE INDEX idx_users_native_lang ON users(native_language_id);
CREATE INDEX idx_users_learning_lang ON users(learning_language_id);
CREATE INDEX idx_users_subscription ON users(subscription_tier, subscription_expires_at);
```

### 2. languages (지원 언어)
```sql
CREATE TABLE languages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- 언어 정보
  code TEXT UNIQUE NOT NULL, -- 'en', 'es', 'de', 'fr', 'zh', 'ja', 'ko'
  name_en TEXT NOT NULL, -- 'English', 'Spanish', 'German'
  name_native TEXT NOT NULL, -- '영어', 'Español', 'Deutsch'
  
  -- 지도 시각화
  country_name TEXT NOT NULL,
  flag_emoji TEXT,
  map_coordinates JSONB, -- {lat: float, lng: float}
  
  -- 기타
  is_active BOOLEAN DEFAULT TRUE,
  display_order INTEGER DEFAULT 0
);

-- 기본 언어 데이터 삽입
INSERT INTO languages (code, name_en, name_native, country_name, flag_emoji) VALUES
  ('en', 'English', 'English', 'United States', '🇺🇸'),
  ('es', 'Spanish', 'Español', 'Spain', '🇪🇸'),
  ('de', 'German', 'Deutsch', 'Germany', '🇩🇪'),
  ('fr', 'French', 'Français', 'France', '🇫🇷'),
  ('zh', 'Chinese', '中文', 'China', '🇨🇳'),
  ('ja', 'Japanese', '日本語', 'Japan', '🇯🇵'),
  ('ko', 'Korean', '한국어', 'South Korea', '🇰🇷');
```

### 3. lessons (학습 스텝)
```sql
CREATE TABLE lessons (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- 학습 정보
  step_number INTEGER NOT NULL, -- 1-7 (1-6 기본, 7은 50동사)
  title_key TEXT NOT NULL, -- i18n 키
  description_key TEXT NOT NULL,
  
  -- 컨텐츠
  category TEXT NOT NULL, -- 'grammar', 'cafe', 'restaurant', 'market', 'hobby', 'reactions', 'verbs50'
  
  -- 접근 제어
  is_free BOOLEAN DEFAULT TRUE, -- 1-6 무료, 7은 유료 (처음 3개만 무료)
  free_preview_count INTEGER DEFAULT 0, -- 50동사는 3개만 무료
  
  -- 순서
  display_order INTEGER NOT NULL,
  required_previous_lesson_id UUID REFERENCES lessons(id),
  
  -- 포인트
  points_reward INTEGER DEFAULT 10,
  
  UNIQUE(step_number, category)
);

CREATE INDEX idx_lessons_step ON lessons(step_number);
CREATE INDEX idx_lessons_free ON lessons(is_free);
```

### 4. lesson_scripts (학습 스크립트)
```sql
CREATE TABLE lesson_scripts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  lesson_id UUID REFERENCES lessons(id) ON DELETE CASCADE NOT NULL,
  language_id UUID REFERENCES languages(id) NOT NULL,
  
  -- 대화 스크립트
  script_order INTEGER NOT NULL, -- 스크립트 내 순서
  speaker TEXT NOT NULL, -- 'user' or 'ai'
  
  -- 텍스트 및 오디오
  text_content TEXT NOT NULL,
  audio_url TEXT, -- TTS 생성 오디오
  
  -- 학습 포인트
  grammar_points JSONB, -- ['past_tense', 'question_form']
  vocabulary JSONB, -- ['coffee', 'order', 'please']
  
  UNIQUE(lesson_id, language_id, script_order)
);

CREATE INDEX idx_scripts_lesson ON lesson_scripts(lesson_id);
CREATE INDEX idx_scripts_language ON lesson_scripts(language_id);
```

### 5. user_lesson_progress (사용자 학습 진행도)
```sql
CREATE TABLE user_lesson_progress (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  lesson_id UUID REFERENCES lessons(id) ON DELETE CASCADE NOT NULL,
  
  -- 진행 상태
  status TEXT DEFAULT 'not_started' CHECK (status IN ('not_started', 'in_progress', 'completed')),
  progress_percentage INTEGER DEFAULT 0 CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
  
  -- 스크립트별 완료 상태
  completed_scripts JSONB DEFAULT '[]', -- [script_id, script_id, ...]
  
  -- 성과
  score INTEGER, -- 0-100
  attempts INTEGER DEFAULT 0,
  completed_at TIMESTAMP WITH TIME ZONE,
  
  UNIQUE(user_id, lesson_id)
);

CREATE INDEX idx_progress_user ON user_lesson_progress(user_id);
CREATE INDEX idx_progress_status ON user_lesson_progress(status);
```

### 6. voice_messages (보이스 메일)
```sql
CREATE TABLE voice_messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- 발신자
  sender_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  
  -- 음성 파일
  audio_file_url TEXT NOT NULL, -- Supabase Storage
  duration_seconds INTEGER NOT NULL,
  file_size_bytes INTEGER,
  
  -- AI 처리
  transcribed_text TEXT, -- Whisper/GPT-4o-mini-transcribe
  detected_language_code TEXT,
  ai_feedback JSONB, -- {suggestions: [], corrections: [], score: 0-100}
  
  -- 사용자 수정본
  edited_audio_url TEXT, -- AI 피드백 반영 후 재녹음
  is_edited BOOLEAN DEFAULT FALSE,
  
  -- 퍼뜨리기 상태
  broadcast_status TEXT DEFAULT 'draft' CHECK (broadcast_status IN ('draft', 'broadcasted')),
  broadcasted_at TIMESTAMP WITH TIME ZONE,
  
  -- 메타
  language_id UUID REFERENCES languages(id) NOT NULL,
  is_deleted BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_voice_messages_sender ON voice_messages(sender_id);
CREATE INDEX idx_voice_messages_broadcast ON voice_messages(broadcast_status);
CREATE INDEX idx_voice_messages_language ON voice_messages(language_id);
```

### 7. conversations (1:1 대화)
```sql
CREATE TABLE conversations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- 참여자
  participant_1_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  participant_2_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  
  -- 언어
  language_id UUID REFERENCES languages(id) NOT NULL,
  
  -- 메시지 카운트
  message_count INTEGER DEFAULT 0,
  
  -- 최근 활동
  last_message_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- 결제 제한
  is_paywall_reached BOOLEAN DEFAULT FALSE, -- 10번 초과 시 true
  
  -- 상태
  is_active BOOLEAN DEFAULT TRUE,
  
  CHECK (participant_1_id < participant_2_id), -- 중복 방지
  UNIQUE(participant_1_id, participant_2_id, language_id)
);

CREATE INDEX idx_conversations_p1 ON conversations(participant_1_id);
CREATE INDEX idx_conversations_p2 ON conversations(participant_2_id);
CREATE INDEX idx_conversations_last_message ON conversations(last_message_at DESC);
```

### 8. conversation_messages (대화 메시지)
```sql
CREATE TABLE conversation_messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE NOT NULL,
  voice_message_id UUID REFERENCES voice_messages(id) NOT NULL,
  sender_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  
  -- 읽음 상태
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMP WITH TIME ZONE,
  
  -- 순서
  message_order INTEGER NOT NULL
);

CREATE INDEX idx_conv_messages_conv ON conversation_messages(conversation_id, message_order);
CREATE INDEX idx_conv_messages_sender ON conversation_messages(sender_id);
CREATE INDEX idx_conv_messages_unread ON conversation_messages(is_read) WHERE is_read = FALSE;
```

### 9. payments (결제 내역)
```sql
CREATE TABLE payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  
  -- Stripe 정보
  stripe_payment_id TEXT UNIQUE NOT NULL,
  stripe_invoice_id TEXT,
  
  -- 결제 정보
  amount_cents INTEGER NOT NULL,
  currency TEXT DEFAULT 'USD',
  
  -- 구매 항목
  product_type TEXT NOT NULL CHECK (product_type IN ('subscription_monthly', 'subscription_yearly', 'verbs50', 'conversation_pack', 'broadcast_pack')),
  product_details JSONB, -- {conversations: 5, broadcasts: unlimited}
  
  -- 상태
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
  
  -- 구독 기간
  subscription_start_date TIMESTAMP WITH TIME ZONE,
  subscription_end_date TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_payments_user ON payments(user_id);
CREATE INDEX idx_payments_stripe ON payments(stripe_payment_id);
CREATE INDEX idx_payments_status ON payments(status);
```

### 10. user_achievements (업적/뱃지)
```sql
CREATE TABLE user_achievements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  
  achievement_type TEXT NOT NULL, -- 'streak_7', 'lessons_complete', 'first_conversation'
  achievement_name_key TEXT NOT NULL, -- i18n 키
  
  unlocked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  UNIQUE(user_id, achievement_type)
);

CREATE INDEX idx_achievements_user ON user_achievements(user_id);
```

---

## Row Level Security (RLS) 정책

### users 테이블
```sql
-- 자신의 정보만 읽기/수정
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
  ON users FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  USING (auth.uid() = id);
```

### voice_messages 테이블
```sql
ALTER TABLE voice_messages ENABLE ROW LEVEL SECURITY;

-- 자신이 보낸 메시지만 읽기/수정
CREATE POLICY "Users can view own messages"
  ON voice_messages FOR SELECT
  USING (auth.uid() = sender_id);

CREATE POLICY "Users can create messages"
  ON voice_messages FOR INSERT
  WITH CHECK (auth.uid() = sender_id);

-- 퍼뜨린 메시지는 모든 사용자가 볼 수 있음
CREATE POLICY "Users can view broadcasted messages"
  ON voice_messages FOR SELECT
  USING (broadcast_status = 'broadcasted');
```

### conversations 테이블
```sql
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;

-- 대화 참여자만 볼 수 있음
CREATE POLICY "Participants can view conversation"
  ON conversations FOR SELECT
  USING (auth.uid() = participant_1_id OR auth.uid() = participant_2_id);
```

---

## Supabase Storage 버킷

### voice-recordings
```javascript
// 음성 파일 저장
// 경로: {user_id}/{timestamp}_{random}.webm
// 최대 파일 크기: 10MB
// 허용 형식: audio/webm, audio/mp4, audio/mpeg
```

### avatars
```javascript
// 프로필 이미지
// 경로: {user_id}/avatar.jpg
// 최대 파일 크기: 2MB
// 허용 형식: image/jpeg, image/png, image/webp
```

---

## Realtime 구독 설정

```javascript
// 새로운 대화 메시지 실시간 알림
supabase
  .channel('conversation-messages')
  .on('postgres_changes', 
    { 
      event: 'INSERT', 
      schema: 'public', 
      table: 'conversation_messages',
      filter: `conversation_id=eq.${conversationId}`
    },
    (payload) => {
      // 새 메시지 처리
    }
  )
  .subscribe();

// 사용자 스트릭 업데이트
supabase
  .channel('user-updates')
  .on('postgres_changes',
    {
      event: 'UPDATE',
      schema: 'public',
      table: 'users',
      filter: `id=eq.${userId}`
    },
    (payload) => {
      // 프로필 업데이트
    }
  )
  .subscribe();
```

---

## 데이터베이스 함수 (Database Functions)

### 1. 스트릭 업데이트
```sql
CREATE OR REPLACE FUNCTION update_user_streak(p_user_id UUID)
RETURNS VOID AS $$
DECLARE
  last_active DATE;
  current_streak INTEGER;
BEGIN
  SELECT last_active_date, streak_days INTO last_active, current_streak
  FROM users WHERE id = p_user_id;
  
  IF last_active = CURRENT_DATE THEN
    -- 오늘 이미 활동함
    RETURN;
  ELSIF last_active = CURRENT_DATE - INTERVAL '1 day' THEN
    -- 연속 활동
    UPDATE users 
    SET streak_days = streak_days + 1,
        last_active_date = CURRENT_DATE
    WHERE id = p_user_id;
  ELSE
    -- 스트릭 끊김
    UPDATE users
    SET streak_days = 1,
        last_active_date = CURRENT_DATE
    WHERE id = p_user_id;
  END IF;
END;
$$ LANGUAGE plpgsql;
```

### 2. 대화 제한 체크
```sql
CREATE OR REPLACE FUNCTION check_conversation_limit(
  p_user_id UUID,
  p_other_user_id UUID
)
RETURNS BOOLEAN AS $$
DECLARE
  message_count INTEGER;
  is_premium BOOLEAN;
BEGIN
  SELECT users.is_premium INTO is_premium
  FROM users WHERE id = p_user_id;
  
  IF is_premium THEN
    RETURN TRUE;
  END IF;
  
  SELECT COUNT(*) INTO message_count
  FROM conversation_messages cm
  JOIN conversations c ON c.id = cm.conversation_id
  WHERE cm.sender_id = p_user_id
    AND (c.participant_1_id = p_other_user_id OR c.participant_2_id = p_other_user_id);
  
  RETURN message_count < 10;
END;
$$ LANGUAGE plpgsql;
```

### 3. 일일 브로드캐스트 제한 리셋
```sql
CREATE OR REPLACE FUNCTION reset_daily_broadcast_limit()
RETURNS VOID AS $$
BEGIN
  UPDATE users
  SET daily_voice_broadcasts_count = 0,
      daily_broadcasts_reset_at = CURRENT_DATE
  WHERE daily_broadcasts_reset_at < CURRENT_DATE;
END;
$$ LANGUAGE plpgsql;

-- 매일 자정에 실행 (pg_cron 또는 Supabase Edge Functions)
```

---

## 인덱스 최적화 요약

```sql
-- 자주 조회되는 컬럼에 인덱스 추가
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_voice_messages_created ON voice_messages(created_at DESC);
CREATE INDEX idx_conversations_active ON conversations(is_active, last_message_at DESC);

-- 복합 인덱스
CREATE INDEX idx_user_progress_composite ON user_lesson_progress(user_id, status, lesson_id);
```
