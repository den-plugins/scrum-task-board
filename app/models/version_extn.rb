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
    
    def bug_count_open
      count_open_issue 1
    end

    def feature_count_open
      count_open_issue 2
    end

    def task_count_open
      count_open_issue 4
    end

    def bug_count_closed
      count_closed_issue 1
    end

    def feature_count_closed
      count_closed_issue 2
    end

    def task_count_closed
      count_closed_issue 4
    end

    def selected_issue_count tracker
      Issue.count(:all, :select => "id", :conditions => ["fixed_version_id = ? AND tracker_id = ?", self.id, tracker])
    end

    def count_open_issue tracker
      Issue.count(:all, :joins => "INNER JOIN issue_statuses ON issue_statuses.id = issues.status_id",
        :conditions => ["issues.fixed_version_id = ? and issues.tracker_id = ? and issue_statuses.is_closed = 'f'", self.id,tracker])
    end

    def count_closed_issue tracker
      Issue.count(:all, :joins => "INNER JOIN issue_statuses ON issue_statuses.id = issues.status_id",
        :conditions => ["issues.fixed_version_id = ? and issues.tracker_id = ? and issue_statuses.is_closed = 't'", self.id,tracker])
    end

    def count_total_estimated_effort
      ee = 0
      estimated_efforts = Issue.find(:all, :conditions => ["fixed_version_id = ?", self.id])
      for estimate_effort in estimated_efforts
        estimate_effort.estimated_hours = 0 if estimate_effort.estimated_hours.nil?
	ee += estimate_effort.estimated_hours
      end
      return ee
    end

    def count_total_remaining_effort
      re = 0.0
      estimated_efforts = Issue.find(:all, :conditions => ["fixed_version_id = ?", self.id])
      for estimate_effort in estimated_efforts
	re += estimate_effort.remaining_effort if !estimate_effort.remaining_effort.nil?
      end
      return re
    end
    
  end
end

# Add module to Issue
Version.send(:include, VersionExtn)


