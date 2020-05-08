require("jquery")

import $ from 'jquery';
window.jQuery = $;
window.$ = $;

window.moment = require("moment");
window.Dropzone = require("dropzone");
window.mixpanel = require("mixpanel-browser");
require("selectize");
require("algoliasearch");
require("tempusdominus-bootstrap-4");
require("blueimp-file-upload");

require("./symphony");
require("./symphony/new_workflow");
require("./symphony/assign_ui");
require("./symphony/remarks");
require("./symphony/popover");
require("./symphony/batches/select_all_by_task");
require("./symphony/zoom");
require("./symphony/invoices/xero");
require("./symphony/invoices/aws");
require("./symphony/choice");

window.createAllocation = require("./conductor/create_allocations");
window.addAvailability = require("./conductor/add_availabilities");
require("./conductor/home");
require("./conductor/go_to_allocation");
require("./components/calendar_style");

require("./components/document_upload");
require("./components/date_time_picker");
require("./components/multiple_uploads");
require("./components/multiple_uploads_and_edit");
require("./components/popover_initialize");
require("./components/selectize_initialize");
require("./components/document_popover");
require("./components/stripe");
require("./symphony/invoices/invoice_global_functions");

require("./turbolinks-compatibility");

// Actiontext
require("trix");
require("@rails/actiontext");
