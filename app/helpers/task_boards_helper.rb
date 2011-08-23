module TaskBoardsHelper
  def status_classes_for(issue, user)
    statuses = issue.new_statuses_allowed_to(user)-[issue.status]
    status_class_names = statuses.map {|status| status.class_name }
    status_class_names.join(' ')
  end

  def task_board_drop_receiving_element(dom_id, status)
    drop_receiving_element(dom_id,
      :accept => status.class_name,
      :hoverclass => 'hovered',
      :url => {:controller => 'task_boards', :action => 'update_issue_status'},
      :with => "'issue_id=' + (element.id.split('_').last()) + '&status_id=#{status.id}&id=#{@project.id}&board=#{params[:board]}'")
  end
  
  def task_board_dom_id(issue, status, suffix='')
    element_id = dom_id(issue || Issue.new, status.class_name)
    element_id += "_#{suffix}" if suffix
    element_id
  end
  
  def task_board_border_class issue
    klass = ""
    if issue.task? : klass = "task_board_task_data"  
    elsif issue.feature? : klass = "task_board_feature_data" 
    elsif issue.bug? : klass = "task_board_bug_data"
    elsif issue.support? : klass = "task_board_support_data" 
    end
    klass += " no_drag" if issue.children_here?
    klass
  end
  
  def select_assigned_to f, issue
    f.select :assigned_to_id, (@project.members.collect {|p| [p.name, p.user.id]}), :selected => (issue.assigned_to.nil? ? '' : issue.assigned_to.id), :required => true
  end
  
  def select_status f, issue
    group = @status_grouped
    x = group.keys.detect {|k| group[k][:statuses].include? issue.status }
    if group[x][:statuses].count > 1
      f.select :status_id, group[x][:statuses].collect {|k| [k.name, k.id]}, :selected => issue.status.id
    end
  end
  
  def link_to_issue(issue, options={})
    options[:class] ||= ''
    options[:class] << ' issue'
    if issue.closed?
      klass = issue.bug? ? ' bug_closed' : ' issue_closed'
      options[:class] << klass
    end
    link_to "#{issue.id}", {:controller => "issues", :action => "show", :id => issue}, options
  end
  
  def get_children(parent, color, group)
      str = ""
      color = color - (1118481 * 2)
      parent.children.each do |child|
        if child.fixed_version_id == @version.id and not child.version_children(@version.id).empty?
          str += "<tr style='background: ##{color.to_s(16)};' class='#{group}'><td>&nbsp;</td><td>
            <p> #{link_to_issue(child)} </p>
            <p>#{child.subject}</p>
            <p style='align:right'><a title='#{child.id}_p' class='show_subtasks'>Show Subtasks w/ children</a></p>
          </td>"
=begin
          <% @statuses.each do |status| %>
          str += "<td id='"
          str += task_board_dom_id(feature, status) 
          str += "' class='"
          str += cycle('odd', 'even')
          str += "'>"
          str += "<ul id='"  
          str += task_board_dom_id(feature, status, 'list')  
          str += "'>"  
             
          str += render(:partial => 'task_boards/_issue.html.erb', :collection => Array(feature.version_children(@version.id).group_by(&:status)[status]), :layout => false  )



          str += "</ul>"  
          str += task_board_drop_receiving_element(task_board_dom_id(feature, status), status)
          str += "</td>"
          <% end %>
=end
          str += "</tr>"
          
          
          
          
          str += get_children(child, color, group + " #{child.id}_p")
        end
      end
      str
  end
  
  
end
