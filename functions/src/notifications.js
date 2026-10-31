"use strict";
const {
  onDocumentCreated,
  onDocumentUpdated,
} = require("firebase-functions/v2/firestore");
const { getFirestore, Timestamp } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const { hash } = require("./booking");
const db = getFirestore();
exports.pushNotification = onDocumentCreated(
  "users/{uid}/notifications/{notificationId}",
  async (event) => {
    const notice = event.data?.data();
    if (!notice) return;
    const devices = await db
      .collection(`users/${event.params.uid}/devices`)
      .get();
    const valid = devices.docs.filter((d) => typeof d.data().fid === "string");
    for (let offset = 0; offset < valid.length; offset += 500) {
      const batch = valid.slice(offset, offset + 500);
      const response = await getMessaging().sendEachForMulticast({
        fids: batch.map((d) => d.data().fid),
        notification: {
          title: "EventHub",
          body: "Có cập nhật mới. Mở EventHub để xem.",
        },
        data: {
          uid: event.params.uid,
          eventId: notice.eventId || "",
          registrationId: notice.registrationId || "",
          type: notice.type || "event",
        },
        android: { priority: "high" },
      });
      for (let i = 0; i < response.responses.length; i++) {
        const code = response.responses[i].error?.code;
        if (
          [
            "messaging/invalid-registration-token",
            "messaging/registration-token-not-registered",
          ].includes(code)
        )
          await batch[i].ref.delete();
      }
    }
  },
);
exports.eventUpdateNotifications = onDocumentUpdated(
  "events/{eventId}",
  async (event) => {
    const before = event.data?.before.data(),
      after = event.data?.after.data();
    if (!before || !after) return;
    const millis = (value) =>
      value instanceof Timestamp ? value.toMillis() : null;
    const cancelled =
      before.status !== "cancelled" && after.status === "cancelled";
    const changed =
      millis(before.startsAt) !== millis(after.startsAt) ||
      millis(before.endsAt) !== millis(after.endsAt) ||
      before.location !== after.location;
    if (!cancelled && !changed) return;
    const registrations = await db
      .collection("registrations")
      .where("eventId", "==", event.params.eventId)
      .where("status", "==", "active")
      .get();
    for (const registration of registrations.docs) {
      const uid = registration.data().uid;
      const id = `event-${hash(event.id)}`;
      const data = {
        type: cancelled ? "event_cancelled" : "event_changed",
        eventId: event.params.eventId,
        title: cancelled ? "Sự kiện đã hủy" : "Cập nhật lịch hoặc địa điểm",
        body: after.title || "Mở để xem thông tin mới nhất.",
        registrationId: cancelled ? registration.id : null,
        createdAt: Timestamp.now(),
        readAt: null,
      };
      try {
        await db.doc(`users/${uid}/notifications/${id}`).create(data);
      } catch (error) {
        if (error.code !== 6) throw error;
      }
    }
  },
);
