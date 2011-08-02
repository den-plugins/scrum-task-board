j = jQuery.noConflict(); //This allows Prototype to go undisturbed

////////////////////////////////////////////////////////////http://stackoverflow.com/questions/3233991/jquery-watch-div/3234646#3234646
///This plugin detects changes made to an element
  jQuery.fn.contentChange = function(callback){
    var elms = jQuery(this);
    elms.each(
      function(i){
        var elm = jQuery(this);
        elm.data("lastContents", elm.html());
        window.watchContentChange = window.watchContentChange ? window.watchContentChange : [];
        window.watchContentChange.push({"element": elm, "callback": callback});
      }
    )
    return elms;
  }
  setInterval(function(){
    if(window.watchContentChange){
      for( i in window.watchContentChange){
        if(window.watchContentChange[i].element.data("lastContents") != window.watchContentChange[i].element.html()){
          window.watchContentChange[i].callback.apply(window.watchContentChange[i].element);
          window.watchContentChange[i].element.data("lastContents", window.watchContentChange[i].element.html())
        };
      }
    }
  },500);

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


function th_resize(count)
{
    var $item = jQuery("#task_board th:eq(" + count + ")");
    var width = $item.css('width');
    var height = $item.css('height');
    jQuery(".status-item:eq(" + count + ")").css('width', width).css('height', height);
}



jQuery(function( $ ){

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//'Recreate' the table header since attributing a thead with position: fixed causes empty <td>s to lose their width
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
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
  var $view = $( window );
 
  function th_adjust() //Basically adjusts the fixed header;call this when window is resized or when a DOM element is inserted or removed
  {
    var count = 0
    jQuery("#task_board th").each(function(){
      th_resize(count);
      count++;
    });
  
    first_item_padding();
  }

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
////Resize window
$view.resize(function(){
  th_adjust();
});

////DOM element is inserted or removed 
 jQuery("#task_board").contentChange(function(){th_adjust();});
 
 jQuery(".show_row").click(function()
 {
  var tr = jQuery(this).attr('href');
  setTimeout(function(){
    var tops = jQuery(window).scrollTop();
    jQuery(window).scrollTop(tops - 75);
    jQuery(tr).css('background', '#ff0000');
  }, 100);
  setTimeout(function(){
    jQuery(tr).css('background', '#fff');
  }, 200);
 
 });
  
});
// script modified from http://www.bennadel.com/blog/1810-Creating-A-Sometimes-Fixed-Position-Element-With-jQuery.htm


