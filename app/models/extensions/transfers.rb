module Extensions
  module Transfers
    def all_debits_by_account_year_month(account, year, month)
      this_month = Date.new(year, month, 1)
      next_month = this_month >> 1
      find(:all, :conditions => ["debit_account_id = ? AND posted_on >= ? AND posted_on <= ?", account.id, this_month, next_month], :order => "posted_on")
    end

    def all_credits_by_account_year_month(account, year, month)
      this_month = Date.new(year, month, 1)
      next_month = this_month >> 1
      find(:all, :conditions => ["credit_account_id = ? AND posted_on >= ? AND posted_on <= ?", account.id, this_month, next_month], :order => "posted_on")
    end
  end
end
