jQuery(function(){
  jQuery("#distribution_summary").dialog({
    autoOpen:false,
    title:"Taskboard Distribution Summary",
    width:1000,
    resizable: false,
    modal: true,
    buttons: {
      "Close": function() {
         jQuery(this).dialog("close");
       }
    }
  });
});
