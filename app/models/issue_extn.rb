require_dependency 'project'

module IssueExtn
  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      has_one :item
      unloadable # Send unloadable so it will not be unloaded in development
    end
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
  
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
    
    def version_child?(version)
      not parent.nil? and parent.issue_from.fixed_version_id == version.id
    end
    
    def task_parent?
      not version_descendants.empty? and !parent.nil? and parent.issue_from.parent.nil? and !feature?
    end
    
    def task_parent
      return parent.issue_from if parent.issue_from.parent.nil? and version_descendants.empty?
      task_parent? ? self : parent.issue_from.task_parent
    end
    
    def super_parent
      parent.nil? ? self : parent.issue_from.super_parent
    end
    
    def version_descendants(include_self=false)
      descendants = include_self ? Array(self) : []
      self.children.each do |child|
          descendants << child if child.fixed_version_id == self.fixed_version_id
          descendants += child.version_descendants
      end
      descendants
    end
  end
  
  def version_descendants_filtered
    descendants = version_descendants(true)
    rejects = []
    descendants.select {|d| d.feature? or d.bug? }.each do |x|
      rejects += (x.task_parent? ? [x] : x.version_descendants(true))
    end
    descendants - rejects
  end

  def version_descendants_bugs
    descendants = version_descendants(true)
    bugs = []
    descendants.select {|d| d.bug? }.each do |x|
      bugs += (x.task_parent? ? [x] : x.version_descendants(true))
    end
    bugs.uniq
  end
  
  def feature_child?
    parent.issue_from.feature?
  end
 
  def if_blocked
    issue = IssueRelation.find(:first, :conditions => ["issue_to_id = ? and relation_type = ?",self.id, 'blocks'])
    issue.relation_type.eql? 'blocks' if !issue.nil?
  end
  
  def update_parents
    parents = []
    unless parent.nil?
      parents << parent_issue
      parents += parent_issue.update_parents
    end
    parents
  end

  def story_points
    pts = custom_values.detect{|x| x.custom_field.name.downcase["story points"]}
    pts ? pts.value.to_f : 0.0
  end

  def story_points=(val)
    pts = custom_values.detect{|x| x.custom_field.name.downcase["story points"]}
    pts.value = val.to_f
    pts.save
  end
end

# Add module to Issue
Issue.send(:include, IssueExtn)
