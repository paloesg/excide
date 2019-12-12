require("jquery")
window.moment = require("moment")
window.Dropzone = require("dropzone")
window.mixpanel = require("mixpanel-browser")
require("selectize")
require("algoliasearch")
require("tempusdominus-bootstrap-4")

import $ from 'jquery';
window.jQuery = $;
window.$ = $;

require("./init")
require("./analytics")
require("./symphony")

require("./symphony/new_workflow")
require("./symphony/assign_ui")
require("./symphony/remarks")
require("./symphony/popover")
require("./symphony/batches/select_all_by_task")
require("./symphony/zoom")
require("./symphony/invoices/xero")

window.createAllocation = require("./conductor/create_allocations")
window.addAvailability = require("./conductor/add_availabilities")
require("./conductor/home")
require("./conductor/go_to_allocation")
require("./components/calendar_style")

require("./components/multiple_uploads")
require("./components/multiple_uploads_and_edit")
require("./components/popover_initialize")
require("./components/selectize_initialize")
require("./components/document_popover")
require("./components/load_batch")
require("./components/stripe")

require("./turbolinks-compatibility")