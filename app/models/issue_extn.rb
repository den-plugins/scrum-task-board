require_dependency 'project'

module IssueExtn
  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      has_many :remaining_effort_entries
    end
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
  
    def remaining_effort=(value)
      self.remaining_effort_entries.build(:remaining_effort => value, :created_on => Date.today) unless value.nil?
    end
    
    def remaining_effort
      entry = RemainingEffortEntry.find(:last, :conditions => ["issue_id = #{self.id}"]) unless self.new_record?
      return entry.nil? ? nil : entry.remaining_effort
    end
    
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
    
    def children_here?
      not self.version_children.empty?
    end
    
    def version_child?(version)
      not parent.nil? and parent.other_issue(self).fixed_version_id == version.id
    end
    
    def version_descendants(version = nil)
      descendants = []
      self.children.each do |child|
        if version
          descendants << child if child.fixed_version_id == version.id
          descendants += child.version_descendants(version)
        else
          descendants << child
          descendants += child.version_descendants
        end
      end
      descendants
    end
  end
end

# Add module to Issue
Issue.send(:include, IssueExtn)


