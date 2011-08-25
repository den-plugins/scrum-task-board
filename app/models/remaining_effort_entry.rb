class RemainingEffortEntry < ActiveRecord::Base

  belongs_to :issue
  validates_numericality_of :remaining_effort, :allow_nil => true
  
  before_create :set_default
  
  def set_default
    issue = Issue.find(self.issue.id)
    if remaining_effort.nil?
      if RemainingEffortEntry.find(:all, :conditions => ["issue_id = #{issue.id}"]).present?
        # do not save if remaining_effort is NULL and is not first entry
        return false
      else
        #set the default value, i.e. the estimated_hours
        self.remaining_effort = issue.estimated_hours
      end
    else
      # do not save if value is the same as the latest entry
      return false if remaining_effort == issue.remaining_effort
    end
  end
end
