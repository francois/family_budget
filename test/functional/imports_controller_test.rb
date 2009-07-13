require "test_helper"

class ImportsControllerTest < ActionController::TestCase
  logged_in_as :quentin do
    context "Given an import with no transactions left" do
      setup do
        @family      = families(:beausoleil)
        @import      = @family.imports.create!
      end

      context "on GET to :show" do
        setup do
          get :show, :id => @import.id
        end

        should_redirect_to("the transactions processing page") { bank_transactions_path }
      end
    end

    context "Given three transactions from a single import" do
      setup do
        @family      = families(:beausoleil)
        @import      = @family.imports.create!

        @bt_cell     = @family.bank_transactions.create!( :import => @import, :name => "AT&T",             :fitid => "91283",
                                                          :posted_on => 13.days.ago, :bank_account => bank_accounts(:checking),
                                                          :amount => "-65.93")
        @bt_cell.update_attribute(:auto_account, accounts(:cell_phone_service))

        @bt_groceries = @family.bank_transactions.create!(:import => @import, :name => "Groceries & More", :fitid => "29138",
                                                          :posted_on => 1.days.ago,  :bank_account => bank_accounts(:checking),
                                                          :amount => "-13.22")
        @bt_groceries.update_attribute(:auto_account, accounts(:salary))

        @bt_unknown  = @family.bank_transactions.create!( :import => @import, :name => "Massages & More",  :fitid => "934819",
                                                          :posted_on => 1.days.ago,  :bank_account => bank_accounts(:checking),
                                                          :amount => "-13.21")
      end

      context "on GET to :show" do
        setup do
          get :show, :id => @import.id
        end

        should_respond_with :success
        should_render_template "show"

        should "NOT show @bt_unknown" do
          assert_does_not_contain assigns(:bank_transactions).values.flatten, @bt_unknown
        end
      end

      context "on DELETE to :destroy with :bank_transaction_id" do
        setup do
          delete :destroy, :id => @import.id, :bank_transaction_id => @bt_groceries.id
        end

        should_redirect_to("the import page") { import_url(@import) }
        should_not_change "Transfer.count"
        should_not_change "@bt_groceries.reload.transfers.count"

        should_change "@bt_groceries.reload.auto_account",    :to => nil
      end

      context "on PUT to :update with :bank_transaction_id" do
        setup do
          put :update, :id => @import.id, :bank_transaction_id => @bt_groceries.id
        end

        should_redirect_to("the import page") { import_url(@import) }
        should_change "Transfer.count",                       :by => 1
        should_change "@bt_groceries.reload.transfers.count", :by => 1
        should_change "@bt_groceries.reload.auto_account",    :to => nil
      end

      context "on PUT to :update with :account_id" do
        setup do
          put :update, :id => @import.id, :account_id => accounts(:cell_phone_service).id
        end

        should_redirect_to("the import page") { import_url(@import) }
        should_change "Transfer.count",                  :by => 1
        should_change "@bt_cell.reload.transfers.count", :by => 1
        should_change "@bt_cell.reload.auto_account",    :to => nil
      end
    end
  end
end
