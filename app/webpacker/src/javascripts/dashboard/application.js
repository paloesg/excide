require("jquery");

import $ from "jquery";
window.jQuery = $;
window.$ = $;

window.moment = require("moment");
window.mixpanel = require("mixpanel-browser");
require("selectize");
require("algoliasearch");
require("tempusdominus-bootstrap-4");
require("blueimp-file-upload");
require("select2");

require("./symphony");
require("./symphony/new_workflow");
require("./symphony/assign_ui");
require("./symphony/remarks");
require("./symphony/popover");
require("./symphony/batches/select_all_by_task");
require("./symphony/batches/create_batch_through_documents");
require("./symphony/zoom");
require("./symphony/invoices/xero");
require("./symphony/invoices/aws");
require("./symphony/choice");
require("./symphony/templates/choose_deadline_types");
require("./symphony/templates/choose_template_patterns");
require("./symphony/header");

window.createAllocation = require("./conductor/create_allocations");
window.addAvailability = require("./conductor/add_availabilities");
require("./conductor/home");
require("./conductor/go_to_allocation");
require("./conductor/event_update");
require("./components/calendar_style");

// Import Uppy drag-and-drop
require("./components/uppy");
require("./components/direct_upload");
// require("./components/document_upload");
require("./components/popover_initialize");
require("./components/selectize_initialize");
require("./components/document_popover");
require("./components/stripe");
require("./symphony/invoices/invoice_global_functions");
require("./components/date_time_picker");
