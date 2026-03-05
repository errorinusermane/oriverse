# Oriverse - 아키텍처 설계 문서

## 프로젝트 개요

**Oriverse**는 언어 소통의 즐거움을 강조하는 다국어 학습 및 음성 소통 앱입니다. AI 기반 학습과 비실시간 보이스메일을 통해 사용자 간 실전 소통을 제공합니다.

- **지원 언어**: 영어, 스페인어, 독일어, 프랑스어, 중국어, 일본어, 한국어
- **핵심 기능**: AI 회화 학습 (듀오링고 스타일) + 보이스메일 소통 (목소리톡 스타일)
- **수익 모델**: Freemium + Subscription ($4.99/월) + IAP

---

## 아키텍처 개요

### 기술 스택 (2026 추천 스택)

```
┌─────────────────────────────────────────────────────────────┐
│                        클라이언트                             │
│  React Native (Expo) - iOS/Android/Web                     │
│  - @rork (빌드 최적화)                                       │
│  - React Navigation (라우팅)                                 │
│  - Zustand (상태관리)                                        │
│  - React Query (서버 상태)                                   │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ HTTPS / GraphQL
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      API 게이트웨이                          │
│  Vercel Edge Functions / Supabase Edge Functions           │
│  - Rate Limiting (결제 제한 체크)                            │
│  - Authentication (Clerk or Supabase Auth)                 │
│  - GraphQL API (Apollo Server)                             │
└─────────────────────────────────────────────────────────────┘
                            │
          ┌─────────────────┼─────────────────┐
          ▼                 ▼                 ▼
┌──────────────────┐ ┌──────────────┐ ┌──────────────────┐
│   Supabase       │ │  OpenAI API  │ │  Stripe API      │
│                  │ │              │ │                  │
│ - PostgreSQL     │ │ - Whisper    │ │ - Payment        │
│ - Auth           │ │ - GPT-4o     │ │ - Subscription   │
│ - Storage        │ │ - TTS        │ │ - Webhook        │
│ - Realtime       │ │              │ │                  │
└──────────────────┘ └──────────────┘ └──────────────────┘
```

### 핵심 원칙 (SOLID 적용)

1. **API-First 설계**: 프론트엔드보다 백엔드 API를 먼저 설계
2. **SOLID 원칙**:
   - **SRP**: 각 모듈은 단일 책임 (예: `VoiceRecorder`, `AIFeedbackProvider`)
   - **OCP**: 인터페이스로 확장 가능하게 설계 (예: `ISpeechToText` 구현체 교체 가능)
   - **DIP**: 고수준 비즈니스 로직은 추상화에 의존
3. **Server-Driven UI (SDUI)**: 학습 스크립트를 서버에서 동적 로드 (빠른 A/B 테스트)
4. **마이크로서비스 지향**: 초기엔 Supabase로 단순화, 추후 분리 가능

---

## 엔드포인트 설계 (API Design)

### 1. GraphQL API 스키마

GraphQL을 사용하여 효율적인 쿼리와 확장성 확보. REST 대신 GraphQL을 선택한 이유:
- 클라이언트가 필요한 데이터만 요청 (Over-fetching 방지)
- 단일 엔드포인트로 복잡한 쿼리 처리
- 강타입 시스템으로 명확한 API 계약

#### 주요 쿼리 (Queries)

```graphql
type Query {
  # 사용자 정보
  me: User!
  user(id: ID!): User
  
  # 언어 및 학습
  languages: [Language!]!
  lessons(languageId: ID!): [Lesson!]!
  lessonScripts(lessonId: ID!, languageId: ID!): [LessonScript!]!
  myLessonProgress(lessonId: ID!): UserLessonProgress
  
  # 보이스메일 및 대화
  myVoiceMessages(status: BroadcastStatus): [VoiceMessage!]!
  broadcastedMessages(languageId: ID!, limit: Int, cursor: String): MessageConnection!
  myConversations(limit: Int, cursor: String): ConversationConnection!
  conversationMessages(conversationId: ID!, limit: Int, cursor: String): MessageConnection!
  
  # 결제
  mySubscription: Subscription
  paymentHistory: [Payment!]!
}
```

