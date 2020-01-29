require("jquery");
window.moment = require("moment");
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
require("./components/administrate-field-jsonb/editor");
require("./components/administrate-field-jsonb/accordion");
require("./components/administrate-field-jsonb/viewer");
window.JSONEditor = require("./components/administrate-field-jsonb/jsoneditor-minimalist.min");