require 'redmine'
require 'custom_issue_patch'
require 'stb_member_patch'
require 'scrum_alliance/redmine/issue_status_extensions'
require 'scrum_alliance/redmine/project_extensions'

this_file = File.dirname(__FILE__)
require this_file + '/install_assets'
Dir[this_file + '/../app/helpers/*.rb'].each {|file| require file }
Dir[this_file + '/../app/controllers/*.rb'].each {|file| require file }
Dir[this_file + '/../app/models/*.rb'].each {|file| require file }

Member.send(:include, Stb::MemberPatch)
Version.send(:include, VersionExtn)
Issue.send(:include, IssueExtn)
Project.class_eval { include ScrumAlliance::Redmine::ProjectExtensions }
IssueStatus.class_eval { include ScrumAlliance::Redmine::IssueStatusExtensions }

ActionView::Base.send(:include, TaskBoardsHelper)
ActionController::Base.prepend_view_path File.dirname(__FILE__) + "/../app/views"

Redmine::Plugin.register :scrum_task_board do
  name 'Redmine Task Board plugin'
  author 'Dan Hodos'
  description "Creates a drag 'n' drop task board of the items in the current version and their status"
  version '1.0.0'

  project_module :task_boards do  
    permission :view_task_boards, :task_boards => [:index, :show, :init_distribution_summary]
    permission :update_task_boards, :task_boards => :update_status
  end
  
  menu :project_menu, :task_board, {:controller => 'task_boards', :action => 'index'}, :after => :treeview, :caption => 'Task Board'
end
