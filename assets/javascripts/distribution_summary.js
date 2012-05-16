jQuery(function(){
  jQuery("#distribution_summary").dialog({
    autoOpen:false,
    title:"Taskboard Distribution Summary",
    width:1000,
    height:500,
    resizable: false,
    modal: true,
    buttons: {
      "Close": function() {
         jQuery(this).dialog("close");
       }
    }
  });

  jQuery(".issue_slider").live("click", function(){
    if(jQuery(this).attr("value") == "+")
      jQuery(this).attr("value", "-")
    else
      jQuery(this).attr("value", "+")
      
    jQuery(".member_issues."+jQuery(this).attr("id")).slideToggle();
  });

  jQuery("#dialog-launcher").live("click", function(){
    jQuery("#ajax-indicator").show();
    jQuery.post("/task_boards/init_distribution_summary", {
              version_id: jQuery("#version_id").val(),
              id: jQuery("#project_id").val()})
      .success(function() { 
        jQuery('#ajax-indicator').hide();
        jQuery("#distribution_summary").dialog("open");
      });
  });
});
