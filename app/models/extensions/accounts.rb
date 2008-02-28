module Extensions
  module Accounts
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
