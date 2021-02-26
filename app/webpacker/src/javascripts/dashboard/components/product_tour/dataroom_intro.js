import introJs from 'intro.js/intro.js';
$(document).on("turbolinks:load", function () {
  $(".dataroom-tour-start").click(function(e){
    introJs().setOptions({
      steps: [{
        title: 'Welcome',
        intro: 'Hello World! 👋'
      },
      {
        element: document.querySelector('.dataroom-tour-1'),
        title: "Secured sharing with potential investors and others",
        intro: 'You can share confidential files easily and securely here. Take a tour to quickly learn.'
      },
      {
        title: 'Upload and Create Folder',
        element: document.querySelector('.dataroom-tour-2'),
        intro: 'To upload documents or create new folder, click this "+" button.'
      },
      {
        title: 'Give Different Access',
        element: document.querySelector('.dataroom-tour-3'),
        intro: 'You can give different access to different people to different files. Clicking each of the icon will turn on or off each access.'
      },
      {
        title: 'Customise Your Groups',
        element: document.querySelector('.dataroom-tour-4'),
        intro: 'You can create and edit the groups by clicking this button.',
        position: 'left'
      }]
    }).start();
  })
});
