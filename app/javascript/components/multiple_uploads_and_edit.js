/*global Dropzone*/
/*eslint no-undef: "error"*/
/*eslint camelcase: ["error", {allow: ["authenticity_token", "url_files"]}]*/

Dropzone.autoDiscover = false;

$(document).on("turbolinks:load", function() {
  // Multiple uploads on document index page
  if ($(".multiple_uploads_and_edit").length) {
    let cleanFilename = function (name) {
      let fileName = name.split(".").slice(0, -1).join(".");
      let getExtension = name.substring(name.lastIndexOf(".") + 1);
      // Filter out special characters and spaces in filename (same as parametrize function in rails)
      let filterFilename = fileName.toLowerCase().replace(/[^a-z0-9]+/g,"-").replace(/(^-|-$)/g,"");
      return filterFilename + "." + getExtension;
    };

    let documentUpload = new Dropzone(".multiple_uploads_and_edit", { timeout: 0, renameFilename: cleanFilename });

    // Check if file name are same & rename the file
    documentUpload.on("addedfile", function (file) {
      if (this.files.length) {
        let i, len;
        for (i = 0, len = this.files.length; i < len - 1; i++) {
          if (this.files[i].name === file.name) {
            this.removeFile(file);
            let fileName = file.name.split(".").slice(0, -1).join(".");
            let getExtension = file.name.substring(file.name.lastIndexOf(".") + 1);
            let renameFile = new File([file], fileName + "_" + btoa(Math.random()).substr(5, 5) + "." + getExtension, { type: file.type });
            documentUpload.addFile(renameFile);
          }
        }
      }
    });

    documentUpload.on("queuecomplete", function (file, request) {
      $("#view-invoices-button").show();
      // Get url files after uploaded
      let url_files = [], authenticity_token = $.rails.csrfToken();
      $.each(this.files, function(index, value) {
        let key     = $(value.xhr.responseXML).find("Key").text();
        let parser  = document.createElement("a");
        parser.href = $(value.xhr.responseXML).find("Location").text();
        let url     = "//" + parser.hostname + "/" + key;
        url_files.push(url);
      });
      $.post("/symphony/documents/index-create", {
        authenticity_token,
        url_files
      });
    });
  }
});