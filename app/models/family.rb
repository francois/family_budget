class Family < ActiveRecord::Base
  has_many :people
  has_many :transfers
end
