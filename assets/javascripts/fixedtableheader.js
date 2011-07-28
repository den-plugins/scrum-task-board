j = jQuery.noConflict(); //This allows Prototype to go undisturbed


function th_resize(count)
{
    var $item = jQuery("#task_board th:eq(" + count + ")");
    var width = $item.css('width');
    var height = $item.css('height');
    jQuery(".status-item:eq(" + count + ")").css('width', width).css('height', height);
}



jQuery(function( $ ){

////////////////////////////////////////////////
//'Recreate' the table header since attributing a thead with position: fixed causes empty <td>s to lose their width
  jQuery("#showchart").colorbox();

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
///////////////////////////////////////////////
 
  var $view = $( window );
 
 
// Bind to the window scroll and resize events.
// Remember, resizing can also change the scroll
// of the page.
  $view.bind(
    "scroll resize",
    function(){
// Get the current offset of the marker(<thead>).
      var markTop = $mark.offset().top;
// Get the current scroll of the window.
      var viewTop = $view.scrollTop();
 
// Check to see if the view had scroll down
// past the top of the marker
      if (viewTop > markTop)
      {
        $header.show();
// Check to see if the view has scroll back up
// above the message
      } 
      else if (viewTop <= markTop)
      {
        $header.hide(); 
      }
//Allow the fixed header to scroll horizontally      
      $header.offset({
        left: leftInit + 12
      });
    }
  );
//Change the fixed individual header's width when window is resized  
 $view.resize(function()
 {
  var count = 0
  jQuery("#task_board th").each(function(){
    th_resize(count);
    count++;
  });
  
  first_item_padding();

 });
  
});
// script modified from http://www.bennadel.com/blog/1810-Creating-A-Sometimes-Fixed-Position-Element-With-jQuery.htm


