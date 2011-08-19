class TaskBoardsController < ApplicationController
  unloadable
  menu_item :task_board
  layout 'base'
  before_filter :get_project, :authorize, :only => [:index, :show]
  
  def index
  end

  def show
    @statuses = IssueStatus.all(:order => "position asc")
    @version = Version.find params[:version_id]
    #@task_cols = {"Todo" => [], "Assigned" => [],
    #                             "In Progress" => [], "For Verification" => [],
    #                             "Feedback" => [], "Done" => []}
    @task_cols = ActiveSupport::OrderedHash.new
    @task_cols["Todo"] = IssueStatus.all(:conditions => "name = 'New' or name = 'Assigned' ") << "New"
    @task_cols["In Progress"] = IssueStatus.all(:conditions => "name = 'In Progress'")
    @task_cols["For Verification"] = IssueStatus.all(:conditions => "name = 'Resolved' or name = 'Not a Defect' or name = 'Cannot Reproduce'") << "Resolved"
    @task_cols["Feedback"] = IssueStatus.all(:conditions => "name = 'Feedback' or name = 'For Review' or name = 'For Monitoring'") << "Feedback"
    @task_cols["Done"] = IssueStatus.all(:conditions => "name = 'Closed'")

    if params[:board].to_i.eql? 1
      #This part needs to be optimized
      @features = @version.features
      @tasks = @version.tasks
      
      @features.delete_if.each do |f|
        @tasks << f if not f.children_here?
      end

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
      
      #@tasks.reject!.each do |f|
      #  unless f.parent.nil?
      #     #EDIT: check for consistency here (up to 2 levels up)
      #     #Dirty checking...feel free to optimize
      #    p = Issue.find f.parent.issue_from_id
      #      if p.fixed_version_id == @version.id
      #        if p.feature?
      #          f #reject if parent is a feature
      #        elsif p.task? and not p.parent.nil?
      #          pp = Issue.find p.parent.issue_from_id
      #          f if (pp.feature? or pp.task?) and pp.fixed_version.id == @version.id
      #        end               
      #      end
      #  end
      #end
        
      @featured = true
      @error_msg = "There are no Features/Tasks for this version." if @features.empty? and @tasks.empty?
     
    elsif params[:board].to_i.eql? 2
      @bugs = @version.bugs
      
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
    #attrs.merge!(:assigned_to_id => User.current.id) unless @issue.assigned_to_id?
    @issue.update_attributes(attrs)
    
    render :update do |page|
      page.remove dom_id(@issue)
      story = Issue.find @issue.parent.issue_from_id unless @issue.parent.nil?
      page.insert_html :bottom, task_board_dom_id(story, @status, "list"), :partial => "issue", :object => @issue
    end
  end
  
  def update_issue_assigned_to   
    #TODO Permissions trapping - view
    @issue = Issue.find(params[:id])
    @issue.update_attributes(params[:issue])
    puts dom_id(@issue)
    render :update do |page|
      page.select("##{dom_id(@issue)} .edit_here").first.hide
      page.select("##{dom_id(@issue)} .current_data .assignee").first.update("#{@issue.assigned_to}") # replace this with a partial if editing more than one field
      page.select("##{dom_id(@issue)} .edit").first.update("Edit")
      page.select("##{dom_id(@issue)} .current_data").first.show
      page.visual_effect(:highlight, "#{dom_id(@issue)}")
    end
  end
    
private
  def get_project
    @project = Project.find(params[:id])
  end
      
  def get_version
    @version = Version.find params[:version_id]   
  end
end
