require File.dirname(__FILE__) + "/../test_helper"

class TransactionsControllerTest < ActionController::TestCase
  logged_in_as :quentin do
    context "on GET to /index" do
      setup do
        get :index
      end

      should_respond_with :success
      should_render_template "index"
      should_respond_with_content_type "text/html"
    end
  end
end
