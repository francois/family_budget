require File.dirname(__FILE__) + "/../test_helper"

class TransfersControllerTest < ActionController::TestCase
  def setup
    super
    @transfer = transfers(:checking_to_credit_card)
  end

  logged_in_as :quentin do
    context "on GET to /transfers" do
      setup do
        get :index
      end

      should_respond_with :success
      should_respond_with_content_type "text/html"
      should_render_template "index"
    end

    context "on GET to /transfers/new" do
      setup do
        get :new
      end

      should_respond_with :success
      should_respond_with_content_type "text/html"
      should_render_template "new"
    end

    context "on GET to /transfers/:id/edit" do
      setup do
        get :edit, :id => @transfer.id
      end

      should_respond_with :success
      should_respond_with_content_type "text/html"
      should_render_template "edit"
    end

    context "on POST to /transfers" do
      context "with debit and credit account" do
        setup do
          post :create, :transfer => {:debit_account_id => accounts(:credit_card), :credit_account_id => accounts(:checking), :description => "Pay credit card", :amount => "123.41"}
        end

        should_redirect_to "transfers_path"

        should "assign the correct debit account" do
          assert_equal accounts(:credit_card), assigns(:transfer).debit_account, @response.body
        end

        should "assign the correct credit account" do
          assert_equal accounts(:checking), assigns(:transfer).credit_account, @response.body
        end
      end

      context "with bank_transaction and debit account" do
        setup do
          post :create, :transfer => {:bank_transaction_ids => [bank_transactions(:cell_phone_charge).id], :debit_account_id => accounts(:cell_phone_service)}
        end

        should_redirect_to "transfers_path"

        should "debit the cell phone service account" do
          assert_equal accounts(:cell_phone_service), assigns(:transfer).debit_account
        end

        should "credit the credit card account" do
          assert_equal accounts(:credit_card), assigns(:transfer).credit_account
        end
      end
    end
  end

  not_logged_in do
    context "on GET to /transfers" do
      setup do
        get :index
      end

      should_redirect_to "new_session_path"
    end

    context "on GET to /transfers/:id" do
      setup do
        get :show, :id => 121
      end

      should_redirect_to "new_session_path"
    end

    context "on GET to /transfers/new" do
      setup do
        get :new
      end

      should_redirect_to "new_session_path"
    end

    context "on POST to /transfers" do
      setup do
        post :create, :transfer => {}
      end

      should_redirect_to "new_session_path"
    end

    context "on GET to /transfers/:id/edit" do
      setup do
        get :edit, :id => 1231
      end

      should_redirect_to "new_session_path"
    end

    context "on PUT to /transfers/:id" do
      setup do
        put :update, :id => 1231, :transfer => {}
      end

      should_redirect_to "new_session_path"
    end

    context "on DELETE to /transfers/:id" do
      setup do
        delete :destroy, :id => 1231
      end

      should_redirect_to "new_session_path"
    end
  end
end
