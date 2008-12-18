require File.dirname(__FILE__) + "/../test_helper"

class BankTransactionsControllerTest < ActionController::TestCase
  logged_in_as :quentin do
    context "on GET to /index" do
      setup do
        get :index
      end

      should_respond_with :success
      should_render_template "index"
      should_respond_with_content_type "text/html"
    end

    context "on DELETE to /bank_transactions/:id.js" do
      setup do
        delete :destroy, :id => bank_transactions(:credit_card_payment), :format => "js"
      end

      should_change "bank_transactions(:credit_card_payment).reload.ignored?", :to => true

      should_respond_with :success
      should_render_template "destroy"
      should_respond_with_content_type "text/javascript"
    end
  end
end
