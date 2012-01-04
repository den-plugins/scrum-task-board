class TaskBoardsController < ApplicationController
  unloadable
  menu_item :task_board
  layout 'base'
  before_filter :get_project, :authorize, :only => [:index, :show]
  before_filter :set_cache_buster
  before_filter :get_issue, :only => [:update_issue_status, :update_issue, :add_comment, :get_comment]
  before_filter :get_members, :only => [:update_issue_status, :update_issue, :show]

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  def index
#    Rails.cache.delete('cached_features')
#    Rails.cache.delete('cached_tasks')
#    Rails.cache.clear
#    Version.tmp_features = nil
#    Version.tmp_tasks = nil
    if params[:state].nil?
      @versions = @project.versions.all(:conditions => ["state = ?", 2], :order => 'effective_date IS NULL, effective_date DESC')
    else
      conditions = (params[:state] == "4")? nil : ["state = ?", params[:state]]
      @versions = @project.versions.all(:conditions => conditions, :order => 'effective_date IS NULL, effective_date DESC')
    end
  end

  def show
    @show_bugs = params[:show_bugs] ? true : false
    @statuses = IssueStatus.all(:order => "position asc")
    @version = Version.find params[:version_id]
    @teams = CustomField.first(:conditions => "type = 'IssueCustomField' and name = 'Assigned Dev Team'")
    @selected_team = params[:selected_team] ? params[:selected_team] : ""
    @selected_resource = params[:selected_resource] ? params[:selected_resource] : ""
    @board = params[:board]

    if @board.to_i.eql? 1
      @status_grouped = IssueStatusGroup::TASK_GROUPED
      @status_columns = ordered_keys(@status_grouped)

      #modifications start adding of bugs in features selection
      if @show_bugs
        @bugs = @version.bugs
        @bugs.reject!.each do |b|
          b if b.parent and !b.super_parent.bug?
        end
      end
#      if @bugs and Version.tmp_features and Version.tmp_tasks
#        @features = Version.tmp_features
#        @tasks = Version.tmp_tasks
##        @features = Rails.cache.read('cached_features')
##        @tasks = Rails.cache.read('cached_tasks')
#      else
        @features = @version.features
        @tasks = @version.tasks

        @nodata_to_filter = (@features.empty? and @tasks.empty?)? true : false
        unless ["", "All", "Select a team..."].member? @selected_team
          @features = @features.select {|f| not f.custom_values.first(:conditions => "value = '#{@selected_team}'").nil? }
          @tasks.reject!.each { |t| t if !@features.member? t.super_parent }
        end

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
        @features = parented_sort  @features
