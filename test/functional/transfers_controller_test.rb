require 'test_helper'

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

    context "on DELETE to /transfers/:id" do
      setup do
        delete :destroy, :id => @transfer.id
      end

      should_redirect_to "transfers_path"
      should_change "families(:beausoleil).transfers.count", :by => -1
    end

    context "attached to a bank transaction" do
      setup do
        @bank_transaction           = families(:beausoleil).bank_transactions.build(:name => "ABC", :bank_account => bank_accounts(:checking), :amount => 100)
        @bank_transaction.fitid     = "J938109"
        @bank_transaction.posted_on = Date.today
        @bank_transaction.save!

        @transfer.bank_transactions << @bank_transaction
      end

      context "on DELETE to /transfers/:id" do
        setup do
          delete :destroy, :id => @transfer.id
        end

        should_redirect_to "transfers_path"
        should_change "families(:beausoleil).transfers.count", :by => -1
        should_change "@bank_transaction.transfers(true).count", :to => 0
      end
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

      context "with bank_transaction that has an auto_account_id" do
        setup do
          @bank_transaction = bank_transactions(:cell_phone_charge)
          @bank_transaction.auto_account = accounts(:movies)
          @bank_transaction.save!
        end

        context "" do
          setup do
            post :create, :transfer => {:bank_transaction_id => [@bank_transaction.id], :debit_account_id => accounts(:cell_phone_service)}
          end

          should_redirect_to("the transfers page") { transfers_path }
          should_change "@bank_transaction.reload.auto_account", :to => nil

          before_should "retrain the transaction" do
            Family.any_instance.expects(:train_classifier).with(equals(@bank_transaction))
          end

          should "debit the cell phone service account" do
            assert_equal accounts(:cell_phone_service), assigns(:transfer).debit_account
          end

          should "credit the credit card account" do
            assert_equal accounts(:credit_card), assigns(:transfer).credit_account
          end
        end
      end

      context "with bank_transaction and debit account" do
        setup do
          post :create, :transfer => {:bank_transaction_id => [bank_transactions(:cell_phone_charge).id], :debit_account_id => accounts(:cell_phone_service)}
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
