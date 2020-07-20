/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

require("@rails/ujs").start();
require("turbolinks").start();

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//

// const imagePath = (name) => images(name, true)
// Importing images through webpack
const images = require.context('../src/images', true);


import 'bootstrap/dist/js/bootstrap';
// Bootstrap tooltip 
$(function () {
  $('[data-toggle="tooltip"]').tooltip()
})

// For bootstrap datetimepicker
import 'tempusdominus-bootstrap-4/build/css/tempusdominus-bootstrap-4.min';
// Import font awesome 5
import "@fortawesome/fontawesome-free/js/all";
import '../src/javascripts/dashboard/application.js';
import '../src/javascripts/dashboard/metronic/application.js';

require("../src/javascripts/google-analytics");
// Currently no way to implement cocoon in rails 6, so this was an alternative to use cocoon before the creator start changing to use webpack
require("src/javascripts/dashboard/cocoon");

// Actiontext
require("trix");
require("@rails/actiontext");
