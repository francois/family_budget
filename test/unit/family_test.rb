require 'test_helper'

class FamilyTest < ActiveSupport::TestCase
  should_validate_presence_of :name
  should_validate_uniqueness_of :name
  should_not_allow_mass_assignment_of :family_ids, :budget_ids, :people_ids, :salt
  should_have_many :accounts, :budgets, :people, :bank_accounts, :bank_transactions

  context "A new family" do
    setup do
      @family = Family.new(:name => "Katherine")
    end

    should "raise an ArgumentError when calling #encrypt" do
      assert_raise ArgumentError do
        @family.encrypt("a")
      end
    end

    context "on save" do
      setup do
        @family.save!
      end

      should_change "@family.salt"
      should_change "@family.salt", :to => /^[\da-f]{128}$/i

      context "" do
        setup do
          Digest::SHA1.stubs(:hexdigest).returns("the digest string")
        end

        context "calling #encrypt('a', 'b', 'c')" do
          setup do
            @digest = @family.encrypt("a", "b", "c")
          end

          before_should "encrypt using Digest::SHA1#hexdigest" do
            Digest::SHA1.expects(:hexdigest).with("--#{@family.salt}--a--b--c--").returns("abc123")
          end

          should "return the hexdigest" do
            assert_equal "the digest string", @digest
          end
        end
      end

      context "on subsequent save" do
        setup do
          @family.name = "Ekatherina"
          @family.save!
        end

        should_not_change "@family.salt"
      end
    end
  end
end
