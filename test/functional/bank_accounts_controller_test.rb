require 'test_helper'

class BankAccountsControllerTest < ActionController::TestCase
  def setup
    super
    @bank_account = bank_accounts(:checking)
  end

  logged_in_as :quentin do
    context "on GET to /bank_accounts" do
      setup do
        get :index
      end

      should_respond_with :success
      should_render_template "index"
      should_respond_with_content_type "text/html"
    end

    context "on GET to /bank_accounts/:id/edit" do
      setup do
        get :edit, :id => @bank_account.id
      end

      should_respond_with :success
      should_render_template "edit"
      should_respond_with_content_type "text/html"
    end

    context "on GET to /bank_accounts.js" do
      setup do
        get :index, :format => "js"
      end

      should_respond_with :success
      should_render_without_layout
      should_respond_with_content_type "text/javascript"

      should "return the list of bank accounts as JSON" do
        assert_equal families(:beausoleil).bank_accounts.to_json, @response.body
      end
    end

    context "on GET to /bank_accounts/:id.js" do
      setup do
        get :show, :id => @bank_account.id, :format => "js"
      end

      should_respond_with :success
      should_render_without_layout
      should_respond_with_content_type "text/javascript"

      should "return the requested bank account as JSON" do
        assert_equal @bank_account.to_json, @response.body
      end
    end

    context "on PUT to /bank_accounts/:id" do
      setup do
        @account = @bank_account.family.accounts.create!(:purpose => "asset", :name => "Special Purpose")
        put :update, :id => @bank_account.id, :bank_account => {:account => @account.id}
      end

      should_redirect_to "bank_accounts_path"

      should "assign the correct account" do
        assert_equal @account, @bank_account.reload.account
      end
    end

    context "on DELETE to /bank_accounts/:id" do
      setup do
        delete :destroy, :id => bank_accounts(:checking)
      end

      should_redirect_to "bank_accounts_path"
      should_set_the_flash_to /compte 9\*\*\*\*2828 a été détruit/

      should "destroy the bank account" do
        assert_raise ActiveRecord::RecordNotFound do
          bank_accounts(:checking).reload
        end
      end
    end
  end
end
