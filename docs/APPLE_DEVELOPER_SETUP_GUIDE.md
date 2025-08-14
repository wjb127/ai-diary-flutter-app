# 🍎 Apple Developer Console 설정 상세 가이드

## 📍 시작하기 전에
- Apple Developer 계정 필요 (연 $99)
- Team ID 확인: Apple Developer 페이지 우측 상단 (예: 9Q26686S8R)

---

## 1️⃣ App ID 확인 및 Sign in with Apple 활성화

### 단계별 진행:

1. **Apple Developer Console 접속**
   - https://developer.apple.com/account/resources/identifiers/list 로 이동

2. **기존 App ID 찾기**
   - Identifiers 목록에서 `com.test.aidiary` 찾기
   - 없다면 Xcode에서 자동 생성되었을 수 있음

3. **App ID 클릭하여 편집**
   - `com.test.aidiary` 클릭

4. **Capabilities 섹션에서 Sign In with Apple 활성화**
   - ✅ **Sign In with Apple** 체크박스 선택
   - 우측에 "Enabled" 표시 확인

5. **저장**
   - 우측 상단 **Save** 버튼 클릭

---

## 2️⃣ Services ID 생성 (이것이 Client ID가 됩니다)

### 단계별 진행:

1. **Identifiers 페이지에서 새 ID 생성**
   - 우측 상단 **+** (파란색 플러스) 버튼 클릭

2. **Services IDs 선택**
   - 라디오 버튼에서 **Services IDs** 선택
   - **Continue** 클릭

3. **Service 정보 입력**
   ```
   Description: AI Diary Web Service
   Identifier: com.test.aidiary.service
   ```
   - ⚠️ **중요**: Identifier는 앱 Bundle ID와 달라야 함
   - **Continue** 클릭

4. **Sign In with Apple 설정**
   - ✅ **Sign In with Apple** 체크박스 선택
   - **Configure** 버튼 클릭

5. **Web Authentication Configuration 팝업**
   
   **Primary App ID:**
   - 드롭다운에서 `com.test.aidiary` 선택
   
   **Domains and Subdomains:**
   ```
   jihhsiijrxhazbxhoirl.supabase.co
   ```
   - ⚠️ https:// 제외하고 도메인만 입력
   
   **Return URLs:**
   ```
   https://jihhsiijrxhazbxhoirl.supabase.co/auth/v1/callback
   ```
   - **Add** 버튼 클릭하여 추가
   
   - **Next** 클릭

6. **확인 및 저장**
   - 정보 확인 후 **Done** 클릭
   - 메인 화면에서 **Continue** → **Register** 클릭

7. **생성 완료**
   - ✅ Services ID 생성 완료: `com.test.aidiary.service`
   - 이것이 Supabase의 **Client ID**가 됩니다

---

## 3️⃣ Sign in with Apple Key 생성 (Secret Key용)

### 단계별 진행:

1. **Keys 섹션으로 이동**
   - 좌측 메뉴에서 **Keys** 클릭
   - 또는 https://developer.apple.com/account/resources/authkeys/list

2. **새 Key 생성**
   - 우측 상단 **+** (파란색 플러스) 버튼 클릭

3. **Key 정보 입력**
   ```
   Key Name: AI Diary Auth Key
   ```

4. **Sign in with Apple 활성화**
   - ✅ **Sign in with Apple** 체크박스 선택
   - 우측 **Configure** 버튼 클릭

5. **Primary App ID 선택**
   - 드롭다운에서 `com.test.aidiary` 선택
   - **Save** 클릭

6. **Key 등록**
   - **Continue** 클릭
   - 정보 확인 후 **Register** 클릭

7. **⚠️ 매우 중요: Key 다운로드**
   - **Download** 버튼 클릭
   - `AuthKey_XXXXXXXXXX.p8` 파일 다운로드
   - **⚠️ 이 파일은 한 번만 다운로드 가능! 안전한 곳에 보관!**

8. **Key 정보 메모**
   ```
   Key ID: XXXXXXXXXX (10자리)
   Team ID: 9Q26686S8R (우측 상단에 표시)
   ```

9. **완료**
   - **Done** 클릭

---

## 4️⃣ Supabase에 입력할 정보 정리

이제 다음 정보가 준비되었습니다:

### 수집한 정보:
```
Client ID (Services ID): com.test.aidiary.service
Key ID: XXXXXXXXXX (10자리)
Team ID: 9Q26686S8R
Private Key: AuthKey_XXXXXXXXXX.p8 파일 내용
```

### Supabase Dashboard 설정:

1. https://app.supabase.com/project/jihhsiijrxhazbxhoirl/auth/providers 접속

2. **Apple** 섹션 찾기

3. **Enable Apple** 토글 ON

4. 입력 필드:
   
   **Client ID:**
   ```
   com.test.aidiary.service
   ```
   
   **Secret Key:** (JSON 형식으로 입력)
   ```json
   {
     "team_id": "9Q26686S8R",
     "key_id": "XXXXXXXXXX",
     "private_key": "-----BEGIN PRIVATE KEY-----\nMIGTAgEAMB...(p8 파일 내용)...XkEggg==\n-----END PRIVATE KEY-----",
     "client_id": "com.test.aidiary.service"
   }
   ```

5. **Save** 클릭

---

## 📝 체크리스트

- [ ] App ID에서 Sign in with Apple 활성화
- [ ] Services ID 생성 (`com.test.aidiary.service`)
- [ ] Services ID에 Supabase 도메인과 콜백 URL 추가
- [ ] Sign in with Apple Key 생성
- [ ] `.p8` 파일 다운로드 및 안전하게 보관
- [ ] Key ID 메모
- [ ] Team ID 확인
- [ ] Supabase에 Client ID 입력
- [ ] Supabase에 Secret Key (JSON) 입력

---

## 🆘 문제 해결

### "Invalid client_id" 오류
- Services ID가 올바른지 확인
- Services ID ≠ App Bundle ID 확인

### "Invalid redirect_uri" 오류
- Services ID 설정에서 Return URL 확인
- `https://jihhsiijrxhazbxhoirl.supabase.co/auth/v1/callback` 정확히 입력

### "Invalid grant" 오류
- Key ID, Team ID 확인
- `.p8` 파일 내용이 올바른지 확인

---

## 💡 팁

1. **Services ID 네이밍**: 
   - 좋은 예: `com.test.aidiary.service`, `com.test.aidiary.web`
   - 나쁜 예: `com.test.aidiary` (앱 ID와 동일)

2. **.p8 파일 읽기**:
   ```bash
   cat AuthKey_XXXXXXXXXX.p8
   ```
   - 내용을 복사하여 JSON의 `private_key` 필드에 붙여넣기
   - 줄바꿈은 `\n`으로 변환

3. **테스트**:
   - 설정 완료 후 앱에서 Apple 로그인 테스트
   - 실패 시 Supabase 로그 확인

---

완료! 이제 Apple 로그인이 작동해야 합니다. 🎉