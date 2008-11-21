require 'test_helper'

class SplitsControllerTest < ActionController::TestCase
  logged_in_as :quentin do
    context "on GET to /splits/:id/edit" do
      setup do
        get :edit, :id => bank_transactions(:credit_card_payment)
      end

      should_respond_with :success
      should_render_template "edit"
    end

    context "on PUT to /splits/:id" do
      setup do
        put :update, :id => bank_transactions(:credit_card_payment), :split => {:amount => ["41.91"], :account_id => [accounts(:cell_phone_service).id]}
      end

      should_redirect_to "bank_transactions_path"
      should_change "families(:beausoleil).transfers.count", :by => 1
      should_set_the_flash_to /1 transferts/
    end
  end

  not_logged_in do
    context "on GET to /splits/:id/edit" do
      setup do
        get :edit, :id => 1234
      end

      should_redirect_to "new_session_path"
    end
  end
end
