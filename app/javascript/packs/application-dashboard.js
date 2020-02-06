/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

require("@rails/ujs").start()
require("turbolinks").start()

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

import 'bootstrap/dist/js/bootstrap';
import 'dropzone/dist/dropzone';
import 'tempusdominus-bootstrap-4/build/css/tempusdominus-bootstrap-4.min';
import '../src-dashboard/application.js';
import '../src-dashboard/metronic/application.js';

// Currently no way to implement cocoon in rails 6, so this was an alternative to use cocoon before the creator start changing to use webpack
require("src-dashboard/cocoon");

// Actiontext
require("trix");
require("@rails/actiontext");
