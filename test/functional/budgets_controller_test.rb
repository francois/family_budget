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

    context "on PUT to :update setting amount for movies to 20" do
      setup do
        put :update, :budget => {accounts(:movies).id => "20"}
      end

      should_redirect_to("the budget page") { budget_path }
      should "set the budget for movies to 20" do
        period = Date.new(Date.today.year, Date.today.month, 1) >> 1
        budget = families(:beausoleil).budgets.for_account_year_month(accounts(:movies), period.year, period.month).first
        assert_not_nil budget, "Budget not created for movies, year/month"
        assert_equal 20, budget.amount, "Budget amount not set"
      end
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
