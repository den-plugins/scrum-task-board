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
      Issue.count_by_sql("SELECT count(issues.id) AS count_id FROM issues INNER JOIN issue_statuses ON issue_statuses.id = issues.status_id WHERE (issues.fixed_version_id = #{self.id} and issues.tracker_id = #{tracker} and issue_statuses.is_closed = 'f') ")
    end

    def count_closed_issue tracker
      Issue.count_by_sql("SELECT count(issues.id) AS count_id FROM issues INNER JOIN issue_statuses ON issue_statuses.id = issues.status_id WHERE (issues.fixed_version_id = #{self.id} and issues.tracker_id = #{tracker} and issue_statuses.is_closed = 't') ")
    end

    def count_total_estimated_effort
      Issue.sum(:estimated_hours, :conditions => "fixed_version_id = #{self.id}")
    end

    def count_total_remaining_effort
      re = 0.0
      for estimate_effort in Issue.find_by_sql("SELECT id FROM issues WHERE (fixed_version_id = #{self.id}) ")
	re += estimate_effort.remaining_effort if !estimate_effort.remaining_effort.nil?
      end
      return re
    end
    
  end
end

# Add module to Issue
Version.send(:include, VersionExtn)


