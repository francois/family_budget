module Extensions
  module Transfers
    def all_debits_by_account_year_month(account, year, month)
      find(:all, :conditions => ["debit_account_id = ? AND posted_on BETWEEN ? AND ?", account.id, Date.new(year, month, 1), Date.new(year, month + 1, 1) - 1], :order => "posted_on")
    end

    def all_credits_by_account_year_month(account, year, month)
      find(:all, :conditions => ["credit_account_id = ? AND posted_on BETWEEN ? AND ?", account.id, Date.new(year, month, 1), Date.new(year, month + 1, 1) - 1], :order => "posted_on")
    end
  end
end
