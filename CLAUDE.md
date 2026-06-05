# VibeCoding 굿즈샵

## 프로젝트 개요
GitHub Pages + Supabase + 토스 페이먼트로 만든 굿즈 판매 웹사이트.
프레임워크 없이 순수 HTML/CSS/JS로 작성됨.

## 인프라 정보

| 항목 | 값 |
|------|---|
| Supabase 프로젝트 | vibecoding-goods |
| Supabase Ref | oyrdgyemgzlgrjppdswb |
| Supabase URL | https://oyrdgyemgzlgrjppdswb.supabase.co |
| GitHub 저장소 | haku174173-cmyk/vibecoding-goods |
| GitHub Pages URL | https://haku174173-cmyk.github.io/vibecoding-goods/ |
| 리전 | 서울 (ap-northeast-2) |

## 관리자 계정

- 이메일: admin@admin.com
- 비밀번호: superadmin
- profiles 테이블에서 is_admin = true 로 설정됨

## 환경 설정 (js/config.js)

```javascript
const SUPABASE_URL = "https://oyrdgyemgzlgrjppdswb.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1...";
const TOSS_CLIENT_KEY = "test_ck_...";  // 토스 개발자 센터에서 발급
```

## 토스 키 발급 방법

1. https://developers.tosspayments.com 접속
2. 회원가입 후 → 내 상점 → API 키
3. 테스트 클라이언트 키를 복사해서 `js/config.js`의 `TOSS_CLIENT_KEY`에 붙여넣기
4. 테스트 시크릿 키는 Supabase에 등록:
   ```bash
   supabase secrets set TOSS_SECRET_KEY=<시크릿키> --project-ref oyrdgyemgzlgrjppdswb
   ```

## 배포 방법

```bash
# 코드 변경 후 GitHub에 push하면 자동 반영
git add .
git commit -m "변경 내용 설명"
git push
```

## 로컬 테스트

```bash
# 아무 정적 서버로 실행 (파이썬 예시)
python3 -m http.server 8080
# 브라우저에서 http://localhost:8080 접속
```

## 주요 파일

| 파일 | 역할 |
|------|------|
| `index.html` | 로그인 여부에 따라 자동 이동 |
| `login.html` | 로그인 / 회원가입 |
| `products.html` | 상품 목록 + 장바구니 + 결제 |
| `payment-success.html` | 결제 성공 처리 |
| `payment-fail.html` | 결제 실패 안내 |
| `my-orders.html` | 내 결제 내역 |
| `admin.html` | 관리자 페이지 |
| `js/config.js` | Supabase/Toss 키 설정 |
| `js/auth.js` | 공통 인증 처리 |
| `css/style.css` | 전체 스타일 |
| `supabase/functions/confirm-payment/index.ts` | 결제 확인 Edge Function |
