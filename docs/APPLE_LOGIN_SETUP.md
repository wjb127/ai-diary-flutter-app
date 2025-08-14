# Apple 로그인 설정 가이드

## 🎯 문제 해결
현재 오류: `SignInWithAppleAuthorizationException: The operation couldn't be completed`

이는 Supabase Dashboard에서 Apple 로그인이 비활성화되어 있기 때문입니다.

## 📋 필요한 정보

### 1. Apple Developer Console에서 필요한 정보
1. **Services ID** (Client ID)
2. **Private Key** (Secret Key)
3. **Key ID**
4. **Team ID**

## 🛠️ 설정 단계

### Step 1: Apple Developer Console 설정

#### 1.1 App ID 확인
1. [Apple Developer](https://developer.apple.com/account/resources/identifiers/list) 접속
2. **Identifiers** 섹션에서 `com.test.aidiary` 확인
3. **Sign In with Apple** 체크박스 활성화

#### 1.2 Services ID 생성 (웹/서버용)
1. **Identifiers** → **+** 버튼 클릭
2. **Services IDs** 선택
3. 설정:
   - Description: `AI Diary Web Service`
   - Identifier: `com.test.aidiary.service` (예시)
4. **Sign In with Apple** 활성화
5. **Configure** 클릭:
   - Primary App ID: `com.test.aidiary` 선택
   - Domain: `jihhsiijrxhazbxhoirl.supabase.co`
   - Return URLs: `https://jihhsiijrxhazbxhoirl.supabase.co/auth/v1/callback`
6. **Save** → **Continue** → **Register**

#### 1.3 Key 생성
1. **Keys** 섹션으로 이동
2. **+** 버튼 클릭
3. Key Name: `AI Diary Auth Key`
4. **Sign in with Apple** 체크
5. **Configure**에서 Primary App ID 선택
6. **Continue** → **Register**
7. **Download** 클릭하여 `.p8` 파일 다운로드
   - ⚠️ **중요**: 이 파일은 한 번만 다운로드 가능!
8. 다음 정보 메모:
   - **Key ID**: 10자리 코드 (예: ABC123DEFG)
   - **Team ID**: 개발자 계정 우측 상단 (예: 9Q26686S8R)

### Step 2: Secret Key 생성

`.p8` 파일 내용과 다른 정보를 조합하여 JWT 생성이 필요합니다.

#### 옵션 1: 온라인 도구 사용
[Secret Generator Tool](https://developer.apple.com/documentation/sign_in_with_apple/generate_and_validate_tokens) 사용

#### 옵션 2: 수동 생성 (Node.js)
```javascript
const jwt = require('jsonwebtoken');
const fs = require('fs');

const privateKey = fs.readFileSync('AuthKey_XXXXXXXXXX.p8');
const teamId = '9Q26686S8R'; // 당신의 Team ID
const keyId = 'XXXXXXXXXX'; // 당신의 Key ID
const serviceId = 'com.test.aidiary.service'; // Services ID

const token = jwt.sign({}, privateKey, {
  algorithm: 'ES256',
  expiresIn: '180d',
  audience: 'https://appleid.apple.com',
  issuer: teamId,
  subject: serviceId,
  keyid: keyId
});

console.log('Secret Key:', token);
```

### Step 3: Supabase 설정

1. [Supabase Dashboard](https://app.supabase.com/project/jihhsiijrxhazbxhoirl/auth/providers) 접속
2. **Apple** 제공자 찾기
3. **Enable Apple** 토글 활성화
4. 입력:
   - **Client ID**: Services ID (예: `com.test.aidiary.service`)
   - **Secret Key**: 위에서 생성한 JWT 토큰 또는 아래 형식의 JSON:
   ```json
   {
     "team_id": "9Q26686S8R",
     "key_id": "XXXXXXXXXX",
     "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----",
     "client_id": "com.test.aidiary.service"
   }
   ```
5. **Save** 클릭

## 🔍 빠른 확인사항

### 현재 설정 상태
- ✅ iOS 앱 Bundle ID: `com.test.aidiary`
- ✅ Runner.entitlements: Sign in with Apple 활성화됨
- ✅ Info.plist: 설정 완료
- ❌ Supabase: Apple 로그인 비활성화 (설정 필요)

### 필요한 작업
1. Apple Developer Console에서 Services ID 생성
2. Sign in with Apple Key 생성 및 다운로드
3. Supabase Dashboard에 정보 입력

## 🚨 주의사항

1. **Services ID**: iOS 앱 Bundle ID와 다르게 설정 (예: `.service` 추가)
2. **Return URL**: Supabase 프로젝트 URL 정확히 입력
3. **Private Key**: `.p8` 파일은 한 번만 다운로드 가능하므로 안전하게 보관
4. **Team ID**: Apple Developer 계정 우측 상단에서 확인

## 📞 도움이 필요하면

1. Apple Developer Console 스크린샷 제공
2. 생성한 Services ID 공유
3. Team ID 확인

---

## 간단 요약

**Supabase에 입력할 정보:**
- **Client ID (Services ID)**: `com.test.aidiary.service` (새로 생성 필요)
- **Secret Key**: `.p8` 파일과 정보로 생성한 JWT 또는 JSON 객체

이 두 가지만 있으면 Apple 로그인이 작동합니다!