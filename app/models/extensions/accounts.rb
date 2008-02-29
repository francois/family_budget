module Extensions
  module Accounts
    def all_by_type_and_name
      find(:all, :order => "purpose, name")
    end

    def assets
      find(:all, :conditions => {:purpose => Account::Asset})
    end

    def liabilities
      find(:all, :conditions => {:purpose => Account::Liability})
    end

    def equities
      find(:all, :conditions => {:purpose => Account::Equity})
    end

    def incomes
      find(:all, :conditions => {:purpose => Account::Income})
    end

    def expenses
      find(:all, :conditions => {:purpose => Account::Expense})
    end
  end
end
