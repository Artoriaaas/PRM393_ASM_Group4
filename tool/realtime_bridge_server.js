const http = require('http');

const PORT = 8088;

// Bộ dữ liệu dùng chung giữa Mobile (Điện thoại) và Web Admin (Chrome)
let events = [
  {
    id: 'e_ux',
    title: 'Workshop Thiết kế trải nghiệm người dùng',
    clubName: 'Câu lạc bộ IT FPTU',
    clubId: 'club_it',
    location: 'Phòng 204 · Campus TP.HCM',
    startsAt: new Date(Date.now() + 3 * 86400000).toISOString(),
    endsAt: new Date(Date.now() + 3 * 86400000 + 7200000).toISOString(),
    deadline: new Date(Date.now() + 2 * 86400000).toISOString(),
    capacity: 30,
    activeCount: 18,
    coverKey: 'ux-design',
    description: 'Trang bị kiến thức nền tảng về tư duy UX, cách xây dựng User Persona và thực hành thiết kế luồng người dùng trên Figma cùng các chuyên gia hàng đầu.',
    activities: [
      '08:00 - Đón tiếp sinh viên & check-in',
      '08:30 - Khái niệm UX căn bản & Case study',
      '09:30 - Thực hành thiết kế User Journey',
      '10:15 - Q&A, góp ý sản phẩm và bế mạc'
    ],
    mode: 'required',
    status: 'published'
  },
  {
    id: 'e_code',
    title: 'Coding Bootcamp: Flutter & Firebase',
    clubName: 'Câu lạc bộ IT FPTU',
    clubId: 'club_it',
    location: 'Lab 301 · Campus TP.HCM',
    startsAt: new Date(Date.now() + 5 * 86400000).toISOString(),
    endsAt: new Date(Date.now() + 5 * 86400000 + 14400000).toISOString(),
    deadline: new Date(Date.now() + 4 * 86400000).toISOString(),
    capacity: 25,
    activeCount: 24, // Còn 1 chỗ để test duyệt suất cuối
    coverKey: 'career-connect',
    description: 'Thực chiến lập trình ứng dụng di động đa nền tảng kết nối cơ sở dữ liệu đám mây.',
    activities: [
      '13:00 - Khởi động & cài đặt môi trường',
      '14:00 - Kiến trúc State Management Riverpod',
      '15:30 - Thực hành kết nối API & Rules',
      '16:30 - Demo sản phẩm & trao thưởng'
    ],
    mode: 'required',
    status: 'published'
  },
  {
    id: 'e_acoustic',
    title: 'Đêm nhạc Acoustic: Thanh âm sân trường',
    clubName: 'Câu lạc bộ IT FPTU',
    clubId: 'club_it',
    location: 'Sân khấu ngoài trời · Tòa nhà Alpha',
    startsAt: new Date(Date.now() + 7 * 86400000).toISOString(),
    endsAt: new Date(Date.now() + 7 * 86400000 + 10800000).toISOString(),
    deadline: new Date(Date.now() + 6 * 86400000).toISOString(),
    capacity: 100,
    activeCount: 65,
    coverKey: 'acoustic-live',
    description: 'Không gian âm nhạc mộc mạc kết nối các bạn sinh viên sau giờ học căng thẳng.',
    activities: ['18:30 - Đón khách', '19:00 - Khai mạc', '21:00 - Kết thúc'],
    mode: 'required',
    status: 'published'
  }
];

// Khởi tạo ở trạng thái 'pending' (Chờ duyệt) để Staff Web thấy trên Review Queue!
let registrations = [
  {
    id: 'reg_init_01',
    eventId: 'e_ux',
    clubId: 'club_it',
    status: 'pending',
    generation: 1,
    participant: {
      name: 'Nguyễn Văn An',
      email: 'an.nv@fpt.edu.vn',
      group: 'student',
      cohort: 'K18',
      phone: '0912345678'
    },
    createdAt: new Date(Date.now() - 3600000).toISOString()
  }
];

let notifications = [
  {
    id: 'notif_init',
    title: 'Chào mừng bạn đến với EventHub',
    body: 'Đơn đăng ký tham gia Workshop UX của bạn đang chờ CLB xét duyệt.',
    eventId: 'e_ux',
    registrationId: 'reg_init_01',
    type: 'registration_pending',
    createdAt: new Date().toISOString(),
    readAt: null
  }
];

let checkinSession = {
  eventId: 'e_ux',
  open: false,
  qrToken: '',
  qrHash: ''
};

function parseBody(req) {
  return new Promise((resolve) => {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      try {
        resolve(body ? JSON.parse(body) : {});
      } catch (e) {
        resolve({});
      }
    });
  });
}

