module Extensions
  module Budgets
    def for_period(year, month)
      find(:all, :conditions => {:year => year, :month => month})
    end
  end
end
