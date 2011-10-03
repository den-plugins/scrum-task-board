function th_resize(count)
{
    var $item = jQuery("#task_board th:eq(" + count + ")");
    var width = $item.css('width');
    var height = $item.css('height');
    jQuery(".status-item:eq(" + count + ")").css('width', width).css('height', height);
}

jQuery(function( $ ){
 jToggleDetails = jQuery('.toggle_details');
 jQuery("#toggle_all").click(function(){
  if(jQuery(this).is(":checked"))
  {
     jQuery(".current_data").show();
     if (jToggleDetails.hasClass("minimized")) 
      jToggleDetails.removeClass("minimized").addClass("maximized");
  }
  else
  {
     jQuery(".current_data").hide();
     if (jToggleDetails.hasClass("maximized")) 
      jToggleDetails.removeClass("maximized").addClass("minimized");
  }
 });
// 'Recreate' the table header since attributing a thead with position: fixed causes empty <td>s to lose their width
  var $mark = jQuery( "#task_board thead" );
  var $header = jQuery( "#fixed_table_header" );
  
  var count = 0;
  var leftInit = $header.offset().left;
  


  jQuery("#task_board th").each(function(){
    $header.append('<div class="status-item">'+ jQuery("#task_board th:eq("+ count +")").text() + '</div>'); 
    th_resize(count);
    count++;
  });
  
  //Declare the ff. 3 statements in that order
  var $first_item = jQuery('.status-item:eq(0)');
  
  function first_item_padding() { $first_item.css('padding-right', '0'); }
    
  first_item_padding();
 
  var $view = $( window );
// Adjusts the fixed header;call this when window is resized or when a DOM element is inserted or removed 
  function th_adjust() 
  {
    var count = 0
    jQuery("#task_board th").each(function(){
      th_resize(count);
      count++;
    });
  
    first_item_padding();
  }

// Bind to the window scroll and resize events. Remember, resizing can also change the scroll of the page.
  $view.bind(
    "scroll resize",
    function(){
// Get the current offset of the marker(<thead>).
      var markTop = $mark.offset().top;
// Get the current scroll of the window.
      var viewTop = $view.scrollTop();
 
// Check to see if the view had scroll down past the top of the marker
      if (viewTop > markTop)
      {
        $header.show();
      } 
// Check to see if the view has scroll back up above the message
      else if (viewTop <= markTop)
      {
        $header.hide(); 
      }
// Allow the fixed header to scroll horizontally      
      $header.offset({
        left: leftInit + 12
      });
    }
  );
////Resize window
$view.resize(function(){
  th_adjust();
});

///Jump to row 
 jQuery(".to_parent").click(function()
 {
  var tr = jQuery(this).attr('href');
  setTimeout(function(){
    var tops = jQuery(window).scrollTop();
    jQuery(window).scrollTop(tops - 75);
    jQuery(tr).css('background', '#ff0000');
  }, 100);
  setTimeout(function(){
    jQuery(tr).css('background', '#fefefe');
  }, 200);
  });

// DOM element is inserted or removed(http://stackoverflow.com/questions/4979738/fire-jquery-event-on-div-change) 
  jQuery("#task_board").bind('DOMNodeInserted DOMNodeRemoved', function(event) {
    th_adjust();
  }); 
});
// script modified from http://www.bennadel.com/blog/1810-Creating-A-Sometimes-Fixed-Position-Element-With-jQuery.htm

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
      x = x - tipWidth;
  } if ( tipVisY < 20 ) { //If tooltip exceeds the Y coordinate of viewport
      y = y - tipHeight;
  }
  //Absolute position the tooltip according to mouse position
  tip.css({  top: y, left: x, display: "inline" });
});
