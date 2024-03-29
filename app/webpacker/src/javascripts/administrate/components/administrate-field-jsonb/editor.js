$(document).on("turbolinks:load", function(){
  let editor, updatedJson;
  $('.administrate-jsoneditor').each(function (index) {

    let $current = $(this).find("textarea");

    let options = {
      onChange: function () {
        try {
          updatedJson = editor.get();
        } catch (err) {
          console.log(err);
        }

        $current.val(JSON.stringify(updatedJson));
      },
      onError: function (err) {
        alert(err.toString());
      },
      navigationBar: false,
      search: false,
      enableSort: false,
      enableTransform: false,
      mode: 'tree',
      modes: ['text', 'tree'],
    };

    let editor = new JSONEditor(this, options);

    if ($current.val() == "null") {
      editor.set(JSON.parse("[]"));
      $("textarea").val("[]");
    } else {
      editor.set(JSON.parse($current.val()));
    }
  });
})