require "rails_generator/secret_key_generator"

class AddSaltToExistingFamilies < ActiveRecord::Migration
  def self.up
    generator = Rails::SecretKeyGenerator.new("this is the secret key used for the rails secret generator")
    Family.all.each do |family|
      family.salt = generator.generate_secret
      family.save!
    end
  end

  def self.down
    Family.update_all("salt = NULL")
  end

  class Family < ActiveRecord::Base; end
end
