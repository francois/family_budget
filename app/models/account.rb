class Account < ActiveRecord::Base
  belongs_to :family
  validates_presence_of :name, :purpose, :family_id

  ValidPurposes = %w(asset liability equity income expense).freeze
  before_validation {|a| a.purpose = a.purpose.downcase unless a.purpose.blank?}
  validates_inclusion_of :purpose, :in => ValidPurposes
end
