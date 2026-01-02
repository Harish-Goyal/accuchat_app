
/* eslint-disable no-undef */

// Import Firebase scripts (compat is simplest in SW)
importScripts("https://www.gstatic.com/firebasejs/10.12.5/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.12.5/firebase-messaging-compat.js");

// Your firebase config (same project)
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

// Background push handler (when tab is not focused/closed)
messaging.onBackgroundMessage((payload) => {
  console.log("[sw] onBackgroundMessage", payload);

  const title = payload?.notification?.title || "New message";
  const options = {
    body: payload?.notification?.body || "",
    data: payload?.data || {},      // keep for click
  };

  self.registration.showNotification(title, options);
});

// Notification tap handler
self.addEventListener("notificationclick", (event) => {
  console.log("[sw] notificationclick", event.notification.data);

  const data = event.notification.data || {};
  const params = new URLSearchParams(data).toString();
  console.log('params',params);
  // Put your deep link here (best: a URL that includes query params)
  const url =  "#/notification?${params}");

  event.notification.close();
  event.waitUntil(
    clients.matchAll({ type: "window", includeUncontrolled: true }).then((clientList) => {
      // If app tab already open, focus it + (optional) postMessage
      for (const client of clientList) {
        if (client.url.includes(self.location.origin)) {
          client.focus();
          client.postMessage({ type: "NOTIF_CLICK", data });
          return;
        }
      }
      return clients.openWindow(url);
    })
  );
});


/*
messaging.onBackgroundMessage((payload) => {
console.log('🔥 BACKGROUND MESSAGE RECEIVED');
console.log('Payload:', payload);

  const data = payload.data || {};
  const title = (payload.notification && payload.notification.title) || "New message";
  const body  = (payload.notification && payload.notification.body) || "";
 console.log('Data:', data);
  console.log('Title:', title);
  console.log('Body:', body);

  self.registration.showNotification(title, {
    body,
    data, // 🔥 click time yehi data milega
  });
});

// click -> open your app with query params
self.addEventListener('notificationclick', (event) => {
  console.log('👉 NOTIFICATION CLICKED');
  event.notification.close();

  const data = event.notification.data || {};
  console.log('Click Data:', data);

  const params = new URLSearchParams(data).toString();
  console.log('Query Params:', params);


  // NOTE: if app is hosted in subfolder, change path accordingly
  const urlToOpen = `/#/notification?${params}`;

  event.waitUntil((async () => {
    const clientsArr = await clients.matchAll({
      type: 'window',
      includeUncontrolled: true
    });

    for (const client of clientsArr) {
      console.log('Existing client found:', client.url);
      await client.navigate(urlToOpen);
      return client.focus();
    }

    console.log('Opening new window');
    return clients.openWindow(urlToOpen);
  })());
});

*/



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