#### 주요 뮤테이션 (Mutations)

```graphql
type Mutation {
  # 온보딩
  setNativeLanguage(languageId: ID!): User!
  setLearningLanguage(languageId: ID!): User!
  
  # 학습
  startLesson(lessonId: ID!): UserLessonProgress!
  completeScript(lessonId: ID!, scriptId: ID!, voiceRecordingUrl: String!): ScriptResult!
  completeLesson(lessonId: ID!, score: Int!): UserLessonProgress!
  
  # 보이스메일
  createVoiceMessage(audioFile: Upload!, languageId: ID!): VoiceMessage!
  requestAIFeedback(voiceMessageId: ID!): AIFeedback!
  editVoiceMessage(voiceMessageId: ID!, editedAudioFile: Upload!): VoiceMessage!
  broadcastVoiceMessage(voiceMessageId: ID!): VoiceMessage!
  
  # 대화
  startConversation(voiceMessageId: ID!): Conversation!
  replyToConversation(conversationId: ID!, voiceMessageId: ID!): ConversationMessage!
  markMessageAsRead(messageId: ID!): ConversationMessage!
  
  # 결제
  createCheckoutSession(productType: ProductType!): CheckoutSession!
  cancelSubscription: Subscription!
}
```

#### 타입 정의

```graphql
type User {
  id: ID!
  email: String!
  username: String
  nativeLanguage: Language!
  learningLanguage: Language!
  avatarUrl: String
  lessonsCompleted: Int!
  totalPoints: Int!
  streakDays: Int!
  isPremium: Boolean!
  subscriptionTier: SubscriptionTier!
  dailyBroadcastsRemaining: Int!
}

type Language {
  id: ID!
  code: String!
  nameEn: String!
  nameNative: String!
  countryName: String!
  flagEmoji: String!
  mapCoordinates: Coordinates
}

type Lesson {
  id: ID!
  stepNumber: Int!
  titleKey: String!
  category: String!
  isFree: Boolean!
  pointsReward: Int!
}

type VoiceMessage {
  id: ID!
  sender: User!
  audioFileUrl: String!
  durationSeconds: Int!
  transcribedText: String
  aiFeedback: AIFeedback
  broadcastStatus: BroadcastStatus!
  language: Language!
  createdAt: DateTime!
}

type Conversation {
  id: ID!
  participants: [User!]!
  language: Language!
  messageCount: Int!
  lastMessageAt: DateTime!
  isPaywallReached: Boolean!
  messages(limit: Int, cursor: String): MessageConnection!
}

enum BroadcastStatus {
  DRAFT
  BROADCASTED
}

enum SubscriptionTier {
  FREE
  PREMIUM
}

enum ProductType {
  SUBSCRIPTION_MONTHLY
  SUBSCRIPTION_YEARLY
  VERBS50
  CONVERSATION_PACK
  BROADCAST_PACK
}
```

### 2. REST API 엔드포인트 (보조)

GraphQL이 주요이지만, 특정 기능은 REST로 제공:

```
POST   /api/upload/voice        # 음성 파일 업로드 (multipart/form-data)
POST   /api/upload/avatar       # 프로필 이미지 업로드
GET    /api/stream/audio/:id    # 오디오 스트리밍
POST   /api/webhooks/stripe     # Stripe 웹훅
```

### 3. API 최적화 전략

#### Cursor Pagination (대용량 데이터)
```graphql
type MessageConnection {
  edges: [MessageEdge!]!
  pageInfo: PageInfo!
}

type MessageEdge {
  node: VoiceMessage!
  cursor: String!
}

type PageInfo {
  hasNextPage: Boolean!
  endCursor: String
}
```

#### Fields Parameter (필요한 필드만 요청)
```graphql
query {
  myConversations {
    id
    lastMessageAt
    # audioFileUrl 제외 -> 대역폭 절약
  }
}
```

