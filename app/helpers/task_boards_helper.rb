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
    klass += " no_drag" unless issue.version_descendants.empty?
    klass
  end
  
  def select_assigned_to f, issue
    f.select :assigned_to_id, (@project.members.collect {|p| [p.name, p.user.id]}), :selected => (issue.assigned_to.nil? ? '' : issue.assigned_to.id), :include_blank => true
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
  
  def update_sticky_note container, issue
    page.select("#stickynotejs_#{issue.id}").first.update("sticky_note('#{container}', '#{issue.assigned_to_id}', '#{issue.status_id}')")
    page.select("##{container} .current_data .estimate").first.update("#{issue.remaining_effort}")
    page.select("##{container} .current_data .assignee").first.update("#{issue.assigned_to}")
    page.select("##{container} .current_data .status").first.update("#{issue.status}")
    page.select("##{container} .edit").first.update("Edit")
    page[container.to_sym].className = "#{status_classes_for(issue, User.current)} task_board_data #{ task_board_border_class(issue) }" unless issue.feature?
    page.visual_effect(:highlight, "#{container}")
  end
end
