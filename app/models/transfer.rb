class Transfer < ActiveRecord::Base
  belongs_to :family
  validates_presence_of :family_id, :posted_on

  has_many :members, :class_name => "TransferMember", :order => "account_id"

  attr_accessor :from, :with, :amount
end
