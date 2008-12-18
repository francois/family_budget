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

    context "with a bank transaction that's been ignored" do
      setup do
        bank_transactions(:credit_card_payment).ignore!
      end

      context "on PUT to /bank_transactions/:id.js" do
        setup do
          put :update, :id => bank_transactions(:credit_card_payment).id, :format => "js", :bank_transaction => {:ignored_at => ""}
        end

        should_change "bank_transactions(:credit_card_payment).reload.ignored?", :to => false

        should_respond_with :success
        should_render_template "update"
        should_respond_with_content_type "text/javascript"
      end
    end

    context "on DELETE to /bank_transactions/:id.js" do
      setup do
        delete :destroy, :id => bank_transactions(:credit_card_payment).id, :format => "js"
      end

      should_change "bank_transactions(:credit_card_payment).reload.ignored?", :to => true

      should_respond_with :success
      should_render_template "destroy"
      should_respond_with_content_type "text/javascript"
    end
  end
end
