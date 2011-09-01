class TaskBoardsController < ApplicationController
  unloadable
  menu_item :task_board
  layout 'base'
  before_filter :get_project, :authorize, :only => [:index, :show]

  def index
    @versions = @project.versions.all(:order => 'effective_date IS NULL, effective_date DESC')
  end

  def show
    @statuses = IssueStatus.all(:order => "position asc")
    @version = Version.find params[:version_id]

    if params[:board].to_i.eql? 1
      @status_grouped = IssueStatusGroup::TASK_GROUPED
      @status_columns = ordered_keys(@status_grouped)
      
      #This part needs to be optimized
      @features = @version.features
      @tasks = @version.tasks

      @tasks.reject!.each do |f|
        if f.version_child?(@version)
          p = f.parent.other_issue(f)
          if p.feature? or p.support?
            f
          elsif p.task? and p.version_child?(@version)
            pp = p.parent.other_issue(p)
            f if pp.feature? or pp.task? or pp.support?
          end
        end
      end
        
      @featured = true
      @error_msg = "There are no Features/Tasks for this version." if @features.empty? and @tasks.empty?
     
    elsif params[:board].to_i.eql? 2
      @status_grouped = IssueStatusGroup::BUG_GROUPED
      @status_columns = ordered_keys(@status_grouped)
      @bugs = @version.bugs
      
      @parent_bugs = @bugs.map do |b|
        b if !b.version_descendants.empty? and b.parent.nil?
      end
      
      # puts @parent_bugs.inspect
      @bugs.reject!.each do |b|
        b if !b.version_descendants.empty? or !b.parent.nil?
      end
      
      @bugged = @bugs.empty? ? false : true
      @error_msg = "There are no Bugs for this version." if not @bugged
    end
    
    @error_msg = "There are no issues for this version." if @version.fixed_issues.empty?

    #    if !@version.effective_date.nil?
    #      @chart_data = BurndownChart.new(@version).data_and_dates
    #    end
  end
  
  def update_issue_status
    get_project
    @status = IssueStatus.find(params[:status_id])
    @issue = Issue.find(params[:issue_id])
    @issue.init_journal(User.current, "Automated status change from the Task Board")

    attrs = {:status_id => @status.id}
    @issue.update_attributes(attrs)
    if @issue.parent
      parent = @issue.parent.other_issue(@issue)
      parent.update_parent_status
    end
    @status_grouped = (params[:board].to_i.eql?(1) ? IssueStatusGroup::TASK_GROUPED : IssueStatusGroup::BUG_GROUPED)

    render :update do |page|
      page.remove dom_id(@issue)
      story = @issue.task_parent unless @issue.parent.nil?
      descendant = {}
      if !story.nil?
        story = story.parent.issue_from if story.bug? and !story.parent.nil?
        descendant = {:descendant => true} unless story.feature?
      end
      page.insert_html :bottom, task_board_dom_id(story, @status, "list"), :partial => "issue", :object => @issue, :locals => descendant
      page.update_sticky_note dom_id(parent), parent
    end
  end
  
  def update_issue
    #TODO Permissions trapping - view
    @issue = Issue.find(params[:id])
    @issue.init_journal(User.current, "Automated issue update from Task Board")
    @issue.update_attributes(params[:issue])
    
    render :update do |page|
      page.update_sticky_note dom_id(@issue), @issue
    end
  end
    
private
  def get_project
    @project = Project.find(params[:id])
  end
      
  def get_version
    @version = Version.find params[:version_id]
  end
  
  def ordered_keys(values)
    values.keys.sort{|x,y| values[x][:order] <=> values[y][:order]}
  end
end
