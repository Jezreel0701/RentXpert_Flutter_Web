// web/firebase-messaging-sw.js

importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyCi4C9C1gl1VHULiR0XajlGv7l9dDF_2GQ",
  authDomain: "rentxpert-a987d.firebaseapp.com",
  projectId: "rentxpert-a987d",
  storageBucket: "rentxpert-a987d.firebasestorage.app",
  messagingSenderId: "651094880398",
  appId: "1:651094880398:ios:202391ac132b5493a0d9df"
});

const messaging = firebase.messaging();
