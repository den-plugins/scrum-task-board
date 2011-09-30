require 'redmine'
require 'custom_issue_patch'
require 'scrum_alliance/redmine/issue_status_extensions'
require 'scrum_alliance/redmine/project_extensions'

# Dependency loading hell. http://www.ruby-forum.com/topic/166578#new
require 'dispatcher'
Dispatcher.to_prepare do
  Project.class_eval { include ScrumAlliance::Redmine::ProjectExtensions }
  IssueStatus.class_eval { include ScrumAlliance::Redmine::IssueStatusExtensions }
end

Redmine::Plugin.register :scrum_task_board do
  name 'Redmine Task Board plugin'
  author 'Dan Hodos'
  description "Creates a drag 'n' drop task board of the items in the current version and their status"
  version '1.0.0'

  project_module :task_boards do  
    permission :view_task_boards, :task_boards => [:index, :show]
    permission :update_task_boards, :task_boards => :update_status
  end
  
  menu :project_menu, :task_board, {:controller => 'task_boards', :action => 'index'}, :after => :treeview, :caption => 'Task Board'
end

require File.dirname(__FILE__) + '/app/models/issue_extn.rb'
require File.dirname(__FILE__) + '/app/models/version_extn.rb'
