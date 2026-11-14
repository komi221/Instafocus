# InstaDM (인스타 DM 전용 앱)

DM 화면만 여는 네이티브(SwiftUI + WKWebView) 앱입니다.
- 홈/릴스/탐색 이동 차단, 시작 화면은 DM 받은편지함
- 릴스 → "릴스를 보냈습니다." 텍스트
- 영상 → "동영상을 보냈습니다." 텍스트
- 내가 보낸 사진은 숨기고 상대가 보낸 사진만 표시

## IPA 만들기 (Mac 없이)
1. GitHub에 새 저장소를 만들고 이 폴더 내용을 그대로 업로드(.github 폴더 포함)
2. Actions 탭 → "Build IPA" → Run workflow
3. 끝나면 Artifacts의 InstaDM-ipa 다운로드 (서명 안 된 IPA)
4. LiveContainer / AltStore / Sideloadly 등으로 설치

번들 ID는 project.yml의 PRODUCT_BUNDLE_IDENTIFIER에서 바꿀 수 있어요.
