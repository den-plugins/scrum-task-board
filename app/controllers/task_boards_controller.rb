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
    
    else
      find_version_and_project
      
      @fixed_issues = Issue.find(:all, :conditions => {:project_id => @project.id, :fixed_version_id => nil})   
    end
    
    order_issues
    
    if @stories_with_tasks[nil]
      @stories_with_tasks[nil] = @stories_with_tasks[nil].reject {|issue| @stories_with_tasks.keys.include?(issue) }
    end
    
    @parents = []    

    @stories_with_tasks.each do |story, tasks|
      @stories_with_tasks[story] = tasks.group_by(&:status)
      @parents << story
    end
    
    output_lengths "FINAL"
    puts "#############################################/n There are #{@fixed_issues.count} FIXED ISSUES!!!/n#############################################"
    
    puts "|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
    @parents.each {|p| puts p}
    puts "|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
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
      #puts  @issue.parent.nil?
      story = Issue.find @issue.parent.issue_from_id unless @issue.parent.nil? ### fix this, there seems to be a problem here somewhere
      #puts @issue.parent.issue_from_id ### SO THE PROBLEM WAS HERE (thanks, tail -f log/development.log :))
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
    #render_error("There is no current Sprint for this Project") and return unless @version
  end
  
  def order_issues
  
    puts "#############################################/n There are #{@fixed_issues.count} FIXED ISSUES!!!/n#############################################"

    @parents, @children, @alone = [], [], [] 
    
    output_lengths "INITIALIZE"
    
    @fixed_issues.each do |val|
      @parents << val if val.parent.nil? 
      @children << val if not val.parent.nil?
    end
    
    output_lengths "1ST GROUPING"

    @stories_with_tasks = {}
        
    if not @parents.empty?
    
    
    
      #puts "...[   #{@parents.length}   ] issues don't need mama and papa..."
      @parents.reject!.each { |val| @alone << val if val.children.empty? }
      
      output_lengths "REJECT NO CHILDREN"  
      #puts "...[   #{@parents.leputs "|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"ngth}   ] issues don't need mama and papa..."
      
      #@parents.each do |p|
       # @stories_with_tasks[p] = []
        
        #p.children.each { |c| @stories_with_tasks[p] << c  if c.fixed_version == p.fixed_version } #if c.fixed_version == p.fixed_version
        
        #@alone << p if @stories_with_tasks[p].empty?
      #end
      
      @children.each do |c| #iterate through all child tasks
        puts c.parent
        @stories_with_tasks[Issue.find c.parent.issue_from_id] ||= [] #create a parent container if one does not yet exist
        @stories_with_tasks[Issue.find c.parent.issue_from_id] << c #takes care of multiple levels of sub tasking, treats all as parent << child 
      end
      
      @parents.reject!.each do |p|
        @alone << p unless @stories_with_tasks.member? p
        
      end
      
      output_lengths "TRANSFER NO CHILDREN"
      
      #@parents.reject!.each { |val| @alone << val if @stories_with_tasks[val].empty? }
    end

    @stories_with_tasks[nil] = @alone
  end
  
  def output_lengths event
    puts "_______________________________________________________________________________"
    puts event
    puts "@alone     [   #{@alone.count}   ] issues are all alone..."
    puts "@children  [   #{@children.length}   ] issues are looking for mama and papa..."
    puts "@parents   [   #{@parents.length}   ] issues don't need mama and papa..."
    puts "_______________________________________________________________________________"
  end
  
end
