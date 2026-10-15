# Pulse

현재 위치 근처에 익명의 짧은 감정 문장을 남기고 지도에서 발견하는 Flutter MVP입니다. Android와 iOS를 대상으로 하며, Mapbox 지도의 좌표 위에 일반 핀 대신 문장 자체가 미세하게 부유하도록 표시됩니다.

## 현재 구현 상태

- 현재 위치 권한 요청 및 현재 위치로 카메라 이동
- Mapbox 다크 지도와 현재 위치 puck
- 지도 좌표에 텍스트 문장 annotation 표시
- 텍스트의 미세한 상하 부유 애니메이션
- `한 문장 남기기` Bottom Sheet와 40자 제한
- `PulseRepository` 인터페이스를 통한 데이터 소스 분리
- Supabase Anonymous Auth
- Supabase RPC 기반 게시글 작성/주변 조회
- 게시글 24시간 만료
- 서버에서 위치를 300~700m 난독화한 뒤 난독화 좌표만 저장
- PostGIS `ST_DWithin` 기반 반경 조회
- RLS 및 RPC 권한 제한

Supabase 환경값을 넣지 않으면 기존 `SamplePulseRepository`로 실행되어 로컬 샘플 데이터를 사용합니다.

## 요구 환경

- Flutter 3.38.1 이상 / Dart 3.10 이상
- Android SDK
- iOS 15 이상, macOS + Xcode
- Mapbox public access token (`pk.`로 시작)
- Supabase 프로젝트

핵심 패키지:

```yaml
mapbox_maps_flutter: ^3.0.0
geolocator: ^14.1.1
supabase_flutter: ^2.10.0
```

## Supabase 설정

1. Supabase 프로젝트를 생성합니다.
2. Authentication 설정에서 Anonymous Sign-ins를 활성화합니다.
3. SQL Editor 또는 Supabase CLI로 다음 migration을 적용합니다.

```text
supabase/migrations/001_initial.sql
```

이 migration은 `posts` 테이블, RLS, 24시간 만료, 위치 난독화 작성 RPC, 주변 게시글 조회 RPC를 생성합니다.

정확한 GPS 좌표는 `posts` 테이블에 저장하지 않습니다. 작성 RPC가 전달받은 좌표를 서버에서 300~700m 이동시킨 후 난독화 좌표만 저장합니다.

## 실행 방법

프로젝트 루트에서:

```bash
flutter pub get
```

Mapbox만 사용해 샘플 모드로 실행:

```bash
flutter run --dart-define=ACCESS_TOKEN=pk.your_public_token
```

Supabase까지 연결해 실행:

```bash
flutter run \
  --dart-define=ACCESS_TOKEN=pk.your_public_token \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

PowerShell 예시:

```powershell
$env:MAPBOX_ACCESS_TOKEN = "pk.your_public_token"
$env:SUPABASE_URL = "https://YOUR_PROJECT.supabase.co"
$env:SUPABASE_ANON_KEY = "YOUR_ANON_KEY"

flutter run `
  --dart-define="ACCESS_TOKEN=$env:MAPBOX_ACCESS_TOKEN" `
  --dart-define="SUPABASE_URL=$env:SUPABASE_URL" `
  --dart-define="SUPABASE_ANON_KEY=$env:SUPABASE_ANON_KEY"
```

`SUPABASE_ANON_KEY`는 모바일 클라이언트용 publishable/anon key만 사용하세요. `service_role` 키는 앱에 넣으면 안 됩니다.

## 권한 설정

- Android: `INTERNET`, `ACCESS_COARSE_LOCATION`, `ACCESS_FINE_LOCATION`
- iOS: `NSLocationWhenInUseUsageDescription`

## 폴더 구조

```text
lib/
├─ app.dart
├─ main.dart
├─ models/
├─ services/
└─ features/map/
   ├─ data/
   │  ├─ sample_pulse_repository.dart
   │  └─ supabase_pulse_repository.dart
   ├─ domain/
   │  └─ pulse_repository.dart
   └─ presentation/

supabase/
└─ migrations/
   └─ 001_initial.sql
```

## 보안 / 개인정보 원칙

- 원본 GPS 좌표를 게시글 레코드에 저장하지 않음
- 글 작성은 authenticated 익명 사용자만 RPC를 통해 가능
- 직접 insert/update/delete 권한은 차단
- 조회는 활성 상태이며 만료되지 않은 글로 제한
- 조회 반경은 서버에서 최대 10km로 제한

현재 콘텐츠 moderation과 rate limit은 아직 구현 전입니다. 욕설·비방·개인정보 필터링은 다음 단계에서 서버 측 검증으로 추가해야 합니다.

## 품질 확인

의존성 설치 후 아래 명령을 실행하세요.

```bash
flutter analyze
flutter test
```
