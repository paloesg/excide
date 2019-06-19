/*global Dropzone*/
/*eslint no-undef: "error"*/
/*eslint camelcase: ["error", {allow: ["authenticity_token", "url_files"]}]*/

Dropzone.autoDiscover = false;

$(document).ready(function () {

  // Multiple uploads on document index page
  if ($(".multiple_uploads_and_edit").length) {
    var cleanFilename = function (name) {
      var fileName = name.split(".").slice(0, -1).join(".");
      var getExtension = name.substring(name.lastIndexOf(".") + 1);
      // Filter out special characters and spaces in filename (same as parametrize function in rails)
      var filterFilename = fileName.toLowerCase().replace(/[^a-z0-9]+/g,"-").replace(/(^-|-$)/g,"");
      return filterFilename + "." + getExtension;
    };

    var documentUpload = new Dropzone(".multiple_uploads_and_edit", { timeout: 0, renameFilename: cleanFilename });

    // Check if file name are same & rename the file
    documentUpload.on("addedfile", function (file) {
      if (this.files.length) {
        var i, len;
        for (i = 0, len = this.files.length; i < len - 1; i++) {
          if (this.files[i].name === file.name) {
            this.removeFile(file);
            var fileName = file.name.split(".").slice(0, -1).join(".");
            var getExtension = file.name.substring(file.name.lastIndexOf(".") + 1);
            var renameFile = new File([file], fileName + "_" + btoa(Math.random()).substr(5, 5) + "." + getExtension, { type: file.type });
            documentUpload.addFile(renameFile);
          }
        }
      }
    });

    documentUpload.on("queuecomplete", function (file, request) {
      $("#view-invoices-button").show();
      // Get url files after uploaded
      var url_files = [], authenticity_token = $.rails.csrfToken();
      $.each(this.files, function(index, value) {
        var key     = $(value.xhr.responseXML).find("Key").text();
        var parser  = document.createElement("a");
        parser.href = $(value.xhr.responseXML).find("Location").text();
        var url     = "//" + parser.hostname + "/" + key;
        url_files.push(url);
      });
      $.post("/symphony/documents/index-create", {
        authenticity_token,
        url_files
      });
    });
  }
});