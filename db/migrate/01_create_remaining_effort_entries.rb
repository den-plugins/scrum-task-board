class CreateRemainingEffortEntries < ActiveRecord::Migration

  def self.up
    create_table :remaining_effort_entries do |t|
      t.column :issue_id, :integer
      t.column :remaining_effort, :float
      t.column :created_on, :date
    end
  end
  
  def self.down
    drop_table :remaining_effort_entries
  end
  
end