const server = http.createServer(async (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, DELETE');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  const url = new URL(req.url, `http://${req.headers.host}`);
  const pathname = url.pathname;

  // 1. GET /api/events & POST /api/events
  if (pathname === '/api/events') {
    if (req.method === 'GET') {
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify(events));
      return;
    }
    if (req.method === 'POST') {
      const data = await parseBody(req);
      const newEvent = {
        id: data.id || 'e_' + Date.now(),
        title: data.title || 'Sự kiện mới',
        clubName: data.clubName || 'Câu lạc bộ IT FPTU',
        clubId: data.clubId || 'club_it',
        location: data.location || 'Campus TP.HCM',
        startsAt: data.startsAt || new Date(Date.now() + 86400000).toISOString(),
        endsAt: data.endsAt || new Date(Date.now() + 90000000).toISOString(),
        deadline: data.deadline || new Date(Date.now() + 80000000).toISOString(),
        capacity: Number(data.capacity) || 30,
        activeCount: Number(data.activeCount) || 0,
        coverKey: data.coverKey || 'ux-design',
        description: data.description || '',
        activities: data.activities || [],
        mode: data.mode || 'required',
        status: data.status || 'published'
      };
      events.unshift(newEvent);
      console.log(`[Bridge] Staff vừa tạo sự kiện mới: "${newEvent.title}" (ID: ${newEvent.id})`);
      res.writeHead(201, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify(newEvent));
      return;
    }
  }

  // 2. GET /api/registrations & POST /api/registrations
  if (pathname === '/api/registrations') {
    if (req.method === 'GET') {
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify(registrations));
      return;
    }
    if (req.method === 'POST') {
      const data = await parseBody(req);
      const regId = 'reg_' + Date.now();
      const newReg = {
        id: regId,
        eventId: data.eventId,
        clubId: data.clubId || 'club_it',
        status: 'pending', // Luôn ở trạng thái chờ duyệt
        generation: 1,
        participant: data.participant || {
          name: 'Nguyễn Minh Anh',
          email: 'minhanh@example.com',
          group: 'student',
          cohort: 'K18'
        },
        createdAt: new Date().toISOString()
      };
      registrations.unshift(newReg);
      console.log(`[Bridge] Sinh viên nộp đơn đăng ký sự kiện "${data.eventId}" -> Status: PENDING`);
      res.writeHead(201, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify(newReg));
      return;
    }
  }

  // 3. POST /api/registrations/review (Duyệt hoặc Từ chối đơn từ Web)
  if (pathname === '/api/registrations/review' && req.method === 'POST') {
    const data = await parseBody(req);
    const { registrationId, action, reason } = data; // action: 'approve' | 'reject'
    const reg = registrations.find(r => r.id === registrationId);

    if (reg) {
      if (action === 'approve') {
        reg.status = 'approved';
        const ev = events.find(e => e.id === reg.eventId);
        if (ev) ev.activeCount++;
        // Thêm thông báo vào Inbox của sinh viên
        notifications.unshift({
          id: 'notif_' + Date.now(),
          title: 'Đơn đăng ký đã được duyệt!',
          body: `CLB đã phê duyệt đơn tham gia sự kiện của bạn. Hãy kiểm tra mục Lịch để lấy mã QR.`,
          eventId: reg.eventId,
          registrationId: reg.id,
          type: 'registration_approved',
          createdAt: new Date().toISOString(),
          readAt: null
        });
        console.log(`[Bridge] Staff đã DUYỆT đơn: ${registrationId}`);
      } else if (action === 'reject') {
        reg.status = 'rejected';
        reg.reason = reason || 'Không đủ tiêu chuẩn tham gia';
        notifications.unshift({
          id: 'notif_' + Date.now(),
          title: 'Đơn đăng ký bị từ chối',
          body: `Lý do: ${reg.reason}`,
          eventId: reg.eventId,
          registrationId: reg.id,
          type: 'registration_rejected',
          createdAt: new Date().toISOString(),
          readAt: null
        });
        console.log(`[Bridge] Staff đã TỪ CHỐI đơn: ${registrationId} - Lý do: ${reg.reason}`);
      }
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify(reg));
      return;
    }
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Registration not found' }));
    return;
  }

  // 4. GET /api/notifications
  if (pathname === '/api/notifications' && req.method === 'GET') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(notifications));
    return;
  }

  // 5. GET & POST /api/checkin-session
  if (pathname === '/api/checkin-session') {
    if (req.method === 'GET') {
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify(checkinSession));
      return;
    }
    if (req.method === 'POST') {
      const data = await parseBody(req);
      checkinSession = {
        eventId: data.eventId || checkinSession.eventId,
        open: data.open !== undefined ? data.open : checkinSession.open,
        qrToken: data.qrToken || checkinSession.qrToken,
        qrHash: data.qrHash || checkinSession.qrHash
      };
      console.log(`[Bridge] Staff cập nhật phiên Check-in: Open = ${checkinSession.open}`);
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify(checkinSession));
      return;
    }
  }

  // 6. POST /api/checkin (Sinh viên quét mã QR từ điện thoại)
  if (pathname === '/api/checkin' && req.method === 'POST') {
    const data = await parseBody(req);
    const { registrationId } = data;
    const reg = registrations.find(r => r.id === registrationId);
    if (reg) {
      reg.checkInAt = new Date().toISOString();
      console.log(`[Bridge] Sinh viên ĐIỂM DANH THÀNH CÔNG cho đơn: ${registrationId}`);
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify(reg));
      return;
    }
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Registration not found' }));
    return;
  }

  res.writeHead(404);
  res.end('Not Found');
});

server.listen(PORT, '127.0.0.1', () => {
  console.log(`======================================================`);
  console.log(`  Realtime Sync Bridge dang chay tai http://127.0.0.1:${PORT}`);
  console.log(`  - Mobile App (USB Reverse): http://127.0.0.1:${PORT}`);
  console.log(`  - Web Admin (Chrome):       http://127.0.0.1:${PORT}`);
  console.log(`======================================================`);
});