#### Redis Caching (Supabase Edge Caching)
```javascript
// 자주 조회되는 데이터 캐싱
cache.set(`user:${userId}`, userData, { ttl: 300 }); // 5분
cache.set(`lessons:${languageId}`, lessons, { ttl: 3600 }); // 1시간
```

#### Gzip Compression
```javascript
// Vercel Edge Functions에서 자동 지원
export const config = {
  runtime: 'edge',
  regions: ['icn1'], // Seoul
};
```

---

## 백엔드 설계

### 1. 서비스 레이어 구조 (SOLID 적용)

```
backend/
├── services/
│   ├── auth/
│   │   ├── AuthService.ts              # 인증 비즈니스 로직
│   │   └── IAuthProvider.ts            # 인터페이스
│   ├── learning/
│   │   ├── LessonService.ts            # 학습 관리
│   │   ├── ProgressTracker.ts          # 진행도 추적
│   │   └── StreakManager.ts            # 스트릭 관리
│   ├── voice/
│   │   ├── VoiceRecorder.ts            # 녹음 (SRP)
│   │   ├── ISpeechToText.ts            # 인터페이스 (OCP/DIP)
│   │   ├── OpenAISpeechService.ts      # Whisper 구현
│   │   ├── AIFeedbackProvider.ts       # 피드백 생성 (SRP)
│   │   └── MessageDispatcher.ts        # 퍼뜨리기 (SRP)
│   ├── conversation/
│   │   ├── ConversationManager.ts      # 대화 관리
│   │   └── MessageMatcher.ts           # 랜덤 매칭
│   └── payment/
│       ├── IPaymentGateway.ts          # 인터페이스 (DIP)
│       ├── StripeService.ts            # Stripe 구현
│       └── SubscriptionManager.ts      # 구독 관리
├── graphql/
│   ├── schema.graphql
│   ├── resolvers/
│   │   ├── userResolver.ts
│   │   ├── lessonResolver.ts
│   │   ├── voiceMessageResolver.ts
│   │   └── paymentResolver.ts
│   └── context.ts                      # GraphQL 컨텍스트
├── database/
│   ├── supabase.ts                     # Supabase 클라이언트
│   └── migrations/                     # 스키마 마이그레이션
└── utils/
    ├── rateLimiter.ts                  # Rate limiting
    └── errorHandler.ts                 # 에러 처리
```

### 2. 핵심 서비스 구현 예시

#### ISpeechToText 인터페이스 (OCP/DIP)
```typescript
export interface ISpeechToText {
  transcribe(audioBuffer: Buffer, languageCode: string): Promise<TranscriptionResult>;
}

export interface TranscriptionResult {
  text: string;
  confidence: number;
  detectedLanguage: string;
}
```

#### OpenAISpeechService (구현체)
```typescript
export class OpenAISpeechService implements ISpeechToText {
  constructor(private openai: OpenAI) {}
  
  async transcribe(audioBuffer: Buffer, languageCode: string): Promise<TranscriptionResult> {
    const file = new File([audioBuffer], "audio.webm");
    const result = await this.openai.audio.transcriptions.create({
      file: file,
      model: "whisper-1",
      language: languageCode,
    });
    
    return {
      text: result.text,
      confidence: 0.95, // Whisper는 confidence 제공 안함
      detectedLanguage: languageCode,
    };
  }
}
```

#### AIFeedbackProvider (SRP)
```typescript
export class AIFeedbackProvider {
  constructor(private openai: OpenAI, private speechService: ISpeechToText) {}
  
  async provideFeedback(
    audioBuffer: Buffer,
    expectedText: string,
    languageCode: string
  ): Promise<AIFeedback> {
    // 1. 음성 -> 텍스트
    const transcription = await this.speechService.transcribe(audioBuffer, languageCode);
    
    // 2. GPT로 피드백 생성
    const prompt = `
      Expected: "${expectedText}"
      User said: "${transcription.text}"
      Language: ${languageCode}
      
      Provide feedback in JSON format:
      {
        "isCorrect": boolean,
        "suggestions": string[],
        "corrections": string[],
        "score": number (0-100)
      }
    `;
    
    const response = await this.openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: prompt }],
      response_format: { type: "json_object" },
    });
    
    return JSON.parse(response.choices[0].message.content);
  }
}
```

