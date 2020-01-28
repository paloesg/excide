// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start();
require("turbolinks").start();

// The next line you only need if you want ActiveStorage support
// require("@rails/activestorage").start()

// The next line you only need if you need channels in administrate
// require("channels")

// // The next two lines you only need if you want ActionText support
// require("trix")
// require("@rails/actiontext")

// Currently no way to implement cocoon in rails 6, so this was an alternative to use cocoon before the creator start changing to use webpack
require("../src-dashboard/cocoon");

require("../administrate/index");
