-- 상품 테이블
create table products (
  id serial primary key,
  name text not null,
  description text,
  price integer not null,
  image_url text,
  stock integer default 100,
  created_at timestamptz default now()
);

-- 사용자 프로필 (auth.users 확장)
create table profiles (
  id uuid references auth.users on delete cascade primary key,
  is_admin boolean default false,
  created_at timestamptz default now()
);

-- 주문 테이블
create table orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users not null,
  total_amount integer not null,
  status text default 'pending',
  payment_key text,
  order_name text,
  created_at timestamptz default now()
);

-- 주문 상세 테이블
create table order_items (
  id serial primary key,
  order_id uuid references orders on delete cascade,
  product_id integer references products,
  quantity integer not null,
  price integer not null
);

-- ─── is_admin 헬퍼 함수 (RLS 무한재귀 방지용) ───
-- SECURITY DEFINER: RLS를 우회해서 profiles 테이블을 직접 조회
create or replace function public.is_admin()
returns boolean
language sql
security definer
stable
as $$
  select coalesce(
    (select is_admin from public.profiles where id = auth.uid()),
    false
  )
$$;

-- ─── RLS 설정 ───

alter table products enable row level security;
create policy "products_read" on products for select using (true);
create policy "products_admin_write" on products for all using (is_admin());

alter table profiles enable row level security;
create policy "profiles_self" on profiles for all using (id = auth.uid());
create policy "profiles_admin_read" on profiles for select using (is_admin());

alter table orders enable row level security;
create policy "orders_self" on orders for all using (user_id = auth.uid());
create policy "orders_admin" on orders for select using (is_admin());

alter table order_items enable row level security;
create policy "items_owner" on order_items for select
  using (exists (select 1 from orders where id = order_id and user_id = auth.uid()));
create policy "items_admin" on order_items for select using (is_admin());
create policy "items_insert" on order_items for insert
  with check (exists (select 1 from orders where id = order_id and user_id = auth.uid()));

-- ─── 회원가입 시 자동 프로필 생성 트리거 ───
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id)
  values (new.id);
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ─── 샘플 상품 데이터 ───
insert into products (name, description, price, image_url, stock) values
  ('클래식 로고 티셔츠', '소프트 코튼 100% / 남녀공용', 29000, 'https://picsum.photos/seed/tshirt/400/400', 50),
  ('에코백', '튼튼한 캔버스 에코백 / A4 사이즈', 15000, 'https://picsum.photos/seed/ecobag/400/400', 80),
  ('스티커 세트 5종', '방수 코팅 고광택 스티커 세트', 6000, 'https://picsum.photos/seed/sticker/400/400', 200),
  ('머그컵', '전자레인지 사용 가능 / 350ml', 18000, 'https://picsum.photos/seed/mug/400/400', 30),
  ('아크릴 키링', '투명 아크릴 / 양면 인쇄', 8000, 'https://picsum.photos/seed/keyring/400/400', 100);
