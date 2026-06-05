# 아키텍처 문서

## 전체 구조

```
사용자 브라우저
    │
    ├── GitHub Pages (정적 파일 호스팅)
    │       index.html, login.html, products.html,
    │       my-orders.html, admin.html, css/, js/
    │
    ├── Supabase (백엔드)
    │       ├── Auth: 회원가입/로그인 (이메일 인증 없음)
    │       ├── Database: products, profiles, orders, order_items
    │       └── Edge Functions: confirm-payment
    │
    └── 토스 페이먼트 (결제창)
            테스트 모드로 동작
```

## 결제 흐름

```
1. 사용자가 상품을 장바구니에 담고 "결제하기" 클릭
   │
2. Supabase DB에 orders 레코드 생성 (status: "pending")
   │
3. 토스 결제창 실행 (TossPayments SDK)
   │
4. 사용자가 카드 정보 입력 및 결제
   │
5. 토스가 payment-success.html로 리다이렉트
   (URL에 paymentKey, orderId, amount 포함)
   │
6. payment-success.html → Supabase Edge Function 호출
   │
7. Edge Function → 토스 API로 결제 최종 확인
   │
8. 확인 완료 → orders 테이블 status를 "paid"로 업데이트
   │
9. 사용자에게 완료 화면 표시
```

## 데이터베이스 스키마

### products (상품)
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | serial | 고유 번호 |
| name | text | 상품명 |
| description | text | 설명 |
| price | integer | 가격 (원화) |
| image_url | text | 이미지 URL |
| stock | integer | 재고 수량 |
| created_at | timestamptz | 생성일시 |

### profiles (사용자 프로필)
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | uuid | auth.users와 연결 |
| is_admin | boolean | 관리자 여부 |
| created_at | timestamptz | 생성일시 |

> 회원가입 시 트리거로 자동 생성됨

### orders (주문)
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | uuid | 고유 주문 ID (토스 orderId로도 사용) |
| user_id | uuid | 주문한 사용자 ID |
| total_amount | integer | 총 결제 금액 |
| status | text | pending / paid / failed |
| payment_key | text | 토스 결제 키 (결제 후 저장) |
| order_name | text | 주문 상품명 요약 |
| created_at | timestamptz | 주문일시 |

### order_items (주문 상세)
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | serial | 고유 번호 |
| order_id | uuid | 연결된 주문 ID |
| product_id | integer | 연결된 상품 ID |
| quantity | integer | 수량 |
| price | integer | 주문 시점 단가 (스냅샷) |

## RLS (Row Level Security) 정책

| 테이블 | 읽기 | 쓰기 |
|--------|------|------|
| products | 모두 | admin만 |
| profiles | 본인만 / admin은 전체 | 본인만 |
| orders | 본인만 / admin은 전체 | 본인만 |
| order_items | 해당 주문 소유자 / admin | 본인 주문에만 |

## Edge Function: confirm-payment

위치: `supabase/functions/confirm-payment/index.ts`

**역할:** 결제 성공 후 토스 API에 최종 결제 확인 요청을 보내는 서버 역할.
GitHub Pages는 서버가 없기 때문에, 토스 시크릿 키가 필요한 이 작업을 Edge Function이 대신 처리함.

**환경 변수 (Supabase secrets):**
- `TOSS_SECRET_KEY`: 토스 테스트 시크릿 키
- `SUPABASE_URL`: 자동 주입
- `SUPABASE_SERVICE_ROLE_KEY`: 자동 주입

## 인증 흐름

```
1. supabase.auth.signUp() 또는 signInWithPassword()
2. 성공 시 session이 브라우저 localStorage에 저장됨
3. 각 페이지에서 requireLogin() 함수로 session 확인
4. session이 없으면 login.html로 자동 이동
5. 관리자 페이지는 requireAdmin()으로 is_admin 추가 확인
```
