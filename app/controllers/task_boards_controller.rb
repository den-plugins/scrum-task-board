class TaskBoardsController < ApplicationController
  unloadable
  menu_item :task_board
  
  before_filter :get_project, :authorize, :only => [:index]
  
  def index
  
  end

  def show
    @statuses = IssueStatus.all(:order => "position asc")
    @version = Version.find params[:version_id]
    #unless params[:version_id].nil?
     # @version = Version.find params[:version_id]
  
      #@fixed_issues = @version.fixed_issues
    
    #else #this condition is for the Product Backlogs(issues with no targeted version)
     # get_project
      
      #@fixed_issues = Issue.find(:all, :conditions => {:project_id => @project.id, :fixed_version_id => nil})   
    #end
    puts params[:board].to_i.eql? 1
    puts params[:board]
    puts params[:board].class
    puts 1.class
    
    if params[:board].to_i.eql? 1 
    #This part needs to be optimized 
      @features = @version.features
      @tasks = @version.tasks

      @features.delete_if.each do |f| 
        @tasks << f if not f.children_here?
      end
  
      @tasks.reject!.each do |f|
        unless f.parent.nil?
          p = Issue.find f.parent.issue_from_id
          f if p.fixed_version_id == @version.id and p.feature?
        end
      end
      @featured = @features.empty? ? false : true
      @tasked = @tasks.empty? ? false : true
      @error_msg = "There are no Features/Tasks for this version." if not @featured and not @tasked
    elsif params[:board].to_i.eql? 2
      @bugs = @version.bugs
      
      @bugged = @bugs.empty? ? false : true
      @error_msg = "There are no Bugs for this version." if not @bugged
    else
    
      puts "Actually, there's something very wrong going on here."
    end
    
    @error_msg = "There are no issues for this version." if @version.fixed_issues.empty?
    
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
    
private
  def get_project
    @project = Project.find(params[:id])
  end
      
  def get_version
    @version = Version.find params[:version_id]   
  end
end
