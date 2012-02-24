class IssueStatusGroup

  #TODO: refactor

  GROUPED = { "Todo" => {:order => 1, :default => IssueStatus.find_by_name("New"),
                                        :statuses => IssueStatus.all(:conditions => "name = 'New' or name = 'Assigned' or name = 'Open' or name = 'Reopened'")},
                            "In Progress" => {:order    => 2, :default => IssueStatus.find_by_name("In Progress"),
                                        :statuses => IssueStatus.all(:conditions => "name = 'In Progress'")},
                            "For Verification" => {:order    => 3, :default => IssueStatus.find_by_name("Resolved"),
                                        :statuses => IssueStatus.all(:conditions => "name = 'Resolved' or name = 'Not a Defect' or name = 'Cannot Reproduce'")},
                            "Done" => {:order    => 5, :default => IssueStatus.find_by_name("Closed"),
                                        :statuses => IssueStatus.all(:conditions => "name = 'Closed'")}
                        }

  # Group Statuses for Bug
  BUG_GROUPED = { "Feedback" => {:order    => 4,
                                        :default => IssueStatus.find_by_name("Feedback"),
                                        :statuses => IssueStatus.all(:conditions => "name = 'Feedback' or name = 'For Review' or name = 'For Monitoring' or name = 'On Hold' or name = 'Deferred' or name = 'Duplicate'")},
                                  }.merge! GROUPED

  # Group Statuses for Task
  TASK_GROUPED = { "Feedback" => {:order    => 4,
                                        :default  => IssueStatus.find_by_name("For Review"),
                                        :statuses => IssueStatus.all(:conditions => "name = 'For Review' or name = 'On Hold' or name = 'Deferred' or name = 'Duplicate'")}
                                   }.merge! GROUPED

end

