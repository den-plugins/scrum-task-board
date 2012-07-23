module Stb
  module MemberPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
    end
  end
  
  module ClassMethods
    
  end

  module InstanceMethods
    def resource_day_capacity(week)
      days = 0
      allocations = resource_allocations

      unless allocations.empty?
        week.each do |day|
          allocation = allocations.detect{ |a| a.start_date <= day && a.end_date >= day}
          if allocation
            locations = [6]
            locations << allocation.location
            locations << 3 if allocation.location == 2 || allocation.location == 1
            holiday = Holiday.find(:all, :conditions => ["event_date=? AND location IN (?)", day, locations])
            if (1..5) === day.wday && holiday.empty?
              div = (allocation.resource_allocation.to_f / 100)
              days += (8 * div)
            end
          end
        end
      end
      days
    end
  end
end
