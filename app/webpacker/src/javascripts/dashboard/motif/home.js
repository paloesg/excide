$(document).on("turbolinks:load", function () {
    $("#select-options").hide();

    $("#checkedAll").change(function() {
        if (this.checked) {
            $("#filter-search").hide();
            $("#select-options").show();
            
            $(".checkSingle").each(function() {
                this.checked=true;
            });
            showChecked();
        } else {
            $("#select-options").hide();
            $("#filter-search").show();
            
            $(".checkSingle").each(function() {
                this.checked=false;
            });
        }
    });

    $(".checkSingle").click(function () {
        if ($(this).is(":checked")) {
            $("#filter-search").hide();
            $("#select-options").show();

            var isAllChecked = 0;
            $(".checkSingle").each(function() {
                if (!this.checked)
                    isAllChecked = 1;
            });

            if (isAllChecked == 0) {
                $("#checkedAll").prop("checked", true);
            }     
        }
        else {
            $("#checkedAll").prop("checked", false);
            if(document.querySelectorAll('input[name=documentCheck]:checked').length == 0){
                $("#select-options").hide();
                $("#filter-search").show();
            }
        }
    });

    function showChecked(){
        document.getElementById('selectedNumber').innerHTML = getCheckBoxCount() + " selected";
    }

    function getCheckBoxCount() {
        return document.querySelectorAll('input[name=documentCheck]:checked').length;
    }

    document.querySelectorAll("input[name=documentCheck]").forEach(i=>{
        i.onclick = () => showChecked();
    });
})