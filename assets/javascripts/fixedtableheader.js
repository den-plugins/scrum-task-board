function th_resize(count)
{
    var jitem = jQuery("#task_board th:eq(" + count + ")");
    var width = jitem.css('width');
    var height = jitem.css('height');
    jQuery(".status-item:eq(" + count + ")").css('width', width).css('height', height);
}

jQuery(function( $ ){
   //show/hide bugs
    jQuery("#show_bugs").click(function() {
       console.log("show_bugs_clicked");
        if (jQuery(this).is(":checked")) {
            jQuery('.isBug').show();
        }
        else {
            jQuery('.isBug').hide();
        }
        filterBugs();
    });
// 'Recreate' the table header since attributing a thead with position: fixed causes empty <td>s to lose their width
  var jmark = jQuery( "#task_board thead" );
  var jheader = jQuery( "#fixed_table_header" );
  var jbtt = jQuery("#back_to_top");
  var count = 0;
  var leftInit = jheader.offset().left;



  jQuery("#task_board th").each(function(){
    jheader.append('<div class="status-item">'+ jQuery("#task_board th:eq("+ count +")").text() + '</div>');
    th_resize(count);
    count++;
  });

  //Declare the ff. 3 statements in that order
  var jfirst_item = jQuery('.status-item:eq(0)');

  function first_item_padding() { jfirst_item.css('padding-right', '0'); }

  first_item_padding();

  var jview = $( window );
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
  jview.bind(
    "scroll resize",
    function(){
// Get the current offset of the marker(<thead>).
      var markTop = jmark.offset().top;
// Get the current scroll of the window.
      var viewTop = jview.scrollTop();

// Check to see if the view had scroll down past the top of the marker
      if (viewTop > markTop)
      {
        jheader.show();
        jbtt.fadeIn();
      }
// Check to see if the view has scroll back up above the message
      else if (viewTop <= markTop)
      {
        jheader.hide();
        jbtt.fadeOut();
      }
// Allow the fixed header to scroll horizontally
      jheader.offset({
        left: leftInit + 12
      });
    }
  );
////Resize window
jview.resize(function(){
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

  jbtt.click(function(){ jQuery("html, body").animate({scrollTop: 0}, 100) });
});
// script modified from http://www.bennadel.com/blog/1810-Creating-A-Sometimes-Fixed-Position-Element-With-jQuery.htm