#        Version.tmp_features = @features
#        Version.tmp_tasks = @tasks
#        Rails.cache.write('cached_features', @features)
#        Rails.cache.write('cached_tasks', @tasks)
#      end
      @tracker = 4
      @featured = (@features.empty? and @tasks.empty?)? false : true
      @error_msg = "There are no Features/Tasks." if not @featured
    elsif @board.to_i.eql? 2
      @status_grouped = IssueStatusGroup::BUG_GROUPED
      @status_columns = ordered_keys(@status_grouped)
      @bugs = @version.bugs
      @descendant_bugs = []
      @nodata_to_filter = (@bugs.empty?)? true : false
      unless ["", "All", "Select a team..."].member? @selected_team
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
        b if !b.version_descendants.empty? or (!b.parent.nil? and b.parent.issue_from.bug?) #and not (b.parent.issue_from.feature? or b.parent.issue_from.task?)
      end

      @bugged = @bugs.empty? ? false : true
      @error_msg = "There are no Bugs." if not @bugged
    end

    @error_msg = "There are no issues for this version." if @version.fixed_issues.empty?
  end

  def update_issue_status
    get_project
    @status = IssueStatus.find(params[:status_id])
    @issue.init_journal(User.current, "")
    @selected_resource = params[:selected_resource] ? params[:selected_resource] : ""

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
        parents.each do |parent|
          unless parent.nil? or parent.feature? #or (params[:board].to_i.eql?(1) and parent.bug?)
            show_bug = {:bug => true} if parent.bug? and params[:board].to_i.eql?(1)
            page.remove dom_id(parent)
            page.insert_html :top, task_board_dom_id(story, parent.status, "list"), :partial => "issue", :object => parent, :locals => show_bug
          else
            page.update_sticky_note dom_id(parent), parent, params[:board].to_i
          end
        end
      end
      show_bug = {:bug => true} if @issue.bug? and params[:board].to_i.eql?(1)
      page.insert_html :bottom, task_board_dom_id(story, @status, "list"), :partial => "issue", :object => @issue, :locals => show_bug
      #page.complete "Element.show('#{task_board_dom_id(story, @status, 'list')}')"
    end
  end

  def update_issue
    #TODO Permissions trapping - view
    get_project
    @issue.init_journal(User.current, '')
    @issue.update_attributes(params[:issue])
    @selected_resource = params[:selected_resource] ? params[:selected_resource] : ""
    @journals = get_journals(@issue)

    parents = @issue.update_parents
    @status_grouped = (params[:board].to_i.eql?(1) ? IssueStatusGroup::TASK_GROUPED : IssueStatusGroup::BUG_GROUPED)

    render :update do |page|
      page.update_sticky_note dom_id(@issue), @issue, params[:board].to_i
      #show_bug = {:bug => true} if @issue.bug? and params[:board].to_i.eql?(1)
      #page.replace_html "chart_panel", :partial => 'show_chart', :locals => {:version => @issue.fixed_version }
      parents.each do |parent|
        if params[:board].to_i.eql? 1
          if parent.version_descendants.present? and !parent.feature? #and !(params[:board].to_i.eql?(1) and parent.bug?)
            show_bug = {:bug => true} if parent.bug? and params[:board].to_i.eql?(1)
            page.remove dom_id(parent)
            page.insert_html :top, task_board_dom_id(parent.task_parent, parent.status, "list"), :partial => "issue", :object => parent, :locals => show_bug
          else
            page.update_sticky_note dom_id(parent), parent, params[:board].to_i
          end
        elsif params[:board].to_i.eql? 2
          story = @issue.super_parent
          page.remove dom_id(parent)
          page.insert_html :top, task_board_dom_id(story, parent.status, "list"), :partial => "issue", :object => parent #, :locals => descendant
        end
      end
    end
  end

  def add_comment
    get_project
    @issue.init_journal(User.current, params[:comment])
    @issue.update_attributes(params[:issue])
    render_comment
  end

  def get_comment
    render_comment
  end

private
  def get_project
    @project = Project.find(params[:id])
  end

  def get_version
    @version = Version.find params[:version_id]
  end

  def get_issue
    @issue = Issue.find(params[:issue_id])
  end

  def get_journals(ticket)
    ticket.journals.find(:all, :include => [:user, :journalized], :conditions => "notes <> ''", :order => "created_on DESC")
  end

  def get_members
    @members = @project.members.find(:all, :include => [:user], :order => "users.firstname ASC")
  end

  def ordered_keys(values)
    values.keys.sort{|x,y| values[x][:order] <=> values[y][:order]}
  end

  def render_comment
    @journals = get_journals(@issue)
    @loaded = true
    render :update do |page|
      page.replace_html "#{@issue.id}_discussion".to_sym, :partial => "discussion", :locals => {:issue => @issue}
      page.replace_html "#{@issue.id}_tip".to_sym, page.task_board_tooltip(@issue, @journals)
    end
  end

  def parented_sort(tasks)
    psorted = tasks.sort_by {|t| -t.children.count }
    sorted = psorted.select {|p| p.parent.nil? && p.children.any?}
    (psorted-sorted).each do |s|
      if s.parent && sorted.include?(s.parent_issue)
        parent_index = sorted.index(s.parent_issue)
        sorted.insert(parent_index + 1, s)
      else
        sorted << s
      end
    end
    sorted
  end
end

