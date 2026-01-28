# UI/UX 스타일 가이드

## 📱 Timer Analysis App Style Guide

이 문서는 Timer Analysis 앱의 디자인 시스템과 UI/UX 가이드라인을 설명합니다.

---

## 🎨 색상 팔레트

### Primary Colors (주요 색상)
| 이름 | Hex | 용도 |
|------|-----|------|
| Primary | `#FFB7B7` | 주요 액센트, 버튼, 아이콘 |
| Primary Light | `#FFE2E2` | 배경 강조, 보조 버튼 |
| Primary Dark | `#E89999` | 눌림 상태 |

### Background & Surface (배경)
| 이름 | Hex | 용도 |
|------|-----|------|
| Background | `#FFFBFA` | 페이지 배경 |
| Surface | `#FFFFFF` | 카드, 다이얼로그 |
| Surface Variant | `#FFF5F5` | 입력 필드 배경 |

### Text (텍스트)
| 이름 | Hex | 용도 |
|------|-----|------|
| Text Primary | `#3D3D3D` | 본문 텍스트 |
| Text Secondary | `#8B8B8B` | 보조 텍스트 |
| Text Tertiary | `#B5B5B5` | 힌트 텍스트 |
| Text On Primary | `#FFFFFF` | 컬러 버튼 위 텍스트 |

### Accent Colors (강조 색상)
| 이름 | Hex | 용도 |
|------|-----|------|
| Mint | `#B9EEE0` | 성공, 완료, 랩타임 |
| Sky | `#D4EDFC` | 정보, 수정 |
| Lavender | `#E8DCFF` | 통계, 분석 |
| Lemon | `#FFF5C3` | 최고 기록, 하이라이트 |

### Semantic Colors (의미적 색상)
| 이름 | Hex | 용도 |
|------|-----|------|
| Success | `#6BD9A1` | 완료, 체크 |
| Warning | `#FFBE6A` | 경고, 느린 문항 |
| Error | `#FF8989` | 삭제, 오류 |

---

## 📝 타이포그래피

### Display (대형)
```dart
displayLarge: 72px, Bold, -2 letter-spacing  // 타이머 숫자
displayMedium: 48px, Bold, -1 letter-spacing
```

### Headings (제목)
```dart
headlineLarge: 24px, Bold     // 페이지 제목
headlineMedium: 20px, SemiBold // 섹션 제목
headlineSmall: 18px, SemiBold  // 카드 제목
```

### Body (본문)
```dart
bodyLarge: 16px, Regular     // 주요 본문
bodyMedium: 14px, Regular    // 보조 본문
bodySmall: 13px, Regular     // 작은 본문
```

### Labels (라벨)
```dart
labelLarge: 14px, SemiBold   // 버튼, 강조 라벨
labelMedium: 13px, SemiBold  // 배지, 태그
caption: 12px, Regular       // 캡션, 메타데이터
```

---

## 📐 간격 (Spacing)

| 토큰 | 값 | 용도 |
|------|-----|------|
| xs | 4px | 인라인 간격 |
| sm | 8px | 작은 간격 |
| md | 12px | 중간 간격 |
| lg | 16px | 기본 간격 |
| xl | 20px | 넓은 간격 |
| xxl | 24px | 섹션 간격 |
| xxxl | 32px | 큰 섹션 간격 |

### 표준 패딩
- **페이지**: horizontal 20px, vertical 16px
- **카드**: all 16px (large: all 20px)
- **다이얼로그**: horizontal 24px, vertical 20px
- **리스트 아이템**: horizontal 16px, vertical 12px

---

## 🔘 Border Radius

| 토큰 | 값 | 용도 |
|------|-----|------|
| xs | 8px | 칩, 배지 |
| sm | 12px | 버튼, 작은 카드 |
| md | 16px | 입력 필드, 리스트 아이템 |
| lg | 20px | 카드, 컨테이너 |
| xl | 24px | 다이얼로그 |
| xxl | 28px | 바텀 시트 |
| full | 100px | 원형 버튼, 필 형태 |

---

## 🌗 그림자 (Shadows)

### Subtle
```dart
color: black 3% opacity
blurRadius: 8px
offset: (0, 2)
```
용도: 카드, 리스트 아이템

