module TaskBoardsHelper
  def status_classes_for(issue, user)
    statuses = issue.new_statuses_allowed_to(user)-[issue.status]
    status_class_names = statuses.map {|status| status.class_name }
    status_class_names.join(' ')
  end

  def task_board_drop_receiving_element(dom_id, status, statuses)
    drop_receiving_element(dom_id,
      :accept => statuses.collect {|s| s.class_name},
      :hoverclass => 'hovered',
      :url => {:controller => 'task_boards', :action => 'update_issue_status', :selected_resource => @selected_resource, 
      :condensed => (@condensed ? @condensed : nil)},
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
    klass += " no_drag" if !issue.version_descendants.empty? or issue.feature?
    klass
  end
  
  def select_assigned_to f, issue
    members = @project.members.find(:all, :include => [:user], :order => "users.firstname ASC")
    f.select :assigned_to_id, (members.collect {|p| [p.name, p.user.id]}), :selected => (issue.assigned_to.nil? ? '' : issue.assigned_to.id), :include_blank => true
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
  
  def update_sticky_note container, issue, board=nil
    if issue.feature?
      page.replace_html "#{container}", :partial => 'feature', :locals => {:feature => issue } 
      classname = "task_board_data #{ task_board_border_class(issue) } assigned_to_#{issue.assigned_to_id} task_board_feature_parent"
    else
      page.replace_html "#{container}", :partial => 'issue_show', :locals => {:issue => issue}
      classname = "#{status_classes_for(issue, User.current)} task_board_data assigned_to_#{issue.assigned_to_id} #{ task_board_border_class(issue) } "
    end
    if issue.assigned_to.eql? User.current
      classname += '_' if issue.feature?
      classname += 'current_is_assigned'
    end
    if board and issue.bug? and board.eql?(1)
      classname += " isBug"
    end
    page[container.to_sym].className = classname
    page.visual_effect(:highlight, "#{container}")
  end
  
  def task_board_tooltip(ticket)
    content = "<strong>#{l(:field_subject)}</strong>: #{ticket.subject}<br />" +
    "<strong>#{l(:field_description)}</strong>: #{ticket.description}<br />" +
    "<strong>#{l(:field_assigned_to)}</strong>: #{ticket.assigned_to}<br />" +
    ((ticket.feature? or ticket.children.any?) ? "" : "<strong>#{l(:field_estimated_hours)}</strong>: #{ticket.estimated_hours ? ticket.estimated_hours : 0} #{l(:field_sp_hours)}<br />") +
    ((ticket.feature? or ticket.children.any?) ? "" : "<strong>#{l(:field_remaining_effort)}</strong>: #{ticket.remaining_effort ? ticket.remaining_effort : 0} #{l(:field_sp_hours)}<br />") +
    "<strong>#{l(:field_comments)}</strong>: <br /> <ul>"
    journals = get_journals(ticket).take(5)
    journals.reverse.each do |j|
      content += "<li style='padding-left: 4px; margin: 0;'>&raquo; #{j.notes}</li>"
    end
    content += "</ul>"
  end

  def get_journals(ticket)
    ticket.journals.find(:all, :include => [:user], :conditions => "notes <> ''", :order => "created_on DESC")
  end

end