#### StripeService (IPaymentGateway 구현)
```typescript
export class StripeService implements IPaymentGateway {
  constructor(private stripe: Stripe) {}
  
  async createCheckoutSession(
    userId: string,
    productType: ProductType
  ): Promise<CheckoutSession> {
    const prices = {
      SUBSCRIPTION_MONTHLY: 'price_monthly_499',
      VERBS50: 'price_verbs50_499',
      CONVERSATION_PACK: 'price_conv_099',
    };
    
    const session = await this.stripe.checkout.sessions.create({
      customer: userId,
      payment_method_types: ['card'],
      line_items: [
        {
          price: prices[productType],
          quantity: 1,
        },
      ],
      mode: productType.includes('SUBSCRIPTION') ? 'subscription' : 'payment',
      success_url: `${process.env.APP_URL}/payment/success`,
      cancel_url: `${process.env.APP_URL}/payment/cancel`,
    });
    
    return { sessionId: session.id, url: session.url };
  }
  
  async handleWebhook(payload: Buffer, signature: string): Promise<void> {
    const event = this.stripe.webhooks.constructEvent(
      payload,
      signature,
      process.env.STRIPE_WEBHOOK_SECRET
    );
    
    switch (event.type) {
      case 'checkout.session.completed':
        await this.handleCheckoutCompleted(event.data.object);
        break;
      case 'customer.subscription.deleted':
        await this.handleSubscriptionCancelled(event.data.object);
        break;
    }
  }
}
```

### 3. Rate Limiting & 결제 제한

```typescript
export class RateLimiter {
  // 하루 브로드캐스트 3개 제한
  async checkBroadcastLimit(userId: string, isPremium: boolean): Promise<boolean> {
    if (isPremium) return true;
    
    const { data: user } = await supabase
      .from('users')
      .select('daily_voice_broadcasts_count, daily_broadcasts_reset_at')
      .eq('id', userId)
      .single();
    
    // 날짜 리셋
    if (user.daily_broadcasts_reset_at < new Date().toISOString().split('T')[0]) {
      await supabase
        .from('users')
        .update({ daily_voice_broadcasts_count: 0, daily_broadcasts_reset_at: new Date() })
        .eq('id', userId);
      return true;
    }
    
    return user.daily_voice_broadcasts_count < 3;
  }
  
  // 대화 10회 제한
  async checkConversationLimit(
    userId: string,
    otherUserId: string,
    isPremium: boolean
  ): Promise<boolean> {
    if (isPremium) return true;
    
    const { data } = await supabase.rpc('check_conversation_limit', {
      p_user_id: userId,
      p_other_user_id: otherUserId,
    });
    
    return data;
  }
}
```

---

## 프론트엔드 설계

### 1. 프로젝트 구조