### Medium
```dart
color: black 6% opacity
blurRadius: 16px
offset: (0, 4)
```
용도: 타이머 디스플레이, 떠있는 요소

### Colored
```dart
color: accent color 25% opacity
blurRadius: 16px
offset: (0, 6)
```
용도: 아이콘 버튼, FAB

---

## 📦 컴포넌트 목록

### 버튼
| 컴포넌트 | 설명 |
|---------|------|
| `AppButton` | Primary/Secondary/Text/Danger 변형 |
| `AppIconButton` | 원형 아이콘 버튼 (타이머 컨트롤) |

### 카드
| 컴포넌트 | 설명 |
|---------|------|
| `AppCard` | 기본 카드 (elevated/outlined/filled) |
| `SubjectCard` | 과목 리스트용 카드 |
| `StatCard` | 통계 표시 카드 |
| `ExamHistoryCard` | 시험 기록 카드 (스와이프 삭제) |

### 다이얼로그 & 시트
| 컴포넌트 | 설명 |
|---------|------|
| `AppDialog` | 표준 확인 다이얼로그 |
| `AppInputDialog` | 텍스트 입력 다이얼로그 |
| `AppBottomSheet` | 표준 바텀 시트 |
| `AppMenuBottomSheet` | 메뉴 옵션 바텀 시트 |

### 기타
| 컴포넌트 | 설명 |
|---------|------|
| `AppEmptyState` | 빈 상태 표시 |

---

## 📱 모바일 우선 가이드라인

### 터치 타겟
- 최소 터치 타겟: **48dp**
- 버튼 높이: **52dp** (small: 44dp)

### 한 손 사용 최적화
1. **하단 배치**: 주요 액션 버튼은 화면 하단에
2. **중앙 FAB**: "시험 시작" 같은 주요 액션은 중앙 하단
3. **스와이프 제스처**: 롱프레스 대신 스와이프로 삭제
4. **전체 화면 탭**: 타이머 실행 중 화면 전체를 탭하면 랩 기록

### 탭 수 줄이기
| 액션 | 이전 | 개선 |
|------|------|------|
| 과목 추가 | FAB 탭 → 입력 | 앱바 버튼 또는 FAB → 입력 |
| 랩 기록 | 버튼 찾기 → 탭 | 화면 아무데나 탭 |
| 삭제 | 롱프레스 → 메뉴 → 삭제 | 스와이프 → 완료 |

---

## 🐰 귀여움 유지하기

### 미묘한 요소들
1. **둥근 모서리**: 모든 요소에 일관된 radius 적용
3. **파스텔 팔레트**: 따뜻하고 친근한 색상
4. **친근한 문구**: 
   - "아직 과목이 없어요" ✓
   - "과목 없음" ✗
5. **이모지 사용** (적절히):
   - 빈 상태: 💪, ✨
   - 성공 메시지: 🎉

### 피해야 할 것
- 과도한 장식
- 너무 많은 색상 사용
- 복잡한 애니메이션
- 밀도 높은 정보 배치

---

## 📁 파일 구조

```
lib/
├── components/         # 재사용 컴포넌트
│   ├── app_button.dart
│   ├── app_card.dart
│   ├── app_dialog.dart
│   ├── app_bottom_sheet.dart
│   ├── app_empty_state.dart
│   └── components.dart (barrel export)
├── utils/
│   ├── design_tokens.dart  # 디자인 토큰 (핵심)
│   ├── app_theme.dart      # ThemeData 설정
│   └── app_colors.dart     # (레거시, design_tokens 재export)
└── pages/
    ├── subjects/
    ├── subject_detail/
    └── timer/
```

---

## ✅ 체크리스트

새로운 UI 요소 추가 시:

- [ ] `design_tokens.dart`의 색상 사용
- [ ] `design_tokens.dart`의 spacing 사용
- [ ] `design_tokens.dart`의 radius 사용
- [ ] 재사용 컴포넌트 사용 (AppButton, AppCard 등)
- [ ] 최소 48dp 터치 타겟 확보
- [ ] 한 손 사용 가능한 배치
- [ ] 친근한 문구 사용
- [ ] 빈 상태 처리
