/* eslint no-console: ["error", { allow: ["warn", "error"] }] */

(function($) {

  var cocoonElementCounter = 0;

  var createNewId = function() {
    return (new Date().getTime() + cocoonElementCounter++);
  }

  var newContentBraced = function(id) {
    return '[' + id + ']$1';
  }

  var newContentUnderscord = function(id) {
    return '_' + id + '_$1';
  }

  var getInsertionNodeElem = function(insertionNode, insertionTraversal, $this){

    if (!insertionNode){
      return $this.parent();
    }

    if (typeof insertionNode == 'function'){
      if(insertionTraversal){
        console.warn('association-insertion-traversal is ignored, because association-insertion-node is given as a function.')
      }
      return insertionNode($this);
    }

    if(typeof insertionNode == 'string'){
      if (insertionTraversal){
        return $this[insertionTraversal](insertionNode);
      }else{
        return insertionNode == "this" ? $this : $(insertionNode);
      }
    }

  }

  $(document).on('click', '.add_fields', function(e) {
    e.preventDefault();
    e.stopPropagation();
    
    var $this                 = $(this),
        assoc                 = $this.data('association'),
        assocs                = $this.data('associations'),
        content               = $this.data('association-insertion-template'),
        insertionMethod       = $this.data('association-insertion-method') || $this.data('association-insertion-position') || 'before',
        insertionNode         = $this.data('association-insertion-node'),
        insertionTraversal    = $this.data('association-insertion-traversal'),
        count                 = parseInt($this.data('count'), 10),
        regexpBraced         = new RegExp('\\[new_' + assoc + '\\](.*?\\s)', 'g'),
        regexpUnderscord     = new RegExp('_new_' + assoc + '_(\\w*)', 'g'),
        newId                = createNewId(),
        newContent           = content.replace(regexpBraced, newContentBraced(newId)),
        newContents          = [],
        originalEvent         = e;


    if (newContent == content) {
      regexpBraced     = new RegExp('\\[new_' + assocs + '\\](.*?\\s)', 'g');
      regexpUnderscord = new RegExp('_new_' + assocs + '_(\\w*)', 'g');
      newContent       = content.replace(regexpBraced, newContentBraced(newId));
    }

    newContent = newContent.replace(regexpUnderscord, newContentUnderscord(newId));
    newContents = [newContent];

    count = (isNaN(count) ? 1 : Math.max(count, 1));
    count -= 1;

    while (count) {
      newId      = createNewId();
      newContent = content.replace(regexpBraced, newContentBraced(newId));
      newContent = newContent.replace(regexpUnderscord, newContentUnderscord(newId));
      newContents.push(newContent);

      count -= 1;
    }

    var insertionNodeElem = getInsertionNodeElem(insertionNode, insertionTraversal, $this)

    if( !insertionNodeElem || (insertionNodeElem.length === 0) ){
      console.warn("Couldn't find the element to insert the template. Make sure your `data-association-insertion-*` on `link_to_add_association` is correct.")
    }

    $.each(newContents, function(i, node) {
      var contentNode = $(node);

      var beforeInsert = jQuery.Event('cocoon:before-insert');
      insertionNodeElem.trigger(beforeInsert, [contentNode, originalEvent]);

      if (!beforeInsert.isDefaultPrevented()) {
        // allow any of the jquery dom manipulation methods (after, before, append, prepend, etc)
        // to be called on the node.  allows the insertion node to be the parent of the inserted
        // code and doesn't force it to be a sibling like after/before does. default: 'before'
        var addedContent = insertionNodeElem[insertionMethod](contentNode);

        insertionNodeElem.trigger('cocoon:after-insert', [contentNode,
          originalEvent]);
      }
    });
  });

  $(document).on('click', '.remove_fields.dynamic, .remove_fields.existing', function(e) {
    var $this = $(this),
        wrapper_class = $this.data('wrapper-class') || 'nested-fields',
        node_to_delete = $this.closest('.' + wrapper_class),
        trigger_node = node_to_delete.parent(),
        originalEvent = e;

    e.preventDefault();
    e.stopPropagation();

    var before_remove = jQuery.Event('cocoon:before-remove');
    trigger_node.trigger(before_remove, [node_to_delete, originalEvent]);

    if (!before_remove.isDefaultPrevented()) {
      var timeout = trigger_node.data('remove-timeout') || 0;

      setTimeout(function() {
        if ($this.hasClass('dynamic')) {
            node_to_delete.detach();
        } else {
            $this.prev("input[type=hidden]").val("1");
            node_to_delete.hide();
        }
        trigger_node.trigger('cocoon:after-remove', [node_to_delete,
          originalEvent]);
      }, timeout);
    }
  });


  $(document).on("ready page:load turbolinks:load", function() {
    $('.remove_fields.existing.destroyed').each(function(i, obj) {
      var $this = $(this),
          wrapper_class = $this.data('wrapper-class') || 'nested-fields';

      $this.closest('.' + wrapper_class).hide();
    });
  });

})(jQuery);