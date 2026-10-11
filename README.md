# Pulse

현재 위치 근처에 익명의 짧은 감정 문장을 남기고 지도에서 발견하는 Flutter MVP입니다. Android와 iOS를 대상으로 하며, Mapbox 지도의 좌표 위에 일반 핀 대신 문장 자체가 미세하게 부유하도록 표시됩니다.

## 이번 MVP에 포함된 기능

- 현재 위치 권한 요청 및 현재 위치로 카메라 이동
- 위치 권한 거부/서비스 비활성화 시 서울 중심 좌표로 안전하게 폴백
- Mapbox 다크 지도와 현재 위치 puck
- 지도 좌표에 고정된 텍스트 문장 annotation
- 텍스트의 미세한 상하 부유 애니메이션
- 샘플 문장 6개
- `한 문장 남기기` Bottom Sheet와 40자 제한
- 작성 직후 세션 내 지도 반영
- Mapbox 토큰 누락 시 설정 안내 화면
- 데이터 저장소 인터페이스 분리 (추후 Supabase 교체 가능)

> 현재 작성 데이터는 메모리에만 저장되므로 앱을 다시 시작하면 사라집니다. 위치 오프셋, 24시간 만료, 콘텐츠 필터도 다음 단계에서 서버 정책과 함께 적용해야 합니다.

## 요구 환경

- Flutter 3.38.1 이상 / Dart 3.10 이상
- Android SDK (minSdk는 Flutter 기본값 사용)
- iOS 15 이상, macOS + Xcode
- Mapbox public access token (`pk.`로 시작)

이 프로젝트에서 사용한 핵심 패키지:

```yaml
mapbox_maps_flutter: ^3.0.0
geolocator: ^14.1.1
```

## 실행 방법

1. [Mapbox Access Tokens](https://account.mapbox.com/access-tokens/)에서 public token을 준비합니다.
2. 프로젝트 루트에서 패키지를 설치합니다.

```bash
flutter pub get
```

3. 연결한 Android 기기/에뮬레이터 또는 iOS Simulator에서 실행합니다. 토큰은 저장소에 커밋하지 않고 빌드 시 주입합니다.

```bash
flutter run --dart-define=ACCESS_TOKEN=pk.your_public_token
```

PowerShell 환경 변수를 사용한다면:

```powershell
$env:MAPBOX_ACCESS_TOKEN = "pk.your_public_token"
flutter run --dart-define="ACCESS_TOKEN=$env:MAPBOX_ACCESS_TOKEN"
```

Android 빌드:

```bash
flutter build apk --dart-define=ACCESS_TOKEN=pk.your_public_token
```

iOS 빌드(macOS 필요):

```bash
flutter build ios --dart-define=ACCESS_TOKEN=pk.your_public_token
```

## 권한 설정

이미 프로젝트에 다음 항목이 반영되어 있습니다.

- Android: `INTERNET`, `ACCESS_COARSE_LOCATION`, `ACCESS_FINE_LOCATION`
- iOS: `NSLocationWhenInUseUsageDescription`

실기기에서 위치 권한을 영구 거부한 경우 OS 설정에서 Pulse의 위치 권한을 다시 허용해야 합니다.

## 폴더 구조

```text
lib/
├─ app.dart
├─ main.dart
├─ models/
│  ├─ geo_point.dart
│  └─ pulse_post.dart
├─ services/
│  └─ location_service.dart
└─ features/map/
   ├─ data/
   │  └─ sample_pulse_repository.dart
   ├─ domain/
   │  └─ pulse_repository.dart
   └─ presentation/
      ├─ map_controller.dart
      ├─ map_page.dart
      └─ widgets/
```

`PulseRepository`가 지도 화면과 데이터 소스를 분리합니다. Supabase 연결 시 `SupabasePulseRepository`를 추가하고 `app.dart`의 주입 대상만 바꾸면 됩니다.

## 다음 단계: Supabase 설계 포인트

- Supabase Anonymous Sign-ins로 익명 사용자 식별
- `posts` 테이블에 `content`, 난독화한 좌표, `created_at`, `expires_at` 저장
- DB 함수 또는 Edge Function에서 실제 좌표에 임의 오프셋 적용
- PostGIS `ST_DWithin` 기반 주변 3km 조회
- `expires_at > now()` RLS/조회 조건과 정리 스케줄 적용
- 제출 전 클라이언트 기본 검사 + 서버 측 욕설·비방·개인정보 필터
- 생성/조회 API 모두 rate limit 및 RLS 적용

정확한 원본 위치는 게시글 레코드에 저장하지 않는 방식이 안전합니다. 오프셋과 필터는 클라이언트만 신뢰하지 말고 반드시 서버에서 다시 적용해야 합니다.

## 품질 확인

```bash
flutter analyze
flutter test
```
