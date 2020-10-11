$(document).on("turbolinks:load", function () {
    $("#select-options").hide();

    $("#checkedAll").change(function() {
        if ($(this).is(":checked")) {
            $(".checkSingle").prop("checked", true).change();
        } else {
            $(".checkSingle").prop("checked", false).change();
        }
    });

    $(".checkSingle").change(function () {
        if ($(this).is(":checked")) {
            $("#filter-search").hide();
            $("#select-options").show();

            if ($(".checkSingle:not(:checked)").length == 0) { //if all is checked
                $("#checkedAll").prop("checked", true);
            }

        }
        else {
            $("#checkedAll").prop("checked", false);
            if($(".checkSingle:checked").length == 0) { //if all is unchecked
                $("#select-options").hide();
                $("#filter-search").show();
            }
        }
        showChecked();
    });

    $("#clearSelect").click(function () {
        $("#checkedAll").prop("checked", false).change();
    })

    function showChecked(){
        count = $(".checkSingle:checked").length
        $("#selectedNumber")[0].innerHTML = count + " selected";
        $("#deleteCount")[0].innerHTML = "Delete these " + count + " items?";
    }
})
