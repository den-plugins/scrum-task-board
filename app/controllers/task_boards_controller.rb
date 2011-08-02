class TaskBoardsController < ApplicationController
  unloadable
  menu_item :task_board
  
  before_filter :find_version_and_project, :authorize, :only => [:index]
  
  def index
  
  end
  
  def show
  
    @statuses = IssueStatus.all(:order => "position asc")
  
    unless params[:version_id].nil?
      @version = Version.find params[:version_id]
  
      @fixed_issues = @version.fixed_issues
    
    else #this condition is for the Product Backlogs(issues with no targeted version)
      find_version_and_project
      
      @fixed_issues = Issue.find(:all, :conditions => {:project_id => @project.id, :fixed_version_id => nil})   
    end
    
    order_issues #group issues here
    
    if @stories_with_tasks[nil]
      @stories_with_tasks[nil] = @stories_with_tasks[nil].reject {|issue| @stories_with_tasks.keys.include?(issue) }
    end
    
    #@parents = [] #empty this variable for reuse

    @stories_with_tasks.each do |story, tasks|
      @stories_with_tasks[story] = tasks.group_by(&:status)
      @parents << story #store all parents regardless of level - to be used for checking
    end
  end
  
  def update_issue_status
    @status = IssueStatus.find(params[:status_id])
    @parents = params["parents"]
    
    @issue = Issue.find(params[:id])
    @issue.init_journal(User.current, "Automated status change from the Task Board")

    attrs = {:status_id => @status.id}
    attrs.merge!(:assigned_to_id => User.current.id) unless @issue.assigned_to_id?
    @issue.update_attributes(attrs)
    
    render :update do |page|
      page.remove dom_id(@issue)
      story = Issue.find @issue.parent.issue_from_id unless @issue.parent.nil?
      page.insert_html :bottom, task_board_dom_id(story, @status, "list"), :partial => "issue", :object => @issue
    end
  end
  
  def get_version
    @version = Version.find params[:version_id]
    
  end
  
  
private
  def find_version_and_project
    @project = Project.find(params[:id])
    #@version = @project.current_version // remove this so that taskboard will have an index page to display all versions
  end
  
  def order_issues

    @parents, @children, @alone, @stories = [], [], [], [] 
    
    @fixed_issues.each do |val|
      @stories << val if val.parent.nil? 
      @children << val if not val.parent.nil?
    end

    @stories_with_tasks = {}
        
    if not @stories.empty?
      @stories.reject!.each { |val| @alone << val if val.children.empty? } #pls. recheck - looks like this isn't needed anymore
      
      @children.each do |c| #iterate through all child tasks
        #puts c.parent
        @stories_with_tasks[Issue.find c.parent.issue_from_id] ||= [] #create a parent container if one does not yet exist
        @stories_with_tasks[Issue.find c.parent.issue_from_id] << c #takes care of multiple levels of sub tasking, treats all as parent << child 
      end
      
      @stories.reject!.each do |p|
        @alone << p unless @stories_with_tasks.member? p #parents who have no children in this version will be joining the @alone issues
      end
    end

    @stories_with_tasks[nil] = @alone
  end

end
