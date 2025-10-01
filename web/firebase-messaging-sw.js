/* web/firebase-messaging-sw.js */
/* eslint-disable no-undef */
importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-messaging-compat.js');

/* Web config: use the SAME values as in firebase_options.dart (web section) */
firebase.initializeApp({
  apiKey: "AIzaSyCaz1HoDpZxb584tFIAMhHiaz5ORSD0TYk",
  authDomain: "accuchat-d5e99.firebaseapp.com",
  projectId: "accuchat-d5e99",
  storageBucket: "accuchat-d5e99.firebasestorage.app",
  messagingSenderId: "975726861063",
  appId: "1:975726861063:web:393a1548c3e686091083a2",
  // measurementId optional
});

const messaging = firebase.messaging();

/* background/closed tabs
messaging.onBackgroundMessage((payload) => {
  const n = payload.notification || {};
  self.registration.showNotification(n.title || 'New message', {
    body: n.body || '',
    icon: n.icon,      // optional
    image: n.image,    // optional
    data: { link: (payload?.fcmOptions?.link) || n.click_action || '/' },
  });
});

*//* click → open link *//*
self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const url = event.notification?.data?.link || '/';
  event.waitUntil(clients.openWindow(url));
});*/



messaging.onBackgroundMessage((payload) => {
  const n = payload.notification || {};
  const data = payload.data || {};
  const type = data.type || 'default';

  self.registration.showNotification(n.title || 'Notification', {
    body: n.body || '',
    tag: type,                   // acts like your "channel"
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    data: data,                  // pass deep-link params
    renotify: true
  });
});

// Handle notification clicks
self.addEventListener('notificationclick', (event) => {
  const url = '/?type=' + (event.notification?.data?.type || 'default');
  event.notification.close();
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then((wins) => {
      // focus existing tab if open
      for (const w of wins) {
        if ('focus' in w) return w.focus();
      }
      // otherwise open new tab
      return clients.openWindow(url);
    })
  );
});
