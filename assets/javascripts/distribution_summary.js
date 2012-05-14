jQuery(function(){
  $("#distribution_summary").dialog({
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
