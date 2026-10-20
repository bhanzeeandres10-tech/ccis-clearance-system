/* Direct-file edition of CCIS CLEARANCE.
 * It mirrors the Flutter presentation flow for classroom review when the
 * generated index.html is opened from a folder (file://), where browsers do
 * not allow the Flutter engine to load. Hosted and installed versions remain
 * the Flutter application. */
(() => {
  const state = {
    role: 'Student',
    signedIn: false,
    page: 'Home',
    dark: true,
    attendance: 3,
    verified: false,
    approved: false,
    personnel: [
      { name: 'Nina R. Dela Cruz', status: 'Active' },
      { name: 'Marco L. Villanueva', status: 'Active' },
      { name: 'Rhea T. Morales', status: 'Inactive' },
    ],
    notices: [
      ['Day 2 checkout is missing', 'Hinampang afternoon Time Out has no record.'],
      ['3 deficiencies need attention', 'Review the missing attendance, fine, and CCIS document.'],
      ['Buwan ng Wika is awaiting review', 'All checkpoints are recorded; verification is pending.'],
    ],
  };

  const escape = (value) => String(value).replace(/[&<>'"]/g, (char) => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', "'": '&#39;', '"': '&quot;'
  }[char]));
  const rolePages = {
    Student: ['Home', 'Clearance', 'Updates', 'Profile'],
    Personnel: ['Home', 'Students', 'Records', 'Updates'],
    Admin: ['Home', 'Personnel', 'Audit'],
  };

  function shell(content) {
    const nav = rolePages[state.role].map((item) =>
      `<button class="nav ${state.page === item ? 'selected' : ''}" data-page="${item}"><span>${navIcon(item)}</span>${item}</button>`
    ).join('');
    return `<main class="app-shell">
      <header class="topbar"><div class="brand"><b>CC</b><div><strong>CCIS CLEARANCE</strong><small>RMMC-MI · CCIS student services</small></div></div>
      <div class="top-actions"><span class="role">${state.role}</span><button class="icon" data-action="theme" aria-label="Switch theme">${state.dark ? '☀' : '☾'}</button><button class="signout" data-action="signout">Sign out</button></div></header>
      <section class="page">${content}</section>
      <nav class="bottom-nav">${nav}</nav>
    </main>`;
  }

  function navIcon(item) {
    return ({ Home: '⌂', Clearance: '▣', Updates: '♧', Profile: '♙', Students: '♙', Records: '▣', Personnel: '♙', Audit: '◷' }[item] || '•');
  }

  function stat(value, label, tone = '') {
    return `<article class="metric ${tone}"><b>${value}</b><span>${label}</span></article>`;
  }

  function studentHome() {
    return `<p class="eyebrow">RMMC-MI / CCIS</p><h1>Good morning, Mariel.</h1><p class="sub">Keep track of your CCIS clearance in one place.</p>
      <section class="progress-card"><div><b>CCIS clearance</b><span>${state.approved ? 'Approved' : 'In progress'}</span></div><strong>${state.approved ? '100' : state.verified ? '60' : '40'}%</strong><div class="progress"><i style="width:${state.approved ? 100 : state.verified ? 60 : 40}%"></i></div><small>${state.approved ? 'All requirements cleared' : state.verified ? '3 of 5 requirements verified' : '2 of 5 requirements verified'}</small></section>
      ${state.approved ? `<div class="success-note">✓ Your CCIS clearance has been approved.</div>` : `<div class="notice warning"><b>2 open deficiencies</b><br>CCIS records still need attention before final clearance approval.</div>`}
      <div class="section-row"><h2>Latest update</h2><button data-page="Updates">View all</button></div>
      <article class="update"><b>${state.notices[0][0]}</b><p>${state.notices[0][1]}</p><small>18 Sep 2026 · 08:35 AM</small></article>
      <div class="section-row"><h2>Your event requirements</h2><button data-page="Clearance">View all</button></div>
      ${eventTile('Abre Klase', '4/4 checkpoints · verified', 'Verified')}${eventTile('Buwan ng Wika', '4/4 checkpoints · awaiting review', state.verified ? 'Verified' : 'Pending')}${eventTile('Hinampang', '2/4 days satisfied · attendance pending', 'In progress')}`;
  }

  function eventTile(title, detail, status) {
    return `<button class="event" data-page="Clearance"><span class="event-icon">▣</span><span><b>${title}</b><small>${detail}</small></span><em class="pill ${status.toLowerCase().replace(' ', '-')}">${status}</em><span>›</span></button>`;
  }

  function studentClearance() {
    return `<p class="eyebrow">CCIS STUDENT SERVICES</p><h1>Clearance overview</h1><p class="sub">Your attendance, requirements, and status.</p>
      <section class="progress-card"><div><b>CCIS clearance</b><span>In progress</span></div><strong>${state.verified ? '60' : '40'}%</strong><div class="progress"><i style="width:${state.verified ? 60 : 40}%"></i></div><small>${state.verified ? '3' : '2'} of 5 requirements verified</small></section>
      <div class="section-row"><h2>Event requirements</h2></div>${eventTile('Abre Klase', 'Attendance complete · 4/4 recorded', 'Verified')}${eventTile('Buwan ng Wika', 'Attendance complete · 4/4 recorded', state.verified ? 'Verified' : 'Pending')}${eventTile('Hinampang', 'Day 2 checkout needs attention', 'In progress')}
      <div class="notice"><b>What happens next?</b><br>CCIS personnel verify completed events and resolve any remaining deficiencies.</div>`;
  }

  function personnelHome() {
    return `<p class="eyebrow">AUTHORIZED CCIS PERSONNEL</p><h1>Good morning, Nina.</h1><p class="sub">Review attendance, deficiencies, and final clearance records.</p>
      <button class="primary" data-page="Students">⌕ Find a student</button>
      <section class="metrics">${stat('18', 'Pending attendance review', 'blue')}${stat('9', 'Open deficiencies', 'amber')}${stat('42', 'CCIS approved', 'green')}</section>
      <div class="section-row"><h2>Priority queue</h2><button data-page="Students">View students</button></div>
      ${studentTile('Mariel A. Santos', '3 open deficiencies · 2/5 verified', 'Deficient')}${studentTile('Adrian M. Reyes', '3/3 verified · ready for final review', 'Complete')}${studentTile('Leah P. Mendoza', 'CCIS clearance approved', 'Approved')}`;
  }

  function studentTile(name, detail, status) {
    return `<button class="student" data-page="Records"><span class="avatar">${name.split(' ').map(x => x[0]).slice(0, 2).join('')}</span><span><b>${name}</b><small>${detail}</small></span><em class="pill ${status.toLowerCase()}">${status}</em><span>›</span></button>`;
  }

  function studentsPage() {
    return `<p class="eyebrow">AUTHORIZED CCIS PERSONNEL</p><h1>Student search</h1><p class="sub">Find a CCIS student to review attendance and clearance status.</p><input id="student-search" placeholder="Search name or student number"><div class="chip-row"><span>All programs</span><span>1st sem 2026–27</span></div><div class="section-row"><h2>Student records</h2><small>3 students</small></div>${studentTile('Mariel A. Santos', '2023-01428 · BSIT 3A · 3 open deficiencies', 'Deficient')}${studentTile('Adrian M. Reyes', '2022-00816 · BSCS 4A · ready for review', 'Complete')}${studentTile('Leah P. Mendoza', '2023-01107 · BSIT 3B · clearance approved', 'Approved')}`;
  }

  function recordsPage() {
    const done = state.attendance === 4;
    return `<p class="eyebrow">AUTHORIZED CCIS PERSONNEL</p><h1>Student clearance record</h1><p class="sub">Mariel A. Santos · 2023-01428 · BSIT 3A</p>
      <section class="progress-card"><div><b>CCIS clearance</b><span>${state.approved ? 'Approved' : 'In progress'}</span></div><strong>${state.approved ? '100' : state.verified ? '60' : '40'}%</strong><div class="progress"><i style="width:${state.approved ? 100 : state.verified ? 60 : 40}%"></i></div><small>${state.verified ? '3 of 5 requirements verified' : '2 of 5 requirements verified'}</small></section>
      <div class="section-row"><h2>Attendance review</h2><button data-action="attendance">Record checkpoint</button></div><article class="update"><b>Buwan ng Wika</b><p>${state.attendance}/4 checkpoints recorded. ${done ? 'Ready for verification.' : 'Afternoon Time Out is missing.'}</p><button class="primary small" data-action="attendance">${done ? 'Attendance complete' : 'Record next checkpoint'}</button></article>
      <div class="section-row"><h2>Requirement review</h2></div><article class="update"><b>Buwan ng Wika verification</b><p>${done ? 'All checkpoints are recorded and can be verified.' : 'All four attendance checkpoints are required.'}</p><button class="primary small" data-action="verify" ${done ? '' : 'disabled'}>${state.verified ? 'Requirement verified' : 'Verify requirement'}</button></article>
      <article class="update"><b>Final approval</b><p>${state.verified ? 'Verification complete. You may approve clearance for this presentation.' : 'Verify requirements and resolve deficiencies first.'}</p><button class="primary small" data-action="approve" ${state.verified ? '' : 'disabled'}>${state.approved ? 'Clearance approved' : 'Approve clearance'}</button></article>`;
  }

  function updatesPage() {
    return `<p class="eyebrow">CCIS CLEARANCE ACTIVITY</p><h1>Updates</h1><p class="sub">Your latest clearance notifications.</p>${state.notices.map(([title, detail]) => `<article class="update"><b>${title}</b><p>${detail}</p><small>Today · CCIS clearance</small></article>`).join('')}`;
  }

  function profilePage() {
    return `<p class="eyebrow">CCIS STUDENT SERVICES</p><h1>Student profile</h1><p class="sub">Account and academic information.</p><article class="profile"><span class="avatar">MS</span><div><b>Mariel A. Santos</b><small>2023-01428 · BSIT 3A</small></div></article><h2>Academic information</h2><dl><dt>Program</dt><dd>BS Information Technology</dd><dt>Year / section</dt><dd>3rd year · BSIT 3A</dd><dt>Department</dt><dd>College of Computing and Information Sciences</dd></dl><button class="outline" data-action="signout">Sign out</button>`;
  }

  function adminHome() {
    return `<p class="eyebrow">SYSTEM ADMINISTRATION</p><h1>Administration dashboard</h1><p class="sub">Manage authorized personnel and review protected system activity.</p><section class="metrics">${stat(state.personnel.filter(p => p.status === 'Active').length, 'Active personnel', 'green')}${stat(state.personnel.filter(p => p.status !== 'Active').length, 'Inactive accounts', 'amber')}${stat('12', 'Audit entries today', 'blue')}</section><div class="section-row"><h2>Administration tools</h2></div><button class="action-card" data-page="Personnel"><b>Manage personnel</b><small>Create accounts and set staff access.</small><span>›</span></button><button class="action-card" data-page="Audit"><b>Audit log</b><small>Review sign-in and update activity.</small><span>›</span></button>`;
  }

  function personnelPage() {
    return `<p class="eyebrow">SYSTEM ADMINISTRATION</p><h1>Manage personnel</h1><p class="sub">Create and activate authorized CCIS personnel.</p><button class="primary" data-action="add-person">＋ Add personnel</button><div class="section-row"><h2>Authorized personnel</h2><small>${state.personnel.length} accounts</small></div>${state.personnel.map((person, index) => `<article class="person"><span class="avatar">${person.name.split(' ').map(x => x[0]).slice(0, 2).join('')}</span><span><b>${person.name}</b><small>CCIS personnel · ${person.status}</small></span><button class="outline small" data-action="toggle-person" data-index="${index}">${person.status === 'Active' ? 'Deactivate' : 'Activate'}</button></article>`).join('')}`;
  }

  function auditPage() {
    return `<p class="eyebrow">SYSTEM ADMINISTRATION</p><h1>Audit log</h1><p class="sub">Protected records of demo account activity.</p>${[['Login', 'Student signed in to CCIS CLEARANCE demo.'], ['Attendance update', 'Personnel recorded a Buwan ng Wika checkpoint.'], ['Requirement verification', 'CCIS event requirement marked verified.'], ['Personnel management', 'Administrator reviewed account status.']].map(([action, detail]) => `<article class="update"><b>${action}</b><p>${detail}</p><small>Today · system audit</small></article>`).join('')}`;
  }

  function pageContent() {
    if (!state.signedIn) return login();
    if (state.role === 'Student') return ({ Home: studentHome, Clearance: studentClearance, Updates: updatesPage, Profile: profilePage }[state.page] || studentHome)();
    if (state.role === 'Personnel') return ({ Home: personnelHome, Students: studentsPage, Records: recordsPage, Updates: updatesPage }[state.page] || personnelHome)();
    return ({ Home: adminHome, Personnel: personnelPage, Audit: auditPage }[state.page] || adminHome)();
  }

  function login() {
    return `<main class="login"><section class="login-card"><div class="brand center"><b>CC</b><div><strong>CCIS CLEARANCE</strong><small>RMMC-MI · CCIS student services</small></div></div><button class="icon login-theme" data-action="theme">${state.dark ? '☀' : '☾'}</button><h1>Welcome back</h1><p class="sub">Sign in to access your CCIS clearance.</p><label>CONTINUE AS</label><div class="roles">${['Admin', 'Personnel', 'Student'].map(role => `<button class="${state.role === role ? 'selected' : ''}" data-role="${role}">${role}</button>`).join('')}</div><label>Username</label><input id="username" placeholder="Enter your username"><label>Password</label><input id="password" type="password" placeholder="Enter your password"><button class="primary login-button" data-action="login">Sign in as ${state.role}</button><div class="notice">ⓘ Demo access: choose a role, then enter any username and password.</div></section></main>`;
  }

  function render() {
    document.documentElement.dataset.theme = state.dark ? 'dark' : 'light';
    document.body.innerHTML = state.signedIn ? shell(pageContent()) : pageContent();
    bind();
  }

  function bind() {
    document.querySelectorAll('[data-page]').forEach(button => button.addEventListener('click', () => { state.page = button.dataset.page; render(); }));
    document.querySelectorAll('[data-role]').forEach(button => button.addEventListener('click', () => { state.role = button.dataset.role; render(); }));
    document.querySelectorAll('[data-action]').forEach(button => button.addEventListener('click', () => handle(button.dataset.action, button.dataset.index)));
  }

  function handle(action, index) {
    if (action === 'theme') {
      document.documentElement.classList.remove('theme-transition');
      // Restart the visual sweep even when the switch is pressed repeatedly.
      void document.documentElement.offsetWidth;
      document.documentElement.classList.add('theme-transition');
      window.setTimeout(() => {
        document.documentElement.classList.remove('theme-transition');
      }, 620);
      state.dark = !state.dark;
    }
    if (action === 'signout') { state.signedIn = false; state.page = 'Home'; }
    if (action === 'login') {
      const username = document.querySelector('#username').value.trim();
      const password = document.querySelector('#password').value.trim();
      if (!username || !password) { alert('Enter both a username and password to continue.'); return; }
      state.signedIn = true; state.page = 'Home';
    }
    if (action === 'attendance') state.attendance = Math.min(4, state.attendance + 1);
    if (action === 'verify' && state.attendance === 4) state.verified = true;
    if (action === 'approve' && state.verified) state.approved = true;
    if (action === 'add-person') state.personnel.unshift({ name: 'New CCIS Personnel', status: 'Active' });
    if (action === 'toggle-person') state.personnel[index].status = state.personnel[index].status === 'Active' ? 'Inactive' : 'Active';
    render();
  }

  const style = document.createElement('style');
  style.textContent = `
    :root { color-scheme: dark; --bg:#0d1520;--surface:#142131;--surface2:#1b2c40;--text:#e8f0fa;--muted:#aebed0;--line:#2c4056;--blue:#83b8ff;--blue2:#2166b8;--green:#56bd8a;--amber:#e9b85e; } [data-theme="light"] { color-scheme:light;--bg:#f5f8fc;--surface:#fff;--surface2:#edf4fc;--text:#142335;--muted:#62748a;--line:#d7e2ee;--blue:#2f73c8;--blue2:#2a67bb;--green:#27865a;--amber:#9b6504; }
    *{box-sizing:border-box} body{margin:0;background:var(--bg);color:var(--text);font:15px/1.45 Inter,Segoe UI,Arial,sans-serif;transition:background-color .48s cubic-bezier(.2,.8,.2,1),color .42s ease} button,input{font:inherit} button{cursor:pointer} .topbar,.bottom-nav,.login-card,.metric,.update,.student,.event,.person,.action-card,.profile,.notice,.success-note,input,.icon,.signout,.outline,.roles,.roles button,.nav{transition:background-color .48s cubic-bezier(.2,.8,.2,1),color .36s ease,border-color .48s ease,box-shadow .48s ease}.theme-transition::before{content:'';position:fixed;z-index:9999;inset:-25vmax;pointer-events:none;background:radial-gradient(circle at 86% 10%,#ffffffbd 0%,#d8ebff62 15%,transparent 43%);animation:theme-sweep .62s cubic-bezier(.2,.85,.28,1) forwards;mix-blend-mode:soft-light}.theme-transition .icon{transform:rotate(180deg) scale(1.14)}.icon{transition:transform .48s cubic-bezier(.2,.85,.28,1),background-color .48s ease,color .36s ease,border-color .48s ease}@keyframes theme-sweep{0%{opacity:0;transform:scale(.35)}25%{opacity:.8}100%{opacity:0;transform:scale(1.35)}}@media(prefers-reduced-motion:reduce){*,*:before{animation-duration:.01ms!important;transition-duration:.01ms!important}}
    .app-shell{min-height:100vh;padding-bottom:83px}.topbar{height:76px;display:flex;align-items:center;justify-content:space-between;padding:0 max(20px,calc((100vw - 1120px)/2));background:var(--surface);border-bottom:1px solid var(--line);gap:14px}.brand{display:flex;align-items:center;gap:11px}.brand>b,.avatar{display:grid;place-items:center;width:42px;height:42px;border-radius:13px;background:linear-gradient(145deg,#285783,#12385f);color:#fff;font-size:16px}.brand strong{display:block;font-weight:900}.brand small,.event small,.student small,.person small{display:block;color:var(--muted);font-size:12px}.top-actions{display:flex;align-items:center;gap:9px}.role,.pill{padding:4px 9px;border-radius:999px;background:var(--surface2);font-size:12px;font-weight:800}.icon,.signout{border:1px solid var(--line);background:var(--surface);color:var(--text);border-radius:10px;padding:8px 10px}.page{max-width:920px;margin:0 auto;padding:28px 20px}.eyebrow,label{display:block;color:var(--blue);font-size:11px;font-weight:900;letter-spacing:.7px;margin:0 0 6px}h1{margin:0;font-size:30px;letter-spacing:-.8px}h2{font-size:17px;margin:0}.sub{color:var(--muted);margin:5px 0 18px}.progress-card{position:relative;overflow:hidden;background:linear-gradient(115deg,var(--blue2),#17416d);padding:20px;border-radius:18px;color:#fff;margin:18px 0}.progress-card div:first-child{display:flex;justify-content:space-between}.progress-card strong{position:absolute;right:20px;top:44px;font-size:30px}.progress{margin-top:26px;height:8px;border-radius:999px;background:#ffffff55;overflow:hidden}.progress i{display:block;height:100%;background:#fff;border-radius:inherit}.progress-card small{display:block;margin-top:10px;font-weight:700}.notice,.success-note{background:var(--surface2);border:1px solid var(--line);border-radius:14px;padding:14px;margin:15px 0;color:var(--text)}.warning{background:#67471555;border-color:#6d5126}.success-note{background:#185d4255;border-color:#367d5f}.section-row{display:flex;align-items:center;justify-content:space-between;margin:25px 0 8px}.section-row button{border:0;background:transparent;color:var(--blue);font-weight:800}.update,.student,.event,.person,.action-card,.profile{width:100%;border:1px solid var(--line);background:var(--surface);color:var(--text);border-radius:14px;padding:14px;margin:9px 0;text-align:left}.update p{margin:3px 0;color:var(--muted)}.update small{color:var(--muted)}.event,.student,.person,.action-card,.profile{display:flex;align-items:center;gap:12px}.event>span:nth-child(2),.student>span:nth-child(2),.person>span:nth-child(2){flex:1}.event-icon{display:grid;place-items:center;width:35px;height:35px;border-radius:10px;background:var(--surface2);color:var(--blue)}.pill{font-style:normal}.verified,.complete,.approved{background:#1d644a55;color:#80e8b3}.pending,.deficient{background:#7c531c55;color:#ffd37d}.in-progress{background:#265e9855;color:#a7d1ff}.metrics{display:grid;grid-template-columns:repeat(3,1fr);gap:10px;margin:18px 0}.metric{border-radius:15px;padding:16px;background:var(--surface2);min-height:105px}.metric b{display:block;font-size:29px}.metric span{font-size:13px;color:var(--muted)}.green{border-left:4px solid var(--green)}.amber{border-left:4px solid var(--amber)}.blue{border-left:4px solid var(--blue)}.primary{border:0;background:#82b8ff;color:#10233a;border-radius:11px;padding:12px 16px;font-weight:900}.small{padding:8px 11px;font-size:13px}.outline{border:1px solid var(--line);background:transparent;color:var(--text);border-radius:10px;padding:10px}.chip-row{display:flex;gap:8px;margin:10px 0}.chip-row span{border:1px solid var(--line);padding:6px 10px;border-radius:999px;font-size:12px}input{width:100%;border:1px solid var(--line);background:var(--surface);color:var(--text);border-radius:11px;padding:13px;margin-bottom:14px}.action-card span:last-child{margin-left:auto;font-size:23px}.action-card small{display:block;color:var(--muted)}dl{display:grid;grid-template-columns:120px 1fr;gap:10px;background:var(--surface);border:1px solid var(--line);border-radius:14px;padding:15px}dt{color:var(--muted)}dd{margin:0;font-weight:700}.bottom-nav{position:fixed;inset:auto 0 0;display:flex;justify-content:center;gap:3px;background:var(--surface);border-top:1px solid var(--line);padding:8px}.nav{border:0;background:transparent;color:var(--muted);min-width:86px;padding:7px;border-radius:12px;font-size:12px;font-weight:800}.nav span{display:block;font-size:20px}.nav.selected{background:var(--surface2);color:var(--blue)}.login{min-height:100vh;display:grid;place-items:center;padding:24px}.login-card{position:relative;width:min(520px,100%);padding:28px;border:1px solid var(--line);border-radius:24px;background:var(--surface);box-shadow:0 22px 60px #0003}.center{margin-bottom:25px}.login-theme{position:absolute;right:24px;top:24px}.roles{display:grid;grid-template-columns:repeat(3,1fr);gap:4px;padding:4px;border-radius:12px;background:var(--surface2);margin:8px 0 22px}.roles button{border:0;background:transparent;color:var(--text);padding:10px 5px;border-radius:9px;font-weight:800}.roles .selected{background:#82b8ff;color:#10233a}.login-card label:not(:first-of-type){margin-top:8px}.login-button{width:100%;margin:2px 0 8px}@media(max-width:560px){.topbar{padding:0 14px}.top-actions .role,.signout{display:none}.page{padding:21px 14px}.metrics{grid-template-columns:1fr}.metric{min-height:75px}.bottom-nav{justify-content:space-around}.nav{min-width:0;flex:1}h1{font-size:26px}.event,.student{padding:12px 10px}}
  `;
  document.head.appendChild(style);
  render();
})();
