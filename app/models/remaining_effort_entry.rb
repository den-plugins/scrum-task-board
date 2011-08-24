class RemainingEffortEntry < ActiveRecord::Base

  belongs_to :issue
  validates_presence_of :remaining_effort
end
