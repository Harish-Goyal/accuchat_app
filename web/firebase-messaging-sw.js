/* eslint-disable no-undef */

// ---- Always log when SW loads (so you can confirm it's the NEW file)
console.log("[firebase-messaging-sw] loaded", self.location.href);

// ---- Basic SW lifecycle (helps take control immediately)
self.addEventListener("install", () => {
  console.log("[firebase-messaging-sw] install");
  self.skipWaiting();
});

self.addEventListener("activate", (event) => {
  console.log("[firebase-messaging-sw] activate");
  event.waitUntil(self.clients.claim());
});

let messaging = null;

// ---- Firebase init wrapped safely so SW NEVER crashes
try {
  importScripts("https://www.gstatic.com/firebasejs/10.12.5/firebase-app-compat.js");
  importScripts("https://www.gstatic.com/firebasejs/10.12.5/firebase-messaging-compat.js");

  firebase.initializeApp({
    apiKey: "AIzaSyCaz1HoDpZxb584tFIAMhHiaz5ORSD0TYk",
    authDomain: "accuchat-d5e99.firebaseapp.com",
    projectId: "accuchat-d5e99",
    storageBucket: "accuchat-d5e99.firebasestorage.app",
    messagingSenderId: "975726861063",
    appId: "1:975726861063:web:393a1548c3e686091083a2",
  });

  messaging = firebase.messaging();
  console.log("[firebase-messaging-sw] firebase messaging initialized");

  // Background handler
  messaging.onBackgroundMessage((payload) => {
    console.log("[firebase-messaging-sw] onBackgroundMessage", payload);

    const n = payload && payload.notification ? payload.notification : {};
    const data = payload && payload.data ? payload.data : {};

    const title = n.title || "New message";
    const options = {
      body: n.body || "",
      icon: n.icon || "/icons/Icon-192.png",
      badge: "/icons/Icon-192.png",
      data: data,
    };

    self.registration.showNotification(title, options);
  });
} catch (e) {
  // IMPORTANT: do NOT throw. If we throw, registration fails.
  console.error("[firebase-messaging-sw] Firebase init failed (but SW continues):", e);
}

// ---- Click handler (works for both Firebase notifications and generic ones)
self.addEventListener("notificationclick", (event) => {
  const data = (event.notification && event.notification.data) ? event.notification.data : {};
  console.log("[firebase-messaging-sw] notificationclick data:", data);

  // build query string safely
  const params = new URLSearchParams();
  Object.keys(data).forEach((k) => params.set(k, data[k] == null ? "" : String(data[k])));

  const urlToOpen =
    self.location.origin + "/#/notification" + (params.toString() ? "?" + params.toString() : "");

  event.notification.close();

  event.waitUntil(
    clients.matchAll({ type: "window", includeUncontrolled: true }).then((wins) => {
      for (const w of wins) {
        if (w.url && w.url.startsWith(self.location.origin)) {
          w.focus();
          try { w.navigate(urlToOpen); } catch (_) {}
          try { w.postMessage({ type: "NOTIF_CLICK", data }); } catch (_) {}
          return;
        }
      }
      return clients.openWindow(urlToOpen);
    })
  );
});