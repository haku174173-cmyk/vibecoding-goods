const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

async function requireLogin() {
  const { data: { session } } = await supabase.auth.getSession();
  if (!session) {
    window.location.href = "login.html";
    return null;
  }
  return session;
}

async function requireAdmin() {
  const session = await requireLogin();
  if (!session) return null;

  const { data: profile } = await supabase
    .from("profiles")
    .select("is_admin")
    .eq("id", session.user.id)
    .single();

  if (!profile?.is_admin) {
    alert("관리자만 접근할 수 있습니다.");
    window.location.href = "products.html";
    return null;
  }
  return session;
}

async function logout() {
  await supabase.auth.signOut();
  window.location.href = "login.html";
}

function renderNav(session, isAdmin) {
  const nav = document.getElementById("nav");
  if (!nav) return;
  if (session) {
    nav.innerHTML = `
      <a href="products.html">상품</a>
      <a href="my-orders.html">내 결제내역</a>
      ${isAdmin ? '<a href="admin.html">관리자</a>' : ""}
      <span style="color:#999;font-size:14px">${session.user.email}</span>
      <button onclick="logout()">로그아웃</button>
    `;
  } else {
    nav.innerHTML = `<a href="login.html">로그인</a>`;
  }
}
