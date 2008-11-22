require 'test_helper'

class DashboardsControllerTest < ActionController::TestCase
  should_route :get, "/", :controller => "dashboards", :action => "show"

  logged_in_as :quentin do
    context "on GET /dashboard" do
      setup do
        get :show
      end

      should_respond_with :success
      should_render_template "show"
    end

    context "" do
      setup do
        @controller.stubs(:current_family).returns(@family = mock("family"))
        @family.stubs(:accounts).returns(@accounts = mock("accounts"))
        @accounts.stubs(:most_active_expense_in_period).with("200709").returns([])
        @accounts.stubs(:most_active_income_in_period).with("200709").returns([])
      end

      context "on GET /dashboard?period=200709" do
        setup do
          get :show, :period => "200709"
        end

        should_respond_with :success
        should_render_template "show"

        before_should "query the most active income accounts for the 200709 period" do
          @accounts.expects(:most_active_income_in_period).with("200709").returns([])
        end

        before_should "query the most active expense accounts for the 200709 period" do
          @accounts.expects(:most_active_expense_in_period).with("200709").returns([])
        end
      end
    end
  end

  not_logged_in do
    context "on GET /dashboard" do
      setup do
        get :show
      end

      should_redirect_to "new_session_path"
    end
  end
end
