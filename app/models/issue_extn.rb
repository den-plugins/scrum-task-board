require_dependency 'project'

module IssueExtn
  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
    end
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
  
    def version_children
      fixed_children = self.children.delete_if { |c| c unless c.fixed_version_id.eql? self.fixed_version_id and !c.support? and !c.bug? }
    end
    
    def bug?
      self.tracker_id.eql? 1
    end
    
    def feature?
      self.tracker_id.eql? 2
    end
     
    def support?
      self.tracker_id.eql? 3
    end
    
    def task?
      self.tracker_id.eql? 4
    end
    
    def version_child?(version)
      not parent.nil? and parent.other_issue(self).fixed_version_id == version.id
    end
    
    def task_parent?
      not version_descendants.empty? and !parent.nil? and parent.other_issue(self).parent.nil?
    end
    
    def task_parent
      return parent.other_issue(self) if parent.other_issue(self).parent.nil? and version_descendants.empty?
      task_parent? ? self : parent.other_issue(self).task_parent
    end
    
    def version_descendants(include_self=false)
      descendants = include_self ? Array(self) : []
      self.children.each do |child|
          descendants << child if child.fixed_version_id == self.fixed_version_id
          descendants += child.version_descendants
      end
      descendants
    end
  end
end

# Add module to Issue
Issue.send(:include, IssueExtn)


