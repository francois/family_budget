class Transfer < ActiveRecord::Base
  belongs_to :family
  validates_presence_of :family_id, :posted_on
end
