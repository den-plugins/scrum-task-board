class IssueStatusGroup

#  STATUS_GROUP = ActiveSupport::OrderedHash.new
#  STATUS_GROUP["Todo"] = IssueStatus.all(:conditions => "name = 'New' or name = 'Assigned' ") << "New"
#  STATUS_GROUP["In Progress"] = IssueStatus.all(:conditions => "name = 'In Progress'")
#  STATUS_GROUP["For Verification"] = IssueStatus.all(:conditions => "name = 'Resolved' or name = 'Not a Defect' or name = 'Cannot Reproduce'") << "Resolved"
#  STATUS_GROUP["Feedback"] = IssueStatus.all(:conditions => "name = 'Feedback' or name = 'For Review' or name = 'For Monitoring'") << "Feedback"
#  STATUS_GROUP["Done"] = IssueStatus.all(:conditions => "name = 'Closed'")
  

  BUG_GROUPED = { "Todo" => {:order => 1, :default => IssueStatus.find_by_name("New"), :statuses => IssueStatus.all(:conditions => "name = 'New' or name = 'Assigned' or name = 'Open' or name = 'Reopened'")},
                            "In Progress" => {:order => 2, :default => IssueStatus.find_by_name("In Progress"), :statuses =>  IssueStatus.all(:conditions => "name = 'In Progress'")},
                            "For Verification" => {:order => 3, :default => IssueStatus.find_by_name("Resolved"), :statuses =>  IssueStatus.all(:conditions => "name = 'Resolved' or name = 'Not a Defect' or name = 'Cannot Reproduce'")},
                            "Feedback" => {:order => 4, :default => IssueStatus.find_by_name("Feedback"), :statuses => IssueStatus.all(:conditions => "name = 'Feedback' or name = 'For Review' or name = 'For Monitoring' or name = 'On Hold' or name = 'Deferred' or name = 'Duplicate'")},
                            "Done" => {:order => 5, :default => IssueStatus.find_by_name("Closed"), :statuses =>  IssueStatus.all(:conditions => "name = 'Closed'")}}
                            
  TASK_GROUPED = { "Todo" => {:order => 1, :default => IssueStatus.find_by_name("New"), :statuses => IssueStatus.all(:conditions => "name = 'New' or name = 'Assigned' or name = 'Open' or name = 'Reopened'")},
                            "In Progress" => {:order => 2, :default => IssueStatus.find_by_name("In Progress"), :statuses =>  IssueStatus.all(:conditions => "name = 'In Progress'")},
                            "For Verification" => {:order => 3, :default => IssueStatus.find_by_name("Resolved"), :statuses =>  IssueStatus.all(:conditions => "name = 'Resolved'")},
                            "Feedback" => {:order => 4, :default => IssueStatus.find_by_name("For Review"), :statuses => IssueStatus.all(:conditions => "name = 'For Review' or name = 'On Hold' or name = 'Deferred' or name = 'Duplicate'")},
                            "Done" => {:order => 5, :default => IssueStatus.find_by_name("Closed"), :statuses =>  IssueStatus.all(:conditions => "name = 'Closed'")}}
end
