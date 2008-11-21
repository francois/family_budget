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
      should_assign_to :top_expenses, :sum_of_expenses, :top_incomes, :sum_of_incomes
    end

    context "on GET /dashboard?period=200709" do
      setup do
        get :show, :period => "200709"
      end

      should_respond_with :success
      should_render_template "show"
      should_assign_to :top_expenses, :sum_of_expenses, :top_incomes, :sum_of_incomes

      before_should "query the 200709 period" do
        Account.expects(:in_period).with("200709").returns(Account)
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
