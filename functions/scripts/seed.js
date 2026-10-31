// Explicit emulator-only seed. Never uploads sample data to the shared cloud project.
if(!process.env.FIRESTORE_EMULATOR_HOST) throw new Error('Set FIRESTORE_EMULATOR_HOST; seed is emulator-only.');
const {initializeApp}=require('firebase-admin/app'); const {getFirestore,Timestamp}=require('firebase-admin/firestore');const {hash}=require('../src/booking');
initializeApp({projectId:process.env.GCLOUD_PROJECT||'demo-eventhub'});
const db=getFirestore();
(async()=>{
 const starts=new Date(Date.now()+7*86400000);starts.setUTCHours(7,0,0,0);
 const start=starts.getTime();
 await db.doc('events/workshop').set({coverKey:'ux-workshop',visibility:'public',title:'Workshop Thiết kế trải nghiệm người dùng',clubName:'CLB Thiết kế FPTU',topic:'Thiết kế',description:'Thực hành nghiên cứu nhu cầu, dựng prototype và kiểm thử nhanh cùng người dùng.',activities:['Phỏng vấn và tổng hợp insight','Dựng prototype','Kiểm thử nhanh'],audience:'Người quan tâm thiết kế trải nghiệm',preparation:'Mang laptop nếu có',location:'Phòng 204 · Campus TP.HCM',startsAt:Timestamp.fromMillis(start),endsAt:Timestamp.fromMillis(start+150*60000),deadline:Timestamp.fromMillis(start-86400000),registrationMode:'required',capacity:24,activeCount:0,status:'published'});
 await db.doc('events/acoustic').set({coverKey:'acoustic',visibility:'public',title:'Giao lưu Acoustic',clubName:'CLB Guitar',topic:'Âm nhạc',description:'Giao lưu âm nhạc; đến trực tiếp, không cần đăng ký.',activities:[],location:'Sảnh B · Campus TP.HCM',startsAt:Timestamp.fromMillis(start+86400000),endsAt:Timestamp.fromMillis(start+90000000),registrationMode:'free',status:'published'});
 await db.doc('checkinSessions/workshop').set({open:true});
 await db.doc(`qrCredentials/${hash('eventhub-emulator-qr-only')}`).set({eventId:'workshop',enabled:true});
 console.log('Seeded emulator only. QR payload: eventhub-emulator-qr-only. Session open for tests.');
})();
