document.addEventListener("turbolinks:load", function(event) {
  if(typeof(gtag) == "function") {
    gtag("config", "UA-93342323-1", {
      "page_title": event.target.title,
      "page_path": event.data.url.replace(window.location.protocol + "//" + window.location.hostname + (location.port && ":" + location.port), ""),
    });
  }
});
