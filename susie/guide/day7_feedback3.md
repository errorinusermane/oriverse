# Day 7 Feedback 3 — 두 번째 녹음 업로드 403 오류

## 오류 메시지

```
ERROR  [uploadRecording] HTTP error: 400 {"statusCode":"403","error":"Unauthorized","message":"new row violates row-level security policy"}
```

---

## 근본 원인

**Storage `user-recordings` 버킷에 UPDATE 정책이 없음.**

### 왜 첫 번째는 성공하고 두 번째는 실패하는가?

업로드 경로가 `${userId}/${scriptId}.${ext}` 고정 패턴이라 같은 스크립트를 다시 녹음하면 동일한 경로가 생성됨.

| 순서 | 파일 존재 여부 | Supabase 내부 동작 | 필요 정책 | 결과 |
|---|---|---|---|---|
| 1번 녹음 | 없음 | POST → **INSERT** | INSERT 정책 | 성공 |
| 2번 녹음 | 있음 | POST + `x-upsert: true` → **UPDATE** | UPDATE 정책 | **403 실패** |

`x-upsert: 'true'` 헤더가 있어도 Storage RLS는 INSERT/UPDATE를 별개 정책으로 평가함.
마이그레이션 파일(`001~006_*.sql`) 어디에도 Storage 버킷 RLS 정책이 정의되어 있지 않음 → UPDATE 정책 자체가 존재하지 않음.

---

## 확인 방법

Supabase Dashboard → **Storage → Policies → user-recordings** 확인.
아래 두 정책이 모두 있어야 함:

| 정책명 | Operation |
|---|---|
| Allow users to upload own recordings | INSERT |
| Allow users to update own recordings | **UPDATE ← 이게 없음** |

---

## 수정 방법

Supabase Dashboard SQL Editor에서 실행:

```sql
CREATE POLICY "Allow users to update own recordings"
ON storage.objects
FOR UPDATE
USING (
  bucket_id = 'user-recordings'
  AND auth.uid()::text = (storage.foldername(name))[1]
);
```

또는 Dashboard에서 직접:
1. Storage → user-recordings → Policies
2. New Policy → For full customization
3. Operation: UPDATE
4. USING 조건: `bucket_id = 'user-recordings' AND auth.uid()::text = (storage.foldername(name))[1]`

---

## 마이그레이션 파일에도 추가 권장

`supabase/migrations/007_storage_policies.sql` 새 파일로 추가해두면 나중에 환경 재설정 시 누락 방지:

```sql
-- user-recordings 버킷 Storage RLS
-- INSERT: 본인 폴더에만 업로드 허용
-- UPDATE: x-upsert 재업로드(재녹음) 허용
-- SELECT: 본인 파일만 조회 허용

INSERT INTO storage.buckets (id, name, public)
VALUES ('user-recordings', 'user-recordings', false)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "recordings_insert_own" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'user-recordings'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "recordings_update_own" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'user-recordings'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "recordings_select_own" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'user-recordings'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );
```

---

## 교훈

- Storage 버킷 생성 시 INSERT만 만들면 안 됨. **재업로드(upsert)가 있으면 UPDATE도 필수.**
- 동일 경로로 upsert하는 설계라면 INSERT + UPDATE 정책을 항상 쌍으로 생성할 것.
- 로드맵 Day 6 병목에 이미 "Storage 권한 누락 시 403" 경고가 있었음 → 버킷 생성 시 정책 3개(INSERT/UPDATE/SELECT) 일괄 체크 습관화 필요.
