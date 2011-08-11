<!------------ Index VIEW ----------------->


<div style="float:right; width: 80px;">
  <span>
  <%= image_tag("/plugin_assets/redmine_burndown/chart.png", :size => "20x20") %>
  </span>
  <span style="float: right; padding-top: 3px;">
  <%= link_to "Show Chart", { :controller => 'burndowns', :action => 'chart', 
                                              :project_id => @version.project_id, 
                                              :id => @version.id }, :id => 'showchart' %>
  </span>
</div>



<!------------ Show VIEW ----------------->

  <link type="text/css" media="screen" rel="stylesheet" href="http://dl.getdropbox.com/u/2863383/js/colorbox132/example5/colorbox.css" /> 
  <h3>Version ID: <%= @version.nil? ? "None" : @version.id %></h3>

  <li><%= link_to "Issues with no versions", 
                  :controller => 'task_boards', 
                  :action => 'show', 
                  :id => @project.id %></li>


<!--- Start REFERENCE (For Development Only) --->

<div id="reference" style="display:none">
<a title="reference" class="show_reference">Show Reference</a>
<table>
<% if @featured %>
  <tr>
    <th colspan="4">Features <span style="font-weight:normal">(Features without children are listed in Other Issues)</span></th>
  </tr>
  <tr>
    <td>Redmine No.</td>
    <td>children.empty?</td>
    <td>Children [all]</td>
    <td>Subtasks</td>
    <td>Children [in this version]</td>
    <td>parent.nil?</td>
    <td>Parent ID</td>
    <td>Parent Version ID</td>
    <td>Subject</td>
  </tr>
  <% @features.each do |f| %>
  <tr>
    <td><%= link_to_issue f %></td>
    <td><%= f.children.empty? %></td>
    <td><%= f.children.count %></td>
    <td><%= f.subtasks.count %></td>
    <% count = 0 
       f.children.each {|c| count += 1 if c.fixed_version_id == @version.id } %>
    <td <%= "style=\"color: #ff0000\"" if f.children.count != count %> ><%= count %></td>   
    <td><%= f.parent.nil? %></td>
    <% p = Issue.find f.parent.issue_from_id if not f.parent.nil? %>
    <td><%= link_to_issue p if not f.parent.nil? %></td> 
    <td <%= "style=\"color: #ff0000\"" if not f.parent.nil? and @version.id != p.fixed_version.id %> ><%= p.fixed_version.id if not f.parent.nil? %></td>
    <td><%= f.subject %></td>
  </tr>
  <% end %>
  
  
  <tr>
    <th colspan="4">Other Issues</th>
  </tr>
  <tr>
    <td>Redmine No.</td>
    <td>children.empty?</td>
    <td>Children [all]</td>
    <td>Subtasks</td>
    <td>Children [in this version]</td>
    <td>parent.nil?</td>
    <td>Parent ID</td>
    <td>Parent Version ID</td>
    <td>Subject</td>
  </tr>
  <% @tasks.each do |f| %>
  <tr>
    <td><%= link_to_issue f %></td>
    <td><%= f.children.empty? %></td>
    <td><%= f.children.count %></td>
    <td><%= f.subtasks.count %></td>
    <% count = 0 
       f.children.each {|c| count += 1 if c.fixed_version_id == @version.id } %>
    <td <%= "style=\"color: #ff0000\"" if f.children.count != count %> ><%= count %></td>
    <td><%= f.parent.nil? %></td>
    <% p = Issue.find f.parent.issue_from_id if not f.parent.nil? %>
    <td><%= link_to_issue p if not f.parent.nil? %></td>    
    <td <%= "style=\"color: #ff0000\"" if not f.parent.nil? and @version.id != p.fixed_version_id %>><%= p.fixed_version_id if not f.parent.nil? %></td>
    <td><%= f.subject %></td>
  </tr>
  <% end %>


<% else %>  
  <tr>
    <th colspan="4">Bugs</th>
  </tr>
  <tr>
    <td>Redmine No.</td>
    <td>children.empty?</td>
    <td>Children [all]</td>
    <td>Subtasks</td>
    <td>Children [in this version]</td>
    <td>parent.nil?</td>
    <td>Parent ID</td>
    <td>Parent Version ID</td>
    <td>Subject</td>
  </tr>
  
  <% @bugs.each do |f| %>
  <tr>
    <td><%= link_to_issue f %></td>
    <td><%= f.children.empty? %></td>
    <td><%= f.children.count %></td>
    <td><%= f.subtasks.count %></td>
    <% count = 0 
       f.children.each {|c| count += 1 if c.fixed_version_id == @version.id } %>
    <td <%= "style=\"color: #ff0000\"" if f.children.count != count %> ><%= count %></td>
    <td><%= f.parent.nil? %></td>
    <% p = Issue.find f.parent.issue_from_id if not f.parent.nil? %>
    <td><%= link_to_issue p if not f.parent.nil? %></td>    
    <td <%= "style=\"color: #ff0000\"" if not f.parent.nil? and @version.id != p.fixed_version_id %>><%= p.fixed_version_id if not f.parent.nil? %></td>
    <td><%= f.subject %></td>
  </tr>
  <% end %>
<% end %>    
</table>
</div>
<a title="reference" class="show_reference">Show Reference</a>
<hr/>

<!--- End REFERENCE (For Development Only) --->



<%= javascript_include_tag  'jquery.colorbox-min.js', :plugin => 'scrum_task_board' %>
<%= javascript_include_tag 'jquery.jqplot.js', :plugin => 'redmine_burndown' %>
<%= javascript_include_tag 'plugins/jqplot.canvasTextRenderer.min.js', :plugin => 'redmine_burndown' %>
<%= javascript_include_tag 'plugins/jqplot.canvasAxisLabelRenderer.min.js', :plugin => 'redmine_burndown' %>
<%= javascript_include_tag 'plugins/jqplot.cursor.min.js', :plugin => 'redmine_burndown' %>
<%= javascript_include_tag 'plugins/jqplot.dateAxisRenderer.min.js', :plugin => 'redmine_burndown' %>
<%= javascript_include_tag 'plugins/jqplot.highlighter.min.js', :plugin => 'redmine_burndown' %>
<%= javascript_include_tag 'chart.js', :plugin => 'redmine_burndown' %>

<script type="text/javascript">
jQuery.noConflict(); 

jQuery("#showchart").colorbox({opacity: 0.7, onComplete:function(){
  var nil = null; // to translate nil to null
  plot_chart(<%= @chart_data.inspect if !@version.effective_date.nil? %>);
}}); 

var $link = jQuery(".show_reference");
$link.click(function(){
  var group = jQuery(this).attr("title");
  var $group = jQuery("#" + group);
  
  if($group.is(":visible"))
  {
    $group.slideUp();
    $link.text("Show Reference");
  }
   
  else
  {
    $group.slideDown();
    $link.text("Hide Reference");
  }
})
</script>


