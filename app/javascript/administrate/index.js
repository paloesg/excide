require("jquery");
import $ from 'jquery';
window.jQuery = $;
window.$ = $;

window.moment = require("moment");

import "cocoon";
require("selectize");
require("algoliasearch");
require("tempusdominus-bootstrap-4");
require("blueimp-file-upload");

require("./components/_search");
require("./components/date_time_picker");
require("./components/has_many_form");
require("./components/image_upload");
require("./components/selectize_initialize");
require("./components/table");