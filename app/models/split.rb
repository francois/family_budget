require "generator"

class Split
  attr_accessor :family, :account_ids, :amounts, :transfers, :bank_transaction
  attr_reader :errors

  def initialize(params={})
    @transfers, @account_ids, @amounts = [], [], []
    @errors = ActiveRecord::Errors.new(self)
    params.each_pair do |attr, value|
      send("#{attr}=", value)
    end
  end

  def valid?
    errors.clear
    validate
    errors.empty?
  end

  def save!
    raise ActiveRecord::RecordInvalid.new(self) unless save
  end

  def save
    return false unless valid?

    begin
      self.transfers = []
      Transfer.transaction do
        SyncEnumerator.new(accounts, amounts).each do |account_id, amount|
          next if amount.blank?
          self.transfers << transfer = family.transfers.build(:debit_account => family.accounts.find(account_id), :amount => amount)
          transfer.bank_transactions << bank_transaction
          transfer.save!
        end
      end

      true
    rescue ActiveRecord::RecordInvalid
      false
    end
  end

  def accounts
    family.accounts.find_all_by_id(account_ids)
  end

  def validate
    errors.add_on_blank("family")
    errors.add_on_blank("bank_transaction")
    errors.add_on_empty("amounts")
    errors.add_on_empty("account_ids")
  end

  class << self
    # Duck type as an ActiveRecord::Base subclass
    def human_attribute_name(*args)
      ActiveRecord::Base.human_attribute_name(*args)
    end

    # Duck type as an ActiveRecord::Base subclass
    def self_and_descendants_from_active_record
      [self]
    end

    def human_name(options={})
      self.name.underscore
    end
  end
end
