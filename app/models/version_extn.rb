module VersionExtn
  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      cattr_accessor :tmp_features, :tmp_tasks
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
    
    def narrow_down(tracker)
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
    
    def bug_counter
      "#{issue_check_counter 1,'f'} open / #{issue_check_counter 1,'t'} closed"
    end

    def feature_counter
      "#{issue_check_counter 2,'f'} open / #{issue_check_counter 2,'t'} closed"
    end

    def task_counter
      "#{issue_check_counter 4,'f'} open / #{issue_check_counter 4,'t'} closed"
    end

    def selected_issue_count tracker
      Issue.count(:all, :select => "id", :conditions => ["fixed_version_id = ? AND tracker_id = ?", self.id, tracker])
    end

    def issue_check_counter tracker,tof
      Issue.count_by_sql("SELECT count(issues.id) AS count_id FROM issues INNER JOIN issue_statuses ON issue_statuses.id = issues.status_id WHERE (issues.fixed_version_id = #{self.id} and issues.tracker_id = #{tracker} and issue_statuses.is_closed = '#{tof}') ")
    end

    def total_estimated_effort
      Issue.sum(:estimated_hours, :conditions => "fixed_version_id = #{self.id} AND tracker_id <> 2")
    end

    def total_remaining_effort
      re = 0.0
      end_date = self.completed_on ? self.completed_on.to_date : Date.today
      for estimate_effort in Issue.find_by_sql("SELECT distinct(issues.id) FROM issues LEFT OUTER JOIN remaining_effort_entries ON remaining_effort_entries.issue_id = issues.id WHERE (fixed_version_id = #{self.id} and remaining_effort is not null and tracker_id <> 2 and remaining_effort_entries.created_on <= '#{end_date}')")
       re += estimate_effort.remaining_effort if !estimate_effort.remaining_effort.nil?
      end
      return re
#      Issue.sum(:remaining_effort, :include => [:remaining_effort_entries], :conditions => "fixed_version_id = #{self.id}")
    end
    
  end
end
