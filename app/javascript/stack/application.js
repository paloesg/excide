require("jquery")

import 'bootstrap';
import 'bootstrap/dist/js/bootstrap';
import 'dropzone/dist/dropzone';

import $ from 'jquery';
window.jQuery = $;
window.$ = $;

window.moment = require("moment")
window.Dropzone = require("dropzone")
window.mixpanel = require("mixpanel-browser")
window.Turbolinks = require("turbolinks")

require("selectize")
require("algoliasearch")
require("tempusdominus-bootstrap-4")

require("../components/stripe");
require("../components/turbolinks-compatibility")