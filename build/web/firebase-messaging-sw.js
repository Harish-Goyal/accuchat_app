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

messaging.onBackgroundMessage((payload) => {
  const data = payload.data || {};
  const title = (payload.notification && payload.notification.title) || "New message";
  const body  = (payload.notification && payload.notification.body) || "";

  self.registration.showNotification(title, {
    body,
    data, // 🔥 click time yehi data milega
  });
});

// click -> open your app with query params
self.addEventListener('notificationclick', (event) => {
  event.notification.close();

  const data = event.notification.data || {};
  const params = new URLSearchParams(data).toString();

  // NOTE: if app is hosted in subfolder, change path accordingly
  const urlToOpen = `/#/notification?${params}`;

  event.waitUntil((async () => {
    const allClients = await clients.matchAll({ type: 'window', includeUncontrolled: true });
    for (const client of allClients) {
      // focus existing tab if already open
      if ('focus' in client) {
        client.navigate(urlToOpen);
        return client.focus();
      }
    }
    // else open new tab
    if (clients.openWindow) return clients.openWindow(urlToOpen);
  })());
});



/*


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
}
);
*/
