$(document).on("turbolinks:load", function () {
    $("#filter-options").hide();
    $("#filter").on("click", function() {
        $("#filter-search").hide();
        $("#filter-options").show();
    })
    $("#clear-filter").on("click", function() {
        $("#filter-options").hide();
        $("#filter-search").show();
    })
})