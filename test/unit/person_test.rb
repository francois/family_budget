require File.dirname(__FILE__) + '/../test_helper'

class PersonTest < ActiveSupport::TestCase
  should_protect_attributes :crypted_password, :salt, :remember_token, :remember_token_expires_at, :family_id, :admin
  should_require_attributes :login, :email, :password, :password_confirmation
  should_require_unique_attributes :login, :email

  context "A person" do
    setup do
      @person = people(:quentin)
    end

    context "updating it's login" do
      setup do
        @old_password_hash = @person.crypted_password
        @person.update_attributes(:login => "bizarro")
      end

      should "authenticate using the new login" do
        assert_equal @person, Person.authenticate("bizarro", "test")
      end

      should "NOT authenticate using the old login" do
        assert_nil Person.authenticate("quentin", "test")
      end

      should "keep the same crypted password" do
        assert_equal @old_password_hash, @person.reload.crypted_password
      end
    end

    context "updating it's password" do
      setup do
        @person.update_attributes(:password => 'new password', :password_confirmation => 'new password')
      end

      should "authenticate using the new password" do
        assert_equal @person, Person.authenticate('quentin', 'new password')
      end

      should "NOT authenticate with the old password" do
        assert_nil Person.authenticate("quentin", "test")
      end
    end
  end

  def test_should_not_rehash_password
    people(:quentin).update_attributes(:login => 'quentin2')
    assert_equal people(:quentin), Person.authenticate('quentin2', 'test')
  end

  def test_should_authenticate_person
    assert_equal people(:quentin), Person.authenticate('quentin', 'test')
  end

  context "A person that is remembered" do
    setup do
      @person = people(:quentin)
      @person.remember_me
      @person.reload
    end

    context "being forgotten" do
      setup do
        @person.forget_me
      end

      should "NOT have a remember_token" do
        assert_nil @person.remember_token
      end

      should "NOT have a remember_token_expires_at" do
        assert_nil @person.remember_token_expires_at
      end

      should "NOT be authenticable using a nil token" do
        assert_nil Person.authenticate(nil)
      end
    end

    should "have a remember_token_expires_at set to 1 week in the future" do
      expires_at = 2.weeks.from_now.utc
      assert_include @person.remember_token_expires_at, ((expires_at - 1.second) .. (expires_at + 1.second))
    end

    should "have a remember_token" do
      assert_not_nil @person.remember_token
    end

    should "authenticate with the correct remember_token" do
      assert_equal @person, Person.authenticate(@person.remember_token)
    end

    should "NOT authenticate when incorrect remember token" do
      assert_nil Person.authenticate(@person.remember_token.succ)
    end

    should "NOT authenticate when the remember token expired" do
      @person.update_attribute(:remember_token_expires_at, 2.weeks.ago.utc)
      assert_nil Person.authenticate(@person.remember_token)
    end
  end
end
