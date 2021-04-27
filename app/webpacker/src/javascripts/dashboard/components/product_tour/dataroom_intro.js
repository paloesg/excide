import introJs from 'intro.js/intro.js';
$(document).on("turbolinks:load", function () {
  $(".dataroom-tour-start").click(function(e){
    introJs().setOptions({
      steps: [{
        title: 'Welcome',
        intro: 'Here is a tour on how to use overture dataroom! 👋'
      },
      {
        element: document.querySelector('.dataroom-tour-1'),
        title: "Upload and Create Folder",
        intro: 'To upload documents or create new folder, click this "+" button.'
      },
      {
        title: 'Give Different Access',
        element: document.querySelector('.dataroom-tour-2'),
        intro: 'You can give different access to different people to different files. Clicking each of the icon will turn on or off each access. Hover your mouse over to see the types of access.'
      },
      {
        title: 'One-click Share to Many',
        element: document.querySelector('.dataroom-tour-3'),
        intro: 'Each column represent one group of people. Every time you give access, it is applied to multiple users at the same time.'
      },
      {
        title: 'Customise Your Groups',
        element: document.querySelector('.dataroom-tour-4'),
        intro: 'You can create and edit the groups by clicking this button.',
        position: 'left'
      }],
      showProgress: true,
      showBullets: false,
      disableInteraction: true
    }).start();
  })
});
