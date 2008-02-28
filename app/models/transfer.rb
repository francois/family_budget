class Transfer < ActiveRecord::Base
  belongs_to :family
  belongs_to :debit_account, :class_name => "Account"
  belongs_to :credit_account, :class_name => "Account"
  validates_presence_of :family_id, :debit_accoun_id, :credit_account_id, :posted_on
end
