# 🔐 Keystore 백업 가이드

**⚠️ 매우 중요: 이 파일을 잃어버리면 앱을 업데이트할 수 없습니다!**

## 📍 Keystore 정보

### 파일 위치
- **원본**: `/Users/seungbeenwi/aidiary-release.keystore`
- **로컬 백업**: `~/Documents/AI-Diary-Backups/aidiary-release-20250815-144447.keystore`

### Keystore 정보
```
Alias: aidiary
유효기간: 27년 (2052년까지)
생성일: 2025년 1월 15일
크기: 2,746 bytes
```

### 비밀번호 정보
```
Store Password: aidiary2025prod
Key Password: aidiary2025prod
Key Alias: aidiary
```

## 🔄 백업 방법

### 1. Google Drive 백업 (권장)
```bash
# Google Drive 데스크톱 앱이 설치되어 있다면
cp /Users/seungbeenwi/aidiary-release.keystore ~/Google\ Drive/My\ Drive/AI-Diary-Backup/

# 또는 웹에서 직접 업로드
# 1. drive.google.com 접속
# 2. 새 폴더 생성: "AI-Diary-Keystore-Backup"
# 3. 파일 업로드: aidiary-release.keystore
```

### 2. iCloud Drive 백업
```bash
cp /Users/seungbeenwi/aidiary-release.keystore ~/Library/Mobile\ Documents/com~apple~CloudDocs/AI-Diary-Backup/
```

### 3. USB/외장하드 백업
```bash
# USB가 마운트되었을 때
cp /Users/seungbeenwi/aidiary-release.keystore /Volumes/USB_NAME/AI-Diary-Backup/
```

### 4. 비밀번호 매니저 백업
1. 1Password, Bitwarden, 또는 사용 중인 비밀번호 매니저 열기
2. 새 항목 생성: "AI 감성 일기 Keystore"
3. 파일 첨부: `aidiary-release.keystore`
4. 비밀번호 저장:
   - Store Password: aidiary2025prod
   - Key Password: aidiary2025prod
   - Alias: aidiary

### 5. 암호화된 ZIP 백업
```bash
# 암호화된 ZIP 생성
cd /Users/seungbeenwi
zip -e aidiary-keystore-backup.zip aidiary-release.keystore

# 비밀번호 입력 (두 번)
# 생성된 ZIP을 안전한 곳에 보관
```

## 🔍 백업 확인 명령어

### Keystore 정보 확인
```bash
keytool -list -v -keystore /Users/seungbeenwi/aidiary-release.keystore -storepass aidiary2025prod
```

### SHA-1 지문 확인
```bash
keytool -list -v -keystore /Users/seungbeenwi/aidiary-release.keystore -alias aidiary -storepass aidiary2025prod | grep SHA1
```

## 🚨 복구 시나리오

### Keystore 복구가 필요한 경우
1. 백업된 파일을 원래 위치로 복사
```bash
cp ~/Documents/AI-Diary-Backups/aidiary-release-*.keystore /Users/seungbeenwi/aidiary-release.keystore
```

2. android/key.properties 파일 확인
```properties
storePassword=aidiary2025prod
keyPassword=aidiary2025prod
keyAlias=aidiary
storeFile=/Users/seungbeenwi/aidiary-release.keystore
```

3. 빌드 테스트
```bash
flutter build appbundle --release
```

## 📋 백업 체크리스트

- [x] 로컬 백업 (Documents 폴더)
- [ ] Google Drive 백업
- [ ] iCloud Drive 백업
- [ ] USB/외장하드 백업
- [ ] 비밀번호 매니저 백업
- [ ] 팀원/파트너와 공유 (필요시)

## ⚠️ 보안 주의사항

1. **절대 GitHub에 업로드하지 마세요**
2. **공개 클라우드에 업로드하지 마세요**
3. **이메일로 전송하지 마세요**
4. **최소 3곳 이상 백업하세요**
5. **백업 위치를 문서화하세요**

## 📱 Play Store 출시 후

Play Store에 앱이 출시되면:
1. Google Play App Signing 활성화 고려
2. 업로드 키와 앱 서명 키 분리
3. Google이 앱 서명 키 관리

---

**마지막 백업 확인**: 2025년 1월 15일  
**다음 백업 예정**: 출시 전 최종 백업