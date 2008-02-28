module Extensions
  module Budgets
    def for_account_year_month(account, year, month)
      find_or_initialize_by_account_id_and_year_and_month(account.id, year, month)
    end

    def for_period(year, month)
      find(:all, :conditions => {:year => year, :month => month})
    end
  end
end
