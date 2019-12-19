require("jquery")

import $ from 'jquery';
window.jQuery = $;
window.$ = $;

window.moment = require("moment")
window.Dropzone = require("dropzone")
window.mixpanel = require("mixpanel-browser")

require("selectize")
require("algoliasearch")
require("tempusdominus-bootstrap-4")

import 'bootstrap';
import 'bootstrap/dist/js/bootstrap';
import 'dropzone/dist/dropzone';

require("../components/stripe");
require("../components/turbolinks-compatibility")

// Load all files in the folder `../stack/js/`
function requireAll(r) { r.keys().forEach(r); }
requireAll(require.context('../stack/js/', true, /\.js$/));