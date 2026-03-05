importScripts('https://www.gstatic.com/firebasejs/10.13.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.13.0/firebase-messaging-compat.js');

firebase.initializeApp({
    apiKey: 'AIzaSyAFPEk1yr_-lG5kU9gyEXmYACDKC2DGh9U',
    appId: '1:948639542031:web:2da43437999a991a562c7a',
    messagingSenderId: '948639542031',
    projectId: 'conectasoc-859f2',
    authDomain: 'conectasoc-859f2.firebaseapp.com',
    storageBucket: 'conectasoc-859f2.firebasestorage.app',
    measurementId: 'G-Y3BTVDH9HM'
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
    console.log('Mensaje en background:', payload);

    self.registration.showNotification(payload.notification?.title ?? 'Notificación', {
        body: payload.notification?.body ?? '',
        icon: '/icons/Icon-192.png'
    });
});
