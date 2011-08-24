j = jQuery.noConflict(); //This allows Prototype to go undisturbed

function sticky_note(issue, assigned_to, status_id)
{
  jQuery("#" + issue + "").hover(
    function(){
      if(!jQuery("#" + issue + " .edit_here").is(":visible"))
        jQuery("#" + issue + " .initial_controls").show();
      },
    function(){jQuery("#" + issue + " .initial_controls").hide();});

  jQuery("#" + issue + " .edit").click(function(){
    jQuery("#" + issue + " .current_data, #" + issue + " .initial_controls").hide();
    jQuery("#" + issue + " .edit_here").show();
  });
        
  jQuery("#" + issue + " .cancel").click(function(){
    jQuery("#issue_assigned_to_id").val(assigned_to);
    jQuery("#issue_status_id").val(status_id);
    jQuery("#" + issue + " .edit_here").hide();
    jQuery("#" + issue + " .initial_controls").show();
    if ( jQuery("#" + issue + " .toggle_details").hasClass('maximized')){
      jQuery("#" + issue + " .current_data").show();
    }
  });
  
  jQuery("#" + issue + " .toggle_details").click(function(){
    jQuery("#" + issue + " .current_data").toggle(1, function()
    {
      //if(jQuery(this).is(":visible"))
      if ( jQuery("#" + issue + " .toggle_details").hasClass('maximized'))
        //jQuery("#" + issue + " .toggle_details").css('background-image', "url('/plugin_assets/scrum_task_board/images/zoom_out.png')");
        jQuery("#" + issue + " .toggle_details").removeClass("maximized").addClass("minimized");
      else
        //jQuery("#" + issue + " .toggle_details").css('background-image', "url('/plugin_assets/scrum_task_board/images/zoom_in.png')");
        jQuery("#" + issue + " .toggle_details").removeClass("minimized").addClass("maximized");
      });
  })

  jQuery("#" + issue + " .submit_link").click(
  function()
  {
    var choice = confirm("Check changes for assigned to and status and confirm.");
    if(choice)
      jQuery("#" + issue + " form").submit();
    else
      return false;
  });
}