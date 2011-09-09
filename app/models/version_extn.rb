require_dependency 'project'

module VersionExtn
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
    
    def bugs
      narrow_down 1
    end
    
    def features 
      narrow_down 2
    end
    
    def tasks
      narrow_down 4
    end
    
    def narrow_down tracker
      Issue.find(:all, :conditions => ["fixed_version_id = ? AND tracker_id = ?", self.id, tracker], :include => [:status, :assigned_to], :order => 'id ASC')
    end
    
    def bug_count
      selected_issue_count 1
    end
    
    def feature_count
      selected_issue_count 2
    end
    
    def task_count
      selected_issue_count 4
    end
    
    def selected_issue_count tracker
      Issue.count(:all, :select => "id", :conditions => ["fixed_version_id = ? AND tracker_id = ?", self.id, tracker])
    end
    
  end
end

# Add module to Issue
Version.send(:include, VersionExtn)


