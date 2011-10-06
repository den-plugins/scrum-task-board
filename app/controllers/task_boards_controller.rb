class TaskBoardsController < ApplicationController
  unloadable
  menu_item :task_board
  layout 'base'
  before_filter :get_project, :authorize, :only => [:index, :show]

  def index
    @versions = @project.versions.all(:order => 'effective_date IS NULL, effective_date DESC')
  end

  def show
    @condensed = params[:condensed] ? true : false
    @statuses = IssueStatus.all(:order => "position asc")
    @version = Version.find params[:version_id]
    @teams = CustomField.first(:conditions => "type = 'IssueCustomField' and name = 'Assigned Dev Team'")
    @selected_team = params[:selected_team] ? params[:selected_team] : ""
    @board = params[:board]

    if @board.to_i.eql? 1
      @status_grouped = IssueStatusGroup::TASK_GROUPED
      @status_columns = ordered_keys(@status_grouped)
      
      #This part needs to be optimized
      @features = @version.features #.select {|f| f.parent.nil?}
      @tasks = @version.tasks
      @nodata_to_filter = (@features.empty? and @tasks.empty?)? true : false
      unless ["", "All", "---select a team---"].member? @selected_team
        @features = @features.select {|f| not f.custom_values.first(:conditions => "value = '#{@selected_team}'").nil? }
        @tasks.reject!.each { |t| t if !@features.member? t.super_parent }
      end
      #@all_issues = (@tasks).compact.map {|i| i.id}
      @tracker = 4
      @tasks.reject!.each do |f|
        if f.version_child?(@version)
          p = f.parent.issue_from
          if p.feature? or p.support?
            f
          elsif p.task? and p.version_child?(@version)
            pp = p.parent.issue_from
            f if pp.feature? or pp.task? or pp.support?
          end
        end
      end
        
      @featured = (@features.empty? and @tasks.empty?)? false : true
      @error_msg = "There are no Features/Tasks." if not @featured
    elsif @board.to_i.eql? 2
      @status_grouped = IssueStatusGroup::BUG_GROUPED
      @status_columns = ordered_keys(@status_grouped)
      @bugs = @version.bugs
      @descendant_bugs = []
      @nodata_to_filter = (@bugs.empty?)? true : false
      unless ["", "All", "---select a team---"].member? @selected_team
        @bugs = @bugs.select {|b| not b.custom_values.first(:conditions => "value = '#{@selected_team}'").nil? }
        #@descendant_bugs = @bugs.map { |b| b.version_descendants }.flatten
         @team = @selected_team
      end
      #@all_issues = (@descendant_bugs + @bugs).map {|i| i.id}
      @tracker = 1
      @parent_bugs = @bugs.map do |b|
        b if !b.version_descendants.empty? and b.parent.nil?
      end
      
      #puts @parent_bugs.inspect
      @bugs.reject!.each do |b|
        b if !b.version_descendants.empty? or !b.parent.nil? #and not (b.parent.issue_from.feature? or b.parent.issue_from.task?)
      end
      
      @bugged = @bugs.empty? ? false : true
      @error_msg = "There are no Bugs." if not @bugged
    end
    
    @error_msg = "There are no issues for this version." if @version.fixed_issues.empty?
  end
  
  def update_issue_status
    get_project
    @status = IssueStatus.find(params[:status_id])
    @issue = Issue.find(params[:issue_id])
    @issue.init_journal(User.current, "")
    @condensed = params[:condensed] ? true : false

    attrs = {:status_id => @status.id}
    @issue.update_attributes(attrs)
    parents = @issue.update_parents
    
    @status_grouped = (params[:board].to_i.eql?(1) ? IssueStatusGroup::TASK_GROUPED : IssueStatusGroup::BUG_GROUPED)
    
    render :update do |page|
      page.remove dom_id(@issue)
      story = @issue.feature_child? ? @issue.parent.issue_from : @issue.task_parent unless @issue.parent.nil?
      story = nil if @issue.parent.nil? or (!@issue.parent.nil? and @issue.parent.issue_from.fixed_version_id != @issue.fixed_version_id)
      descendant = {}

      if !story.nil?
        story = story.parent.issue_from if story.bug? and !story.parent.nil?
        descendant = {:descendant => true} unless story.feature?
        parents.each do |parent|
          unless parent.nil? or parent.feature?
            page.remove dom_id(parent)
            page.insert_html :top, task_board_dom_id(story, parent.status, "list"), :partial => "issue", :object => parent, :locals => descendant
          else
            page.update_sticky_note dom_id(parent), parent
          end
        end
      end
      page.insert_html :bottom, task_board_dom_id(story, @status, "list"), :partial => "issue", :object => @issue, :locals => descendant
    end
  end
  
  def update_issue
    #TODO Permissions trapping - view
      get_project
    @issue = Issue.find(params[:issue_id])
    @issue.init_journal(User.current, '')
    @issue.update_attributes(params[:issue])
    
    parents = @issue.update_parents
    @status_grouped = (params[:board].to_i.eql?(1) ? IssueStatusGroup::TASK_GROUPED : IssueStatusGroup::BUG_GROUPED)
    
    render :update do |page|
      page.update_sticky_note dom_id(@issue), @issue
      #page.replace_html "chart_panel", :partial => 'show_chart', :locals => {:version => @issue.fixed_version }
      parents.each do |parent|
        if params[:board].to_i.eql? 1
          if parent.version_descendants.present? and !parent.feature?
            descendant = {:descendant => true} unless parent.feature?
            page.remove dom_id(parent)
          else
            page.update_sticky_note dom_id(parent), parent
          end
        elsif params[:board].to_i.eql? 2
          story = @issue.super_parent
          page.remove dom_id(parent)
          page.insert_html :top, task_board_dom_id(story, parent.status, "list"), :partial => "issue", :object => parent, :locals => descendant
        end
      end
    end
  end

  def add_comment
    get_project
    @issue = Issue.find(params[:issue_id])
    @issue.init_journal(User.current, params[:comment])
    @issue.update_attributes(params[:issue])
    render :update do |page|
      page.replace_html "#{@issue.id}_discussion".to_sym, :partial => "discussion", :locals => {:issue => @issue}
      page.replace_html "#{@issue.id}_tip".to_sym, page.task_board_tooltip(@issue)
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