```
app/
├── src/
│   ├── screens/
│   │   ├── onboarding/
│   │   │   ├── LanguageSelectScreen.tsx     # Native 언어 선택
│   │   │   └── MapSelectScreen.tsx          # 학습 언어 지도 선택
│   │   ├── learning/
│   │   │   ├── LearningHomeScreen.tsx       # 6스텝 목록
│   │   │   ├── LessonDetailScreen.tsx       # 스크립트 학습
│   │   │   └── ConversationPracticeScreen.tsx # AI 대화
│   │   ├── communication/
│   │   │   ├── CommunicationHomeScreen.tsx  # 보이스메일 목록
│   │   │   ├── RecordVoiceScreen.tsx        # 녹음
│   │   │   ├── AIFeedbackScreen.tsx         # AI 피드백
│   │   │   └── ConversationDetailScreen.tsx # 1:1 대화
│   │   ├── profile/
│   │   │   ├── ProfileScreen.tsx            # 개인 설정
│   │   │   └── SubscriptionScreen.tsx       # 구독 관리
│   │   └── payment/
│   │       └── CheckoutScreen.tsx           # Stripe Checkout
│   ├── components/
│   │   ├── ui/
│   │   │   ├── Button.tsx
│   │   │   ├── Card.tsx
│   │   │   └── VoiceWaveform.tsx
│   │   ├── learning/
│   │   │   ├── LessonCard.tsx
│   │   │   ├── ScriptBubble.tsx
│   │   │   └── ProgressBar.tsx
│   │   └── communication/
│   │       ├── VoiceMessageCard.tsx
│   │       └── RecordButton.tsx
│   ├── hooks/
│   │   ├── useAuth.ts
│   │   ├── useVoiceRecorder.ts
│   │   ├── useAudioPlayer.ts
│   │   └── useSubscription.ts
│   ├── services/
│   │   ├── api/
│   │   │   ├── graphqlClient.ts
│   │   │   └── queries.ts
│   │   ├── audio/
│   │   │   ├── AudioRecorder.ts
│   │   │   └── AudioPlayer.ts
│   │   └── storage/
│   │       └── SecureStorage.ts
│   ├── store/
│   │   ├── authStore.ts                     # Zustand
│   │   ├── learningStore.ts
│   │   └── conversationStore.ts
│   └── utils/
│       ├── i18n.ts                          # 다국어 지원
│       └── analytics.ts
└── app.json                                 # Expo 설정
```

### 2. 상태 관리 (Zustand)

```typescript
// authStore.ts
import create from 'zustand';

interface AuthState {
  user: User | null;
  isAuthenticated: boolean;
  isPremium: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  checkSubscription: () => Promise<void>;
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  isAuthenticated: false,
  isPremium: false,
  
  login: async (email, password) => {
    const { data } = await supabase.auth.signInWithPassword({ email, password });
    const user = await fetchUserProfile(data.user.id);
    set({ user, isAuthenticated: true, isPremium: user.isPremium });
  },
  
  logout: () => {
    supabase.auth.signOut();
    set({ user: null, isAuthenticated: false, isPremium: false });
  },
  
  checkSubscription: async () => {
    // Stripe 구독 상태 확인
  },
}));
```

### 3. 핵심 컴포넌트

#### RecordButton (음성 녹음)
```typescript
export const RecordButton: React.FC = () => {
  const [isRecording, setIsRecording] = useState(false);
  const { startRecording, stopRecording, audioUri } = useVoiceRecorder();
  
  const handlePress = async () => {
    if (isRecording) {
      const uri = await stopRecording();
      // AI 피드백 요청
      await requestAIFeedback(uri);
    } else {
      await startRecording();
    }
    setIsRecording(!isRecording);
  };
  
  return (
    <TouchableOpacity onPress={handlePress}>
      <View style={[styles.button, isRecording && styles.recording]}>
        <Icon name={isRecording ? "stop" : "mic"} />
      </View>
    </TouchableOpacity>
  );
};
```

#### PaywallModal (결제 팝업)
```typescript
export const PaywallModal: React.FC<{ visible: boolean; productType: ProductType }> = ({
  visible,
  productType,
}) => {
  const handlePurchase = async () => {
    const { url } = await createCheckoutSession(productType);
    Linking.openURL(url);
  };
  
  return (
    <Modal visible={visible}>
      <View style={styles.container}>
        <Text>🚀 프리미엄으로 업그레이드하세요!</Text>
        <Button title="$4.99/월 시작하기" onPress={handlePurchase} />
      </View>
    </Modal>
  );
};
```

### 4. Server-Driven UI (SDUI)

학습 스크립트를 서버에서 동적으로 로드:

```typescript
// 서버에서 반환하는 JSON
{
  "lessonId": "lesson-1",
  "components": [
    {
      "type": "ScriptBubble",
      "props": {
        "speaker": "ai",
        "text": "Hello! How are you?",
        "audioUrl": "https://..."
      }
    },
    {
      "type": "UserInputButton",
      "props": {
        "expectedText": "I'm fine, thank you!",
        "validateSpeech": true
      }
    }
  ]
}

// 클라이언트에서 렌더링
const componentMap = {
  ScriptBubble: ScriptBubble,
  UserInputButton: UserInputButton,
};

lesson.components.map((component) => {
  const Component = componentMap[component.type];
  return <Component key={component.id} {...component.props} />;
});
```

