require File.dirname(__FILE__) + "/../test_helper"

class PeopleControllerTest < ActionController::TestCase
  not_logged_in do
    context "on POST to /people" do
      setup do
        post :create, :family => {:name => "Hills"}, :person => {:login => "francois", :email => "francois@example.com", :password => "password", :password_confirmation => "password"}
      end

      should_redirect_to "root_url"
      should_change "Family.count", :by => 1
      should_change "Person.count", :by => 1
    end
  end

  logged_in_as :quentin do
    context "on POST to /people" do
      setup do
        post :create, :family => {:name => "Hills"}, :person => {:login => "francois", :email => "francois@example.com", :password => "password", :password_confirmation => "password"}
      end

      should_redirect_to "root_url"
      should_not_change "Family.count"
      should_change "families(:beausoleil).people.count", :by => 1
    end
  end
end
