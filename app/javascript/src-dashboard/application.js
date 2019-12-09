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

require("./components/date_time_picker")
require("./components/multiple_uploads")
require("./components/multiple_uploads_and_edit")
require("./components/popover_initialize")
require("./components/selectize_initialize")
require("./components/document_popover")
require("./components/load_batch")
require("./components/stripe")
window.deleteBatch = require("./components/delete_batch")

require("./turbolinks-compatibility")