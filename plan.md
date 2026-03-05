어플 이름: Oriverse

- 캐릭터 디자인
    - Ori: 한국어로 오리, Auri, Auro에서 따옴. 긴꼬리딱새의 학명 auroreus에서 따옴.
    - 색깔: 주황/검정/남색
    - 캐릭터: 오리 아니고 새 모양. 긴꼬리딱새 모양.
- 기획
    - 애초에 해결하려는 문제가 학습이 아님. 소통에 있음. 계속 다른 언어 학습할 수 있게 소통의 즐거움을 보여주는 것.
    - 소통을 지속하려면 동기가 필요함. AI랑 대화 -> 사람이랑 대화가 중점.
    - 영어로 스크립트 만들고, 영어, 스페인어, 독일어, 프랑스어, 중국어, 일본어, 한국어 학습/소통 가능.
    - 처음에 접속할 때 자신의 native 언어를 선택하고, 지도로 시각화해서 보여주고, 그 나라를 선택해서 들어갔을 때 자신의 native 언어 <-> 지도 선택한 언어를 공부/소통 가능.
    - native 언어 선택하는 이유는: 어플의 전체 지원 언어 선택하기 위함이고,
    - map에서 선택하는 이유는: 어플에서 학습할 언어/소통할 언어 지정하기 위함.
    - bottom bar에서 학습/소통 2가지의 기능으로 나뉘고, 우측 상단 동그라미 모양으로 개인 설정.
    - 학습 탭: 6가지 스텝이 있음. 1. 기본 문법(어순, 평서문, 의문문, 명령문, 의문사, 조동사 자연스럽게 학습할 수 있는 회화 스크립트) 2. 카페 대화 3. 음식점 대화 4. 마트 대화 5. 취미, 과거경험 대화(과거형, 수동태, 과거분사 사용) 6. 리액션 모음 대화
    - 학습 탭: AI랑 대화한다는 건 실제로 대화한다는 뜻이 아니라 일정한 고정된 스크립트 하에서 음성을 자동으로 텍스트화하게 한다는 의미의 AI와 대화.
    - 학습 탭 레퍼런스: 듀오링고
    - 소통 탭 레퍼런스: 목소리톡(보이스 메일 같은 기능의 어플)
    - 소통 탭: 보이스메일을 주고받음. 대화는 할 수 있지만 실시간 대화는 아님. 왜냐면 내가 실시간으로 대화하면 떨려서 못해…;; 내가 처음에 녹음하면, 그 녹음 기반으로 AI가 약간 수정 제안하고 그에 맞게 수정도 가능함. 필수는 아님. (예시: 안녕? 지금 뭐해? 라고 해보세요. // 앗 이 녹음은 00어로 들리지 않아요. 이렇게 말해볼까요? 정도) 여러 명과 동시에 대화할 수 있고, 1대1 대화만 가능함.
    - 최초 내가 녹음을 보내면 전세계에 퍼뜨릴 수 있고, 답장이 오면 하나씩 답장 가능.
    - 새로운 녹음을 다시 퍼뜨릴 수 있음.
    - 학습 탭: 6개 스크립트를 완료하면 바로 소통 시작 가능(그 전에는 소통 탭 비활성화). 그 이후에 학습 탭에서는 진짜 마지막 학습인 ‘제일 많이 쓰이는 50개 동사를 회화로 익힐 수 있는 학습’이 오픈됨. 이건 유로 결제해야 가능. 처음 3개만 무료 서비스.
    - 결제 시스템: 1. 50동사 확장 → 유료 2. 보이스메일에서 한 사람과 계속해서 10번까지 대화하면 그 이후 대화는 결제해야만 가능. 3. 보이스메일 퍼뜨릴 때 하루에 3개부터는 유로 결제해야 가능. 다음날에 또 가능.
- 와이어프레임
    
    ![image.png](attachment:75aeb9c9-6b7a-47b6-ac26-603da117c372:image.png)
    
- 레퍼런스
    - AI 회화 레퍼런스 - 말해보카 스피킹
    - 듀오링고
    
    ![image.png](attachment:e2409758-749c-4ab1-b4f1-272d79b98bf0:image.png)
    
    - 목소리톡
    
    ![image.png](attachment:064472a5-9388-4a53-8218-e995d5e23c79:image.png)
    
    ![image.png](attachment:5289ca8e-40ab-4646-ad36-2eddd3ca5976:image.png)
    
    ![image.png](attachment:44488ce8-6a90-4bae-8d26-52991ee43895:image.png)
    
    - 다만 목소리톡은 너무 선정적인 UI 느낌이 나서…;; 그 점은 전부 삭제해야 함.
- 앱 설계
    
    ### 앱 재설계 개요
    
    사용자가 제공한 기획을 바탕으로 Oriverse 앱을 재설계한다. 핵심은 언어 소통의 즐거움을 강조하며, 학습을 통해 동기를 부여하고 AI/사람 간 보이스메일 소통으로 전환. 이전 트윗(2026 스택, SOLID, API-first, B2C 플레이북)을 반영해 빠른 MVP 출시, 확장성 강조. 듀오링고(학습 탭 레퍼런스)처럼 개인화 학습과 gamification 적용, 목소리톡(소통 탭 레퍼런스)처럼 익명 음성 채팅 컨셉(비실시간 보이스메일) 반영.
    
    - **앱 이름 & 캐릭터**: Oriverse. Ori 캐릭터 (긴꼬리딱새 모양, 주황/검정/남색 색상) – UI 곳곳에 등장해 친근함 더함 (예: 온보딩 가이드, 학습 피드백).
    - **타겟 오디언스**: 언어 학습자 (초보자 중심), narrow audience (트윗: college students 등)처럼 초기엔 "20-30대 젊은 층"으로 좁힘.
    - **지원 언어**: 영어 스크립트 기반으로 영어, 스페인어, 독일어, 프랑스어, 중국어, 일본어, 한국어. Native 언어 선택으로 앱 UI 언어 설정.
    - **문제 해결**: 학습이 아닌 소통 중심. AI 스크립트로 기본 익히고, 사람 보이스메일로 실전 소통 (동기: 즐거움, 공유).
    - **MVP 스코프**: 트윗 5: 데모 먼저. 온보딩 → 학습 1-2스텝 → 소통 데모. 피드백으로 확장.
    
    ### 1. 아이디어 & UX 흐름 (B2C Playbook 적용)
    
    트윗 "anchor to one question" (am I doing this right?)처럼, "이 언어로 제대로 소통하나?"에 초점.
    
    - **온보딩**:
        - Native 언어 선택 (앱 UI/지원 언어 결정).
        - 지도 시각화: 세계 지도에서 학습/소통 언어 국가 선택 (시각적 가치 5초 내, 트윗 4).
        - 짧은 퀴즈 (트윗 15): 수준 테스트 → 맞춤 스크립트 추천.
    - **UI 구조**:
        - Bottom Bar: 학습 탭 / 소통 탭.
        - 우측 상단: 개인 설정 (프로필, 언어 변경, 결제).
        - 핵심 가치: 첫 세션 내 스크린샷 공유 가능 결과 (트윗 16, 예: 학습 스코어 또는 보이스메일 응답).
    - **학습 탭 (듀오링고 레퍼런스)**:
        - 6스텝: 1. 기본 문법 (회화 스크립트). 2. 카페. 3. 음식점. 4. 마트. 5. 취미/과거 (시제 학습). 6. 리액션.
        - AI 대화: 고정 스크립트 하에서 음성 입력 → 자동 텍스트화 (Speech-to-Text API 사용, 아래 참조). 피드백: 발음/문법 수정 제안.
        - Gamification: 듀오링고처럼 스트릭, 포인트. 6스텝 완료 시 소통 탭 활성화.
        - 추가 학습: 50동사 회화 (유료, 처음 3개 무료).
    - **소통 탭 (목소리톡 레퍼런스)**:
        - 비실시간 보이스메일: 녹음 → AI 수정 제안 (선택적, 예: "이 표현 더 자연스럽게?") → 전세계 퍼뜨리기 (하루 3개 무료, 이후 유료).
        - 답장: 랜덤 매칭, 1:1 대화. 10번 후 유료.
        - 익명: 목소리만 공유 (목소리톡처럼 상상력 자극).
        - AI 통합: 입력 해석 → 명확 답변 (트윗 14).
    - **바이럴 요소**: 공유 CTA (트윗 16), community loops (트윗 27, 예: 스트릭 챌린지). 댓글/피드백 → Claude로 클러스터링 (트윗 13).
    - **마케팅**: TikTok/X 채널 (트윗 Playbook 2), 100 posts (3). Hooks: before/after (9), casual text (10). Virality: shares/installs 측정 (20).
    
    ### 2. 아키텍처 설계 (SOLID + API-first + Duolingo 영감)
    
    트윗 "API-first, UI-second" 따름. 듀오링고처럼 마이크로 서비스 지향 (초기엔 Supabase로 단순화), 서버-driven UI (SDUI)로 빠른 업데이트 고려 (예: 학습 스크립트 서버에서 동적 로드).
    
    - **전체 구조**: 하이브리드 앱 (React Native with @rork). 백엔드: Supabase (DB, Auth, Realtime – 보이스메일 실시간 푸시).
        - **프론트엔드**: React Native. SDUI 요소: 서버에서 UI 컴포넌트 JSON 전송 (듀오링고처럼 빠른 A/B 테스트).
        - **백엔드 API**: GraphQL (효율적 쿼리). 트윗 API 팁: cursor pagination, fields param, Redis caching (Supabase 에지 캐싱), Gzip.
        - **음성 처리**: OpenAI Whisper 또는 GPT-4o-mini-transcribe (2026 최고 추천, 다국어/저오차). 대안: Deepgram (저지연, 5.26% WER).
        - **AI 통합**: OpenAI (분석/수정 제안). 트윗 "AI-feature apps": access/consumption 분리 (비용 관리).
        - **결제**: Stripe (웹훅).
        - **인프라**: Vercel (배포), GitHub (코드), Resend (이메일), Clerk (Auth, Supabase 대체 가능).
    
    SOLID 적용 (트윗: Start with SRP/DIP):
    
    - **SRP**: 각 클래스 한 역할. `VoiceRecorder` (녹음만), `AIFeedbackProvider` (수정 제안만), `MessageDispatcher` (퍼뜨리기만).
    - **OCP**: 인터페이스 확장. `ISpeechToText` (OpenAI 구현, 나중 Deepgram 스위치).
    - **LSP**: 서브클래스 대체 (예: `BaseConversation` → `VoiceConversation`).
    - **ISP**: 작은 인터페이스 ( `IVoiceInput`, `ITextOutput` 분리).
    - **DIP**: 추상화 의존. 고수준 (비즈니스: 학습 로직) → `ISpeechService`, `IPaymentGateway` (Stripe).
    
    데이터 흐름:
    
    - DB: Users (native_lang), Lessons (scripts), Messages (voice_files, S3 저장 via Supabase).
    - 보안: Rate limiting (하루 퍼뜨리기 3개), 유료 체크.
    
    ### 3. 구현 단계 (AI 도구 + Ship Fast)
    
    트윗 스택: @cursor_ai 주요, Claude 보조.
    
    1. **백엔드 셋업**: Supabase 프로젝트. 스키마: users, languages, lessons, conversations. Auth with Clerk. Stripe webhook (유료 기능: 50동사, 대화 10+, 퍼뜨리기 3+).
    2. **AI/음성 통합**: OpenAI API로 STT (음성 → 텍스트), GPT로 피드백. 비용: heavy-user 모니터 (트윗 advice).
    3. **프론트엔드 빌드**: React Native. 지도: Google Maps API. 학습: 스크립트 UI (듀오링고 스타일 퀴즈). 소통: 녹음 버튼 → AI 팝업 → 보내기.
    4. **테스트/반복**: SOLID로 모듈 테스트. 데모 비디오 (20-40초, 트윗 6). Public iterate (19).
    5. **성능**: 트윗 1-10: 대량 데이터 스트리밍, hard limits (페이지 100).
    
    ### 4. 배포 (간단하게: Organic 중심, iOS + Web 우선)
    
    X에서 2026 B2C 앱 플레이북으로 가장 추천되는 건 "iOS + Web first" – 돈 되는 유저가 많아서. Android는 나중에 추가. Oriverse에 적용:
    
    - **초기 배포**: iOS (App Store) + Web 버전 (Vercel 호스팅). 하이브리드 (React Native)라 쉽게 확장.
    - **Android 추가**: Play Store 목표지만, organic 성장 확인 후 (TikTok/X 채널로 100 posts consistency).
    - **마케팅**: Organic first (shares/installs 측정), then paid. Micro-influencers + referrals로 유저 획득. Web funnels로 app store 30% cut 피함.
    
    ### 5. 수익화 (Freemium + Early Charge, Edtech 스타일)
    
    X 추천: "Charge early" – $5 > 5,000 free users, paywall after first clarity (예: 학습 완료 후). Edtech처럼 outcome-linked (학습 결과 기반). Oriverse 적용, 기존 기획 유지하면서 단순화:
    
    - **모델**: Freemium. 기본 학습/소통 무료, 프리미엄 유료.
    - **페이월 위치**: 첫 "moment of clarity" 후 (예: 6스텝 완료 후 소통 활성화 직후).
    - **구체 옵션**:
        1. 50동사 확장: $4.99 (일회성 또는 월 $1.99 sub).
        2. 대화 10+ 회: $0.99/5회 추가 (lifetime deal for early 50 users: $29).
        3. 퍼뜨리기 3+ 개/일: $1.99/무제한 일일 패스.
    - **측정 & 재투자**: LTV/CAC 계산 (organic installs → early profit), cash flow로 creators/more accounts 투자. Retention 중점 (streaks/challenges 무료 시작, 프리미엄화).
- 플레이북
    
    ### Oriverse 앱 빌드 플레이북: 2026 에디션 (수익화 런치 동시 시작 버전)
    
    이 플레이북은 이전 버전을 기반으로 업데이트. 핵심 변경: **런치와 동시에 수익화 시작** (Charge early 원칙 강조). 2026 B2C 앱 추천대로 "Charge early → $5 > 5,000 free users" 적용. Freemium 모델 유지하되, paywall을 첫 가치 순간(6스텝 완료 직후) 바로 배치. X 인디 해커 포스트들(launch ugly, charge early, retention compounds)과 웹 자료(freemium + subscription hybrid, language app 예시 Duolingo-like)를 반영해 단순·실행 가능하게 재구성.
    
    전체 타임라인: 3**주 안에 런치 목표**. 
    
    ### 1. 아이디어 검증 & 기획 (1-2일)
    
    - 완료
    
    ### 2. 설계 & 아키텍처 (2-3일)
    
    - **할 일**: API-first. paywall 로직 추가 (Supabase에서 사용자 상태 체크 → Stripe 링크). Freemium: 기본 무료 (학습 1-3개 + 소통 제한), 프리미엄: 50동사 + 무제한 대화/퍼뜨리기. Hybrid: subscription (월 $4.99) + one-time IAP ($0.99-1.99 소액).
    - **필요 리소스**:
        - 도구: [Draw.io](http://draw.io/) (다이어그램, 무료), Supabase (스키마 + auth, 무료 티어).
        - 예산: $0.
        - 출력: 아키텍처 다이어그램 + paywall 플로우차트.
    
    ### 3. 빌드 (구현, 1주)
    
    - **할 일**: React Native(Expo)로 MVP 빌드. 핵심: paywall integration (Stripe SDK + webhook). 학습 완료 시 "프리미엄으로 소통 무제한 시작!" 팝업. AI 음성/STT (OpenAI) + 수정 제안. Ugly UI OK – 기능 + monetization 우선.
    - **필요 리소스**:
        - 도구: Cursor AI (코딩, $20/월), Claude (보조), @rork (빌드), Vercel (웹 버전), GitHub (무료).
        - API: OpenAI ($50 초기 크레딧), Stripe (무료 셋업, 트랜잭션 2.9%).
        - 예산: $70-150 (API 테스트 + 프로 도구).
        - 출력: monetization-ready MVP (iOS/Web).
    
    ### 4. 테스트 & 반복 (3-5일)
    
    - **할 일**: paywall conversion 테스트 (친구 5-10명: "얼마면 살까?" 피드백). 버그 픽스 + retention 체크 (첫 세션 후 paywall 도달률). Claude로 피드백 클러스터링.
    - **필요 리소스**:
        - 도구: TestFlight (iOS 베타), Vercel Analytics, Google Forms.
        - 예산: $0.
        - 출력: paywall 최적화된 MVP.
    
    ### 5. 런치 & 수익화 동시 시작 (1-2일)
    
    - **할 일**: iOS + Web 먼저 배포 (돈 되는 유저). 런치 당일부터 paywall 활성. Organic installs → 첫 paying user 목표.
    - **필요 리소스**:
        - 도구: Apple Developer ($99/년), Vercel (무료).
        - 예산: $99 (Apple 계정).
        - 출력: 라이브 앱 + Stripe 대시보드 연결.
    
    ### 6. 수익화 모델 (런치 즉시 적용, Charge early 중심)
    
    - **모델**: Freemium + Hybrid (2026 추천: freemium + subscription/IAP). Language 앱처럼 기본 무료 맛보기 → 가치 후 pay.
    - **페이월 위치**: 6스텝 완료 직후 (moment of clarity). "소통 시작하려면 프리미엄!" 버튼.
    - **구체 옵션** (단순하게):
        1. **월 구독** (주요): $4.99/월 – 50동사 전체 + 무제한 대화/퍼뜨리기 + ad-free.
        2. **소액 IAP** (보조): $0.99/5회 추가 대화, $1.99/일 무제한 퍼뜨리기.
        3. **연 구독 옵션** (런치 후 추가): $39.99/년 (할인으로 conversion ↑).
    - **추가 팁**: 3일 free trial (fear ↓, conversion ↑). Weekly trial도 테스트 가능. LTV/CAC 즉시 트래킹 (Supabase + Stripe).
    - **왜 이 모델?**: 2026 트렌드 (hybrid/freemium 지배적). Duolingo-like: 무료로 끌어들이고 subscription으로 장기 수익. Charge early → early validation + cash flow.
    
    ### 7. 마케팅 & 성장 (런치 직후 지속)
    
    - **할 일**: ONE 채널 선택 (TikTok or X). Consistency: 100 posts (데모 20-40초, before/after). Organic first (shares/installs 측정). paying user 나오면 paid ads 테스트.
    - **필요 리소스**:
        - 도구: CapCut (비디오, 무료), TikTok/X Analytics.
        - 예산: $100-300 (초기 콘텐츠/테스트).
        - 출력: 주간 포스트 + 메트릭.
    
    ### 8. 스케일 & 유지 (지속)
    
    - **할 일**: 주간 업데이트 (visible improvements). retention focus (streaks 무료 시작 → premium upsell). AI 비용 모니터. 성공 시 포트폴리오 확장.
    - **필요 리소스**:
        - 도구: Mixpanel (무료 티어), Redis (캐싱 $25/월).
        - 예산: $50/월.
        - 출력: 월 수익 리포트.
    
    **총 예상 예산**: $300-800 (주로 Apple + API + 도구).
    
    **키 원칙**: Launch ugly, charge early, retention compounds, organic win first.
    
    이대로 하면 런치 당일부터 revenue 발생 가능. 첫 paying user 나오면 바로 iterate! 더 세부 조정 필요하면 말해.
    
- 설계 시 플레이북 더 자세히
    
    ### 0. 지금 바로 할 일 (오늘/내일 체크리스트)
    
    1. Supabase → New Project: Americas East US (North Virginia) 선택 (또는 "General Americas East US" – Supabase가 자동 최적 배포).
    2. 프로젝트 생성 후: Project URL + anon key 복사.
    3. Stripe/OpenAI 계정 & 키 준비.
    4. Expo 프로젝트 생성 → supabase-js 설치 → 클라이언트 초기화 테스트 (signUp 해보기).
    5. Supabase 대시보드: users 테이블 metadata에 native_lang 저장 테스트.
    
    이 순서대로 가면 설계 2-3일 안에 끝나고 빌드 들어갈 수 있어요.
    
    ### 1. 지금 당장 만들어야 할 계정 & 기본 셋업 (1~2시간 소요, 비용 $0)
    
    1. **Supabase 계정 만들기**
        - https://supabase.com/ → Sign up (GitHub 또는 이메일로 무료)
        - 로그인 후 Dashboard → **New Project** 클릭
            - Organization: 기본으로 생성됨
            - Project name: e.g. "your-lang-app"
            - Database password: 강력한 거 기억해두기 (나중에 필요)
        - 프로젝트 생성 후 1~2분 기다리면 DB + Auth + Storage 자동 준비됨.
        - **Project URL**과 **anon key** 복사 (API Settings 페이지) → 나중에 Expo 앱에 넣음.
    2. **Stripe 계정 만들기** (paywall 필수)
        - https://stripe.com/ → Sign up (한국 지원됨, 카드 인증 필요)
        - Test mode로 시작 (실제 결제 안 됨)
        - Dashboard → Developers → API keys: **Publishable key** (pk_...) + **Secret key** (sk_...) 복사
        - Webhooks: 나중에 Supabase Edge Functions에서 사용할 거라 미리 webhook secret도 확인
        - Products 생성: Subscription ($4.99/month) + One-time ($0.99~1.99) 미리 만들어 두기 (가격/이름 자유)
    3. **OpenAI 계정 만들기** (AI STT + 수정 제안)
        - https://platform.openai.com/ → Sign up
        - Billing → $5~10 크레딧 충전 (초기 무료 크레딧 있음)
        - API keys → **Secret key** 복사
        - Whisper API (STT) + GPT-4o-mini (제안 생성) 쓸 예정. 한국어/영어 등 다국어 잘 됨.
    4. **Expo 계정 & 개발 환경** (이미 있으면 스킵)
        - https://expo.dev/ → Sign up (GitHub/이메일)
        - Node.js 18+ 설치 (nvm 추천)
        - 터미널: `npm install -g expo-cli` (또는 npx expo)
        - 새 프로젝트: `npx create-expo-app my-lang-app --template blank-typescript`
        - Supabase SDK 설치: `npx expo install @supabase/supabase-js`
        - Stripe SDK: `npx expo install @stripe/stripe-react-native` (React Native용)
    5. **기타 추천 계정**
        - GitHub: Repo 만들어 코드 푸시
        - Cursor AI / Claude: 이미 계획에 있음
        - [Draw.io](http://draw.io/): https://app.diagrams.net/ (브라우저에서 무료)
    
    ### 2. 설계 & 아키텍처 단계 (2-3일) – 당신 계획대로
    
    - **Supabase 대시보드에서 할 일**
        - **Table Editor** (또는 SQL Editor)로 테이블 생성:
            - users (Supabase Auth 자동 생성, metadata에 native_lang 저장)
            - user_progress (학습 완료 여부, streak, gems)
            - scripts (6개 학습 스크립트 데이터)
            - conversations (1:1 보이스메일 스레드)
            - voice_messages (녹음 메타데이터: file_path, sender_id, receiver_id, lang)
            - usage_limits (하루 퍼뜨리기 3개 제한, 대화 10번 제한)
        - **Row Level Security (RLS)** 정책: 각 테이블에 "본인만 읽기/쓰기" 설정 (e.g. auth.uid() = user_id)
        - **Realtime** 활성화: conversations, voice_messages 테이블에 (새 메시지 도착 실시간)
        - **Storage** 버킷 생성: "audio" (private, signed URL로 접근)
    - **아키텍처 다이어그램** (Draw.io로 그리기)
        - 프론트(Expo RN) ↔ Supabase (Auth, DB, Realtime, Storage)
        - 프론트/Edge Functions ↔ OpenAI (STT + LLM 제안)
        - Edge Functions ↔ Stripe (webhook + payment intent)
        - Paywall 플로우: 학습 3개 완료 → supabase.from('user_progress').select() → premium 아니면 Stripe Checkout 링크 보여줌
    - **Paywall 로직**
        - users 테이블에 premium_until (timestamp), subscription_id (Stripe) 컬럼 추가
        - Edge Function으로 Stripe webhook 처리 (subscription updated 시 DB 업데이트)
    
    ### 3. 빌드 단계 (1주) – 핵심 구현 순서
    
    1. **Supabase 클라이언트 초기화** (lib/supabase.ts)
        
        ```tsx
        import { createClient } from '@supabase/supabase-js';
        
        const supabaseUrl = '<https://your-project.supabase.co>';
        const supabaseAnonKey = 'your-anon-key';
        
        export const supabase = createClient(supabaseUrl, supabaseAnonKey);
        ```
        
    2. **Auth 구현** (native_lang 선택 → metadata 업데이트)
        - supabase.auth.signUp / signIn
        - supabase.auth.updateUser({ data: { native_lang: 'ko' } })
    3. **학습 탭**
        - supabase.from('scripts').select()로 스크립트 불러옴
        - 완료 시 user_progress 업데이트 (트랜잭션으로 streak +1)
    4. **소통 탭 (보이스메일)**
        - 녹음 → Storage.upload('audio/' + fileName, blob)
        - 메타 insert → Realtime subscribe로 새 메시지 알림
        - 퍼뜨리기: public pool에 insert + 사용량 체크
    5. **AI STT + 수정 제안** (Edge Functions 추천)
        - Supabase Dashboard → Edge Functions → New Function
        - Deno 코드로: 업로드된 audio URL → OpenAI Whisper API 호출 → 텍스트 → GPT 프롬프트로 "자연스러운 표현 제안"
        - 프론트에서 supabase.functions.invoke('stt-suggest', { body: { audio_url } })
    6. **Paywall + Stripe**
        - Stripe SDK로 Checkout Session 생성 (프론트에서)
        - webhook: Edge Function으로 Stripe 이벤트 listen → DB premium 업데이트
        - Supabase Integrations → Stripe Sync Engine (2025~2026 신기능, one-click으로 customers/subscriptions sync)
    
    ### 추천 Region 전략 (당신 앱에 최적화)
    
    1. **Primary Database Region 선택**
        - **가장 추천: us-east-1 (North Virginia, East US)**
            - 이유: 영어/스페인어 사용자 대부분이 북미/남미/유럽에 몰려 있고, 여행 앱이라 미국 기반 유저(영어 네이티브)가 초기 트래픽의 40~60% 차지할 가능성 큼.
            - 글로벌 트래픽에서 **us-east-1**이 Supabase 기본/가장 안정적 리전 중 하나 (많은 앱들이 여기서 시작).
            - 중국 사용자 latency는 200~300ms 정도지만, Read Replicas로 보완 가능.
        - **대안1: ap-northeast-1 (Tokyo)**
            - 중국/아시아 사용자 많을 때 (중국어 우선 지원이라면). 한국 IP 기반이니 초기 테스트 편함. 하지만 영어/스페인어 타겟이면 북미보다 latency 불리.
        - **대안2: eu-central-1 (Frankfurt)**
            - 스페인어 (유럽) + 영어 (영국/유럽 여행자) 우선이라면. GDPR 준수도 좋음.
        
        → **결론: us-east-1**로 시작하세요. 여행 앱 글로벌 타겟이면 북미 중심이 가장 균형 잡힘 (Supabase docs + 실전 사례에서 "Americas East US"를 general 추천으로 자주 언급).
        
    2. **Read Replicas 추가 (글로벌 latency 낮추기)**
        - Pro 플랜 ($25/월)부터 가능 (무료 티어는 single region만).
        - 추천 replicas (초기 1~2개부터 추가, 비용 $100~210/개 정도):
            - **eu-central-1 (Frankfurt)** 또는 **eu-west-1 (Ireland)** → 유럽/스페인어 사용자 (latency 20~50ms)
            - **ap-northeast-1 (Tokyo)** 또는 **ap-southeast-1 (Singapore)** → 중국/아시아 여행자 (중국 사용자에게 50~100ms 수준)
            - **sa-east-1 (São Paulo)** → 스페인어 남미 (라틴아메리카) 사용자 (브라질/아르헨티나 등 여행 많음)
        - Supabase의 **자동 geo-routing** (GET 요청 시 가까운 replica로 자동 라우팅) 덕분에, 영어/스페인어/중국어 사용자 모두 가까운 DB에서 읽기 → latency 크게 줄음.
        - 쓰기(INSERT/UPDATE)는 Primary로 가지만, 당신 앱은 **읽기 중심** (학습 스크립트 불러오기, 보이스메일 목록, streak 확인)이 대부분이라 효과 극대.
    3. **Edge Functions (STT/LLM 호출 등)**
        - 이미 **글로벌 엣지**로 실행됨 (Tokyo, Seoul, Singapore, Frankfurt, N. Virginia, Oregon 등 10+ 리전 지원).
        - 사용자 가까운 곳에서 자동 실행 → OpenAI/Deepgram 호출 latency도 최소화 (cold start는 있지만, 여행 앱처럼 자주 호출 안 되니 문제 적음).
    
    ### 실제 셋업 순서 (당신 계획에 맞춰)
    
    1. Supabase New Project 생성 시
        - Region: **Americas East US (North Virginia)** 선택 (또는 general "Americas East US" – Supabase가 자동 배포)
        - 생성 후 Dashboard → Settings → API: Primary endpoint 확인 (e.g. [db.yourproject.supabase.co](http://db.yourproject.supabase.co/))
    2. 성장 시 Read Replicas 추가
        - Dashboard → Infrastructure → Read Replicas → New Replica
        - Region 선택 (e.g. Frankfurt, Tokyo) → 생성 5~10분
        - 자동으로 GET 쿼리 geo-routing 활성화됨 (코드 변경 없이!)
    3. 앱 코드에서 (Expo RN)
        - supabase-js는 자동으로 Primary 쓰지만, Read Replicas는 Supabase가 백그라운드에서 처리 (dedicated endpoint도 제공).
        - 중국 사용자 많아지면 Tokyo replica 추가 + 테스트 (e.g. ping 도구로 latency 측정).
    
    ### 예상 latency (글로벌 여행자 기준)
    
    - 북미 사용자: <50ms
    - 유럽/스페인어: 50~100ms (Frankfurt replica)
    - 중국/아시아: 100~200ms (Tokyo/Singapore replica)
    - 남미: 100~150ms (São Paulo replica)
    
    이 조합이면 Duolingo 초기 버그처럼 "연결감 없음" 걱정 없이 글로벌하게 운영 가능해요.
    
    초기 MVP는 Primary us-east-1 하나로 충분 → 유저 10만+ 넘을 때 replicas 2개 추가하면 돼요.