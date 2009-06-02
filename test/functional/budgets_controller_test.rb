require 'test_helper'

class BudgetsControllerTest < ActionController::TestCase
  logged_in_as :quentin do
    context "on GET to :show" do
      setup do
        get :show
      end

      should_respond_with :success
      should_render_template "show"
      should_render_a_form
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
