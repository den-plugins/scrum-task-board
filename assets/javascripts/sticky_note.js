j = jQuery.noConflict(); //This allows Prototype to go undisturbed

function initTalk(id) {
  jQuery("#text_comment_" + id).val('Type your comment here...');
  var barheight = getbarHeight(jQuery("#"+ id + "_discussion"), 30);
  jQuery('.slimScrollBar').css({height: barheight + 'px'});
}


function markLoaded(id) {
  var jtextComment = jQuery("#text_comment_" + id);
  var defaultText = "Type your comment here...";
  jQuery("#" + id + "_discussion").slimScroll({ height: '150px'});
  jtextComment.focusout(function(){
    if(jQuery(this).val() == "") jQuery(this).val(defaultText);
  });
  jtextComment.focusin(function(){
    if(jQuery(this).val() == defaultText) jQuery(this).val("");
  });
  jQuery("#issue_" + id + " .talk").addClass("comments_loaded");
  jQuery("#issue_" + id + " .talk_here").show();
  initTalk(id);
}

function sticky_note(issue, assigned_to, status_id, issue_id, draggable)
{
  jQuery("#" + issue + "").hover(
    function(){
      if(!jQuery("#" + issue + " .edit_here").is(":visible") && !jQuery("#" + issue + " .talk_here").is(":visible"))
        jQuery("#" + issue + " .initial_controls").show();
      },
    function(){jQuery("#" + issue + " .initial_controls").hide();});

  jQuery("#" + issue + " .edit").click(function(){
    jQuery("#" + issue + " .current_data, #" + issue + " .initial_controls").hide();
    jQuery("#" + issue + " .edit_here").show();
  });

  jQuery("#" + issue + " .talk").click(function(){
    jQuery("#" + issue + " .current_data, #" + issue + " .initial_controls").hide();
    if(jQuery(this).hasClass("comments_loaded")) {
      jQuery("#" + issue + " .talk_here").show();
      jQuery("#" + issue + " .talk_here textarea").val("Type your comment here...");
    }
    else {
      var id = jQuery(this).attr("id").split("_")[0];
      console.log(jQuery(this).attr("id").split("_")[0]);
      new Ajax.Request('/task_boards/get_comment', {
                                                    asynchronous  :true,
                                                    evalScripts   :true,
                                                    onComplete    :function(request){markLoaded(id)},
                                                    parameters    :'issue_id=' + id
                                                   });
    }
  });

  jQuery("#" + issue + " .cancel").click(function(){
    jQuery("#" + issue + " #issue_assigned_to_id").val(assigned_to);
    jQuery("#" + issue + " #issue_status_id").val(status_id);
    jQuery("#" + issue + " .edit_here").hide();
    jQuery("#" + issue + " .talk_here").hide();
    jQuery("#" + issue + " .talk_here textarea").val("");
    jQuery("#" + issue + " .initial_controls").show();
    if ( jQuery("#" + issue + " .toggle_details").hasClass('maximized'))
      jQuery("#" + issue + " .current_data").show();
  });

  jQuery("#" + issue + " .toggle_details").click(function(){
    jQuery("#" + issue + " .current_data").toggle(1, function()
    {
      if ( jQuery("#" + issue + " .toggle_details").hasClass('maximized'))
        jQuery("#" + issue + " .toggle_details").removeClass("maximized").addClass("minimized");
      else
        jQuery("#" + issue + " .toggle_details").removeClass("minimized").addClass("maximized");
      });
  })

  jQuery("#" + issue + " .submit_link").click(
  function()
  {
    var choice = confirm("Check changes for assigned to and status and confirm.");
    if(choice){
      jQuery("#" + issue + " .edit_here").hide();
      if (jQuery("#" + issue + " .toggle_details").hasClass('maximized'))
        jQuery("#" + issue + " .current_data").show();
      jQuery("#" + issue + " #taskboard-edit-form-"+ issue +" form").submit();
    }else{
      return false;
    }
  });

  if(draggable)
    new Draggable(issue, {constraint:"horizontal", revert:"failure"});

//===========TOOLTIP===========
  var tip;
  jQuery(".tooltip").hover(function(){
    tip = jQuery(this).find('.tip');
    tip.hide().fadeIn('fast'); //Show tooltip
  }, function() {
    tip.hide(); //Hide tooltip
  }).mousemove(function(e) {
    var x = 24; //Get X coodrinates
    var y = 12; //Get Y coordinates
    var tipWidth = tip.width(); //Find width of tooltip
    var tipHeight = tip.height(); //Find height of tooltip
  //  alert(tipWidth + ", " + tipHeight);
    //Distance of element from the right edge of viewport
    var tipVisX = jQuery(window).width() - (e.pageX + tipWidth);
    //Distance of element from the bottom of viewport
    var tipVisY = jQuery(window).height() - (e.pageY + tipHeight);

    if ( tipVisX < 20 ) { //If tooltip exceeds the X coordinate of viewport
        x = x - tipWidth - 30;
    } if ( tipVisY < 20 ) { //If tooltip exceeds the Y coordinate of viewport
        y = y - tipHeight - 20;
    }
    //Absolute position the tooltip according to mouse position
    tip.css({  top: y, left: x, display: "inline" });
  });

//=================
}

