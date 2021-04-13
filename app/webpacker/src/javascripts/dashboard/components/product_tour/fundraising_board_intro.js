import introJs from 'intro.js/intro.js';
$(document).on("turbolinks:load", function () {
  $(".fundraising-tour-start").click(function(e){
    introJs().setOptions({
      steps: [{
        title: 'Welcome',
        intro: 'Here is a tour on how to use this board! 👋'
      },
      {
        element: document.querySelector('.fundraising-tour-1'),
        title: "From 'Search Investors'",
        intro: 'This is where the shortlisted profiles you found on Overture is compiled.'
      },
      {
        title: 'Add Your Own Contact',
        element: document.querySelector('.fundraising-tour-2'),
        intro: "You can add your own potential investor contacts that you don't find through Overture."
      },
      {
        title: 'Default statuses generated for your progress',
        element: document.querySelector('.fundraising-tour-3'),
        intro: 'Shift your contacts from one status to the other'
      }],
      showProgress: true,
      showBullets: false,
      disableInteraction: true
    }).start();
  })
});
