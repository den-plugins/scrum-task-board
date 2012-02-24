var TaskBoardDisplay = {
  condensedView : function() {
    var showbugs = (j("#hidebugs").html() == "Show Bugs");
    //setting css() seems to be faster than hide() and show()
    j(".task_board_data:visible").not("task_board_feature_data").css("display", "inline-block");
    j(".bulk_details").css('display', 'none');
    j(".taskboard_issues_list").addClass("condensed");
    j(".to_parent").css('display', 'none');
    if(showbugs)
      j(".isBug").addClass("condensed").css("display", "inline-block");
  },

  normalView : function() {
    var showbugs = (j("#hidebugs").html() == "Show Bugs");
    j(".task_board_data:visible").not("task_board_feature_data").css("display", "list-item");
    j(".bulk_details").css('display', 'block');
    j(".taskboard_issues_list").removeClass("condensed");
    j(".to_parent").css("display", "inline");
    if(showbugs)
      j(".isBug").removeClass("condensed").css("display", "list-item");
  },

  toggleCondensed : function() {
    var jcondensed = j("#condensed");
    var jtoggleAll = j("#detailed");

    if(jcondensed.hasClass("activated")) {
      TaskBoardDisplay.condensedView();
      j("#detailed").attr("disabled", true).addClass("disabled");
    }
    else {
      TaskBoardDisplay.normalView();
      j("#detailed").attr("disabled", false).removeClass("disabled");
      if (j(".current_data").is(":visible"))
        jtoggleAll.addClass("activated");
    }
  },

  filterByResource : function() {
    var res_id = j("#selected_resource option:selected").val();
    var display = (j("#condensed").hasClass("activated")) ? "inline-block" : "list-item";
    var opts = { display: display, listStyle: "none" };
    if(j.inArray(res_id, ["", "All", "Select a resource..."]) != -1) {
      j('#selected_resource_blank').val('Select a resource...');
      j('#selected_resource_blank').text('Select a resource...');
      j('.task_board_data').css(opts);
    }
    else {
      j('#selected_resource_blank').val('All');
      j('#selected_resource_blank').text('All');
      j('.task_board_data').hide();
      j('.assigned_to_' + res_id).css(opts);
    }
    if(j("#hidebugs").text() == "Show Bugs"){
      j(".isBug").css("display", "none");
    }
    else {
      var display = (j("#condensed").hasClass("activated")) ? "inline-block" : "list-item";
      j(".isBug").css("display", display);
    }
    TaskBoardDisplay.filterBugs();
  },

  filterBugs : function() {
    var res_id = j("#selected_resource option:selected").val();
    if(j.inArray(res_id, ["", "All", "Select a resource..."]) == -1){
      j('.isBug').each(function(){
        if(!j(this).hasClass('assigned_to_' + res_id) && !j(this).is(':hidden')){
          j(this).css('display', 'none');
        }
      });
    }
  },

  resizeHeaders : function(count) {
    var jitem = j("#task_board th:eq(" + count + ")");
    var width = jitem.css('width');
    var height = jitem.css('height');
    j(".status-item:eq(" + count + ")").css('width', width).css('height', height);
  },

  padFirstHeader : function() {
    // Cache this
    j('.status-item:eq(0)').css('padding-right', '0');
  },

  adjustHeaders : function() {
    // Adjusts the fixed header;call this when window is resized or when a DOM element is inserted or removed
    for(var count = 0, max = j("#task_board th").length; count < max; count++)
    {
      TaskBoardDisplay.resizeHeaders(count);
    }

    TaskBoardDisplay.padFirstHeader();
  },

  setup : function() {
    var jtoggleAll = j("#detailed");
    var jcondensed = j("#condensed");

    j(".buttons").not("#showchart, #hidebugs").click(function(){
      if(!j(this).hasClass("disabled"))
      j(this).toggleClass("activated");
    });

    j("#showbugs").click(function(){
      j(this).text("Loading...").addClass("disabled").css("color", "#4e4e4e").attr("disabled", true);
    });

    j("#hidebugs").click(function(){
      if(j(this).html() === "Hide Bugs") {
        j(".isBug").css("display", "none");
        j(this).html("Show Bugs");
      }
      else {
        var display = (j("#condensed").hasClass("activated")) ? "inline-block" : "list-item";
          j(".isBug").css("display", display);
          TaskBoardDisplay.filterBugs();
          j(this).html("Hide Bugs");
      }
    });

    jtoggleAll.click(function(){
      if(j(this).hasClass("activated")) {
        j(".current_data").show();
        j('.toggle_details').removeClass("minimized").addClass("maximized");
      }
      else {
        j(".current_data").hide();
        j('.toggle_details').removeClass("maximized").addClass("minimized");
      }
    });

    jcondensed.click(TaskBoardDisplay.toggleCondensed);
    j("#selected_resource").bind("change keyup", function() { TaskBoardDisplay.filterByResource(); });
    j("#showchart").click(function(){ return false });
  },

  init : function() {
    if(j("#hidebugs").text() == "Show Bugs"){
      j(".isBug").css("display", "none");
    }
    else {
      var display = (j("#condensed").hasClass("activated")) ? "inline-block" : "list-item";
      j(".isBug").css("display", display);
    }

    //enable show chart
    j("#showchart").unbind("click").removeClass("disabled").colorbox({opacity: 0.5, onComplete:function() {
      plot_chart(j.parseJSON(j("#hidden_chart_data").val()));
    }});

    // 'Recreate' the table header since attributing a thead with position: fixed causes empty <td>s to lose their width
    var jmark = j("#task_board thead");
    var jheader = j( "#fixed_table_header" );
    var jbtt = j("#back_to_top");
    var leftInit = jheader.offset().left;
    var count = 0;

    j("#task_board th").each(function(){
      jheader.append('<div class="status-item">'+ j("#task_board th:eq("+ count +")").text() + '</div>');
      TaskBoardDisplay.resizeHeaders(count);
      count++;
    });

    TaskBoardDisplay.padFirstHeader();

    var jview = j(window);

    // Bind to the window scroll and resize events. Remember, resizing can also change the scroll of the page.
    jview.bind("scroll resize", function() {
      // Get the current offset of the marker(<thead>).
      var markTop = jmark.offset().top;
      // Get the current scroll of the window.
      var viewTop = jview.scrollTop();

      // Check to see if the view had scroll down past the top of the marker
      if (viewTop > markTop) {
        jheader.show();
        jbtt.fadeIn();
      }
      // Check to see if the view has scroll back up above the message
      else if (viewTop <= markTop) {
        jheader.hide();
        jbtt.fadeOut();
      }
      // Allow the fixed header to scroll horizontally
      jheader.offset({ left: leftInit + 12 });
    });

    // Resize window
    jview.resize(function(){
      TaskBoardDisplay.adjustHeaders();
    });

    // Jump to row
    j(".to_parent").click(function() {
      var tr = j(this).attr('href');
      setTimeout(function(){
        var tops = j(window).scrollTop();
          j(window).scrollTop(tops - 75);
          j(tr).css('background', '#ff0000');
      }, 100);

      setTimeout(function(){
        j(tr).css('background', '#fefefe');
      }, 200);
    });

    // DOM element is inserted or removed(http://stackoverflow.com/questions/4979738/fire-jquery-event-on-div-change)
    j("#task_board").bind('DOMNodeInserted DOMNodeRemoved', function(event) {
      TaskBoardDisplay.adjustHeaders();
    });
    // script modified from http://www.bennadel.com/blog/1810-Creating-A-Sometimes-Fixed-Position-Element-With-jQuery.htm
    jbtt.click(function(){ j("html, body").animate({scrollTop: 0}, 100) });
  }
};

TaskBoardDisplay.setup();

