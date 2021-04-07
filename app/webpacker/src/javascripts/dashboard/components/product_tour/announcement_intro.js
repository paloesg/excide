import introJs from 'intro.js/intro.js';
$(document).on("turbolinks:load", function () {
  console.log("Dashboard tour 1: ", document.querySelector('.dashboard-tour-1'))
  $(".announcement-tour-start").click(function(e){
    introJs().setOptions({
      steps: [{
        title: 'Welcome',
        intro: 'Here is a tour to use the announcement feature on Overture 👋'
      },
      {
        element: document.querySelector('.announcement-tour-1'),
        title: "Write New Announcement",
        intro: 'Click this button to write and publish new announcement. ',
        position: 'left'
      },
      {
        title: 'Announcement Feed',
        element: document.querySelector('.announcement-tour-2'),
        intro: "Your published announcements are here, and your investors see them the same way as you do."
      }],
      showProgress: true,
      showBullets: false,
      disableInteraction: true
    }).start();
  })
});