---

## 배포 및 인프라

### 1. 배포 플랫폼

- **프론트엔드**: 
  - iOS: App Store (Apple Developer $99/년)
  - Android: Google Play (나중에 추가)
  - Web: Vercel (무료 티어)
- **백엔드**: Vercel Edge Functions (GraphQL API)
- **데이터베이스**: Supabase (무료 티어 → Pro $25/월)
- **스토리지**: Supabase Storage (음성 파일)

### 2. CI/CD 파이프라인

```yaml
# .github/workflows/deploy.yml
name: Deploy Oriverse

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm test
  
  deploy-backend:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: vercel --prod --token=${{ secrets.VERCEL_TOKEN }}
  
  deploy-mobile:
    needs: test
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - run: expo build:ios
      - run: expo upload:ios
```

### 3. 모니터링 및 분석

- **에러 트래킹**: Sentry
- **분석**: Mixpanel (유저 행동) + Stripe Dashboard (결제)
- **성능**: Vercel Analytics (웹) + Firebase Performance (모바일)
- **로그**: Supabase Logs + CloudWatch

---

## 개발 로드맵 (3주 MVP)

### Week 1: 백엔드 & 인프라
- [ ] Supabase 프로젝트 셋업 + 스키마 생성
- [ ] GraphQL API 구현 (User, Lesson, VoiceMessage)
- [ ] OpenAI STT/TTS 통합
- [ ] Stripe 결제 웹훅 구현

### Week 2: 프론트엔드 (핵심 기능)
- [ ] 온보딩 플로우 (언어 선택 + 지도)
- [ ] 학습 탭 (1-2개 스텝만 MVP)
- [ ] 소통 탭 (녹음 + AI 피드백 + 퍼뜨리기)
- [ ] Paywall 통합

### Week 3: 테스트 & 런치
- [ ] 베타 테스트 (TestFlight)
- [ ] 피드백 반영
- [ ] App Store 제출
- [ ] 마케팅 콘텐츠 제작 (TikTok/X)

---

## 보안 및 규정 준수

### 1. 데이터 보안
- HTTPS 강제 (Vercel 자동 SSL)
- Supabase RLS (Row Level Security)
- JWT 토큰 기반 인증
- 음성 파일 암호화 (저장 시)

### 2. 개인정보 보호
- GDPR/CCPA 준수 (데이터 삭제 요청 API)
- 익명 보이스메일 (실명 노출 없음)
- 사용자 동의 (녹음 권한)

### 3. 콘텐츠 검토
- AI 기반 음성 필터링 (부적절한 콘텐츠 차단)
- 신고 시스템 (남용 방지)

---

## 비용 예측 (초기 100명 기준)

| 항목 | 월 비용 |
|------|---------|
| Supabase Pro | $25 |
| OpenAI API (Whisper + GPT) | ~$50 |
| Vercel Pro | $20 |
| Apple Developer | $8.25 (연간 $99 ÷ 12) |
| Stripe 수수료 | ~$15 (월 $300 수익 × 5%) |
| **총합** | **~$118/월** |

수익: 월 $4.99 × 10명 (10% conversion) = **$49.9/월**  
→ Break-even: 약 25명의 유료 사용자 필요

---

## 다음 단계

1. **MVP 완료 후**:
   - Android 버전 출시
   - 50동사 컨텐츠 추가 (유료)
   - 커뮤니티 기능 (스트릭 챌린지)

2. **스케일 업**:
   - 마이크로서비스 분리 (음성 처리 전용 서버)
   - CDN 추가 (CloudFront)
   - 다국어 확장 (베트남어, 태국어 등)

3. **수익화 최적화**:
   - A/B 테스트 (가격, paywall 위치)
   - Lifetime Deal ($29)
   - B2B 옵션 (학교/기업)
