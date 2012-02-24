j = jQuery.noConflict(); //This allows Prototype to go undisturbed

var StickyNote = {
  init : function(issue, assignedTo, statusId, id, isDraggable){
    var note = j("#" + issue);

    // Hover
    note.hover(function() {
      if(!note.find(".edit_here").is(":visible") && !j("#" + issue + " .talk_here").is(":visible"))
        note.find(".initial_controls").show();
      },
      function(){
        note.find(".initial_controls").hide();
      });

    // Edit Control
    note.find(".edit").click(function(){
      note.find(".current_data, .initial_controls").hide();
      note.find(".edit_here").show();
    });

    // Comment Control
    note.find(".talk").click(function(){
      note.find(".current_data, .initial_controls").hide();
      if(j(this).hasClass("comments_loaded")) {
        note.find(".talk_here").show();
        note.find(".talk_here textarea").val("Type your comment here...");
      }
      else {
        new Ajax.Request('/task_boards/get_comment', {
                                                    asynchronous  :true,
                                                    evalScripts   :true,
                                                    onComplete    :function(request){StickyNote.markLoaded(id, issue)},
                                                    parameters    :'issue_id=' + id
                                                    });
      }
    });

    // Cancel Control
    note.find(" .cancel").click(function(){
      note.find("#issue_assigned_to_id").val(assignedTo);
      note.find("#issue_status_id").val(statusId);
      note.find(".edit_here, .talk_here").hide();
      note.find(".talk_here textarea").val("");
      note.find(".initial_controls").show();
      if(note.find(".toggle_details").hasClass('maximized'))
        note.find(".current_data").show();
    });

    // Click DETAILS
    note.find(".toggle_details").click(function(){
      note.find(".current_data").toggle(1, function(){
        if (note.find(".toggle_details").hasClass('maximized'))
          note.find(".toggle_details").removeClass("maximized").addClass("minimized");
        else
          note.find(".toggle_details").removeClass("minimized").addClass("maximized");
      });
    });

    // Edit FORM SUBMIT
    note.find(".submit_link").click(function(){
      var choice = confirm("Check changes for assigned to and status and confirm.");
      if(choice){
        note.find(".edit_here").hide();
        if (note.find(".toggle_details").hasClass('maximized'))
          note.find(".current_data").show();
        note.find("#taskboard-edit-form-" + issue +" form").submit();
      }
      else {
        return false;
      }
    });

    // Initialize DRAGGABLE
    if(isDraggable)
      new Draggable(issue, {constraint:"horizontal", revert:"failure"});

    // Tooltip
      var tip = j(this).find('.tip');
      j("#" + issue + "_tooltip").hover(function(){
          tip.hide().fadeIn('fast');
        }, function() {
          tip.hide();
        }).mousemove(function(e) {
          var x = 24;
          var y = 12;
          var tipWidth = tip.width();
          var tipHeight = tip.height();
          var tipVisX = j(window).width() - (e.pageX + tipWidth);
          var tipVisY = j(window).height() - (e.pageY + tipHeight);

          if(tipVisX < 20)
            x = x - tipWidth - 30;
          if(tipVisY < 20)
            y = y - tipHeight - 20;
          tip.css({  top: y, left: x, display: "inline" });
        });
  },

  markLoaded : function(id, issue){
    var note = j("#" + issue);
    var jtextComment = j("#text_comment_" + id);
    var defaultText = "Type your comment here...";

    j("#" + id + "_discussion").slimScroll({ height: '150px'});
    jtextComment.focusout(function(){
      if(j(this).val() == "")
        j(this).val(defaultText);
      });

    jtextComment.focusin(function(){
      if(j(this).val() == defaultText)
        j(this).val("");
      });

    note.find(".talk").addClass("comments_loaded");
    note.find(".talk_here").show();

    StickyNote.initTalk(id);
  },

  initTalk : function(id){
    var barheight = getbarHeight(j("#"+ id + "_discussion"), 30);

    j("#text_comment_" + id).val('Type your comment here...');
    j('.slimScrollBar').css({height: barheight + 'px'});
  }
};

