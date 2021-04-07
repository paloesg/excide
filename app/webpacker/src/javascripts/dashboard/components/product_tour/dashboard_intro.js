import introJs from 'intro.js/intro.js';
$(document).on("turbolinks:load", function () {
  console.log("Dashboard tour 1: ", document.querySelector('.dashboard-tour-1'))
  $(".dashboard-tour-start").click(function(e){
    introJs().setOptions({
      steps: [{
        title: 'Welcome',
        intro: 'This is the dashboard tour 👋'
      },
      {
        element: document.querySelector('.dashboard-tour-1'),
        title: "Overture Features",
        intro: 'This is where you can go to different parts of Overture according to your needs.',
        position: 'right'
      },
      {
        title: 'Q&A Summary',
        element: document.querySelector('.dashboard-tour-2'),
        intro: "In this card, you can see the summary of your Q&A with investors. Don't miss anything."
      },
      {
        title: 'Activity History',
        element: document.querySelector('.dashboard-tour-3'),
        intro: 'As you use Overture more, this space will be filled with records of actions done by you, your team or investors.'
      }],
      showProgress: true,
      showBullets: false,
      disableInteraction: true
    }).start();
  })
});
