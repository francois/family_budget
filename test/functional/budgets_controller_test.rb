require File.dirname(__FILE__) + "/../test_helper"

class BudgetsControllerTest < ActionController::TestCase
  logged_in_as :quentin do
    should "flunk" do
      flunk
    end
  end

  not_logged_in do
    context "on GET to show" do
      setup do
        get :show
      end

      should_redirect_to "new_session_url"
    end
  end
end
