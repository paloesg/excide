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
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true))

require("jquery");

import 'bootstrap';
import 'bootstrap/dist/js/bootstrap';
import 'dropzone/dist/dropzone';

// Import font awesome 5
import "@fortawesome/fontawesome-free/js/all";

import $ from 'jquery';
window.jQuery = $;
window.$ = $;

window.moment = require("moment");
window.Dropzone = require("dropzone");
window.mixpanel = require("mixpanel-browser");
window.Turbolinks = require("turbolinks");

require("../../src/javascripts/google-analytics");
require("selectize");
require("algoliasearch");
require("tempusdominus-bootstrap-4");

require("../../src/javascripts/dashboard/components/stripe");
require("../../src/javascripts/dashboard/components/turbolinks-compatibility");
