require_dependency 'project'

module IssueExtn
  def self.included(base)
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development

    end

  end
  
  module ClassMethods  
    
  end
  
  module InstanceMethods
    
    def version_children
      fixed_children = self.children.delete_if { |c| c unless c.fixed_version_id.eql? self.fixed_version_id }
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
    
    def children_here?
      not self.version_children.empty?
    end

    
  end
end

# Add module to Issue
Issue.send(:include, IssueExtn)


