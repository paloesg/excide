// Keentheme"s plugins
window.Sticky = require("sticky-js");

window.KTUtil = require("./assets/js/global/components/base/util");
window.KTApp = require("./assets/js/global/components/base/app");
// window.KTAvatar = require("./assets/js/global/components/base/avatar");
// window.KTDialog = require("./assets/js/global/components/base/dialog");
window.KTHeader = require("./assets/js/global/components/base/header");
window.KTMenu = require("./assets/js/global/components/base/menu");
window.KTOffcanvas = require("./assets/js/global/components/base/offcanvas");
// window.KTPortlet = require("./assets/js/global/components/base/portlet");
window.KTScrolltop = require("./assets/js/global/components/base/scrolltop");
window.KTToggle = require("./assets/js/global/components/base/toggle");
// window.KTWizard = require("./assets/js/global/components/base/wizard");
require("./assets/js/global/components/base/datatable/core.datatable");
require("./assets/js/global/components/base/datatable/datatable.checkbox");
require("./assets/js/global/components/base/datatable/datatable.rtl");

// Layout scripts
window.KTLayout = require("./assets/js/global/layout/layout");
window.KTChat = require("./assets/js/global/layout/chat");
require("./assets/js/global/layout/demo-panel");
require("./assets/js/global/layout/offcanvas-panel");
require("./assets/js/global/layout/quick-panel");
require("./assets/js/global/layout/quick-search");

require("../turbolinks-compatibility")