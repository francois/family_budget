require File.dirname(__FILE__) + "/../test_helper"

class SplitTest < Test::Unit::TestCase
  context "A split" do
    setup do
      @split = Split.new(:family => families(:beausoleil), :bank_transaction => bank_transactions(:cell_phone_charge))
    end

    context "with an account id and an amount" do
      setup do
        @split.account_ids = [accounts(:cell_phone_service)]
        @split.amounts = ["13.99"]
      end

      context "on save" do
        setup do
          @split.save!
        end

        should_change "families(:beausoleil).transfers.count", :by => 1
      end

      context "missing the family" do
        setup do
          @split.family = nil
        end

        should "raise an ActiveRecord::RecordInvalid on save" do
          assert_raise ActiveRecord::RecordInvalid do
            @split.save!
          end
        end
      end

      context "missing the bank_transaction" do
        setup do
          @split.bank_transaction = nil
        end

        should "raise an ActiveRecord::RecordInvalid on save" do
          assert_raise ActiveRecord::RecordInvalid do
            @split.save!
          end
        end
      end
    end

    context "with an account id but an empty amount value" do
      setup do
        @split.account_ids = [accounts(:cell_phone_service)]
        @split.amounts = [""]
      end

      context "on save" do
        setup do
          @split.save!
        end

        should_not_change "families(:beausoleil).transfers.count"
      end
    end

    context "with no account ids and no amounts" do
      context "on save" do
        setup do
          @split.save!
        end

        should_not_change "families(:beausoleil).transfers.count"
      end
    end
  end
end
