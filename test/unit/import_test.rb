require File.dirname(__FILE__) + "/../test_helper"

class ImportTest < Test::Unit::TestCase
  context "An import" do
    context "referring to a new bank, account and transaction" do
      setup do
        @import = Import.new(:data => qfx(:bankid => "1221", :acctid => "77321812", :fitid => "992381928211"), :family => families(:beausoleil))
      end

      context "calling #process!" do
        setup do
          @import.process!
        end

        should_change "BankAccount.count", :by => 1
        should_change "Transaction.count", :by => 1
      end
    end

    context "referring to an existing bank, account and transaction" do
      setup do
        @import = Import.new(:data => qfx, :family => families(:beausoleil))
      end

      context "calling #process!" do
        setup do
          @import.process!
        end

        should_not_change "BankAccount.count"
        should_not_change "Transaction.count"
      end
    end
  end

  context "A QFX data file example" do
    context "with default options" do
      setup do
        @qfx = qfx
      end

      should "NOT be blank?" do
        assert !@qfx.blank?
      end

      should "contain <BANKID>0912039" do
        assert_include "<BANKID>#{bank_accounts(:checking).bank_number}", @qfx
      end

      should "contain <ACCTID>928192828" do
        assert_include "<ACCTID>#{bank_accounts(:checking).account_number}", @qfx
      end

      should "contain <ACCTTYPE>CHECKING" do
        assert_include "<ACCTTYPE>CHECKING", @qfx
      end

      should "contain <DTSTART>20081102120000" do
        assert_include "<DTSTART>#{qfx_timestamp(transactions(:credit_card_payment).posted_on)}", @qfx
      end

      should "contain <DTEND>20081102120000" do
        assert_include "<DTEND>#{qfx_timestamp(transactions(:credit_card_payment).posted_on)}", @qfx
      end

      should "contain <DTPOSTED>20081102120000" do
        assert_include "<DTPOSTED>#{qfx_timestamp(transactions(:credit_card_payment).posted_on)}", @qfx
      end

      should "contain <FITID>912830912390218299" do
        assert_include "<FITID>912830912390218299", @qfx
      end

      should "contain <TRNAMT>123.12" do
        assert_include "<TRNAMT>#{transactions(:credit_card_payment).amount}", @qfx
      end

      should "contain <NAME>PAYMENT" do
        assert_include "<NAME>#{transactions(:credit_card_payment).name}", @qfx
      end

      should "contain <MEMO>TRANSFER W3 - 0056" do
        assert_include "<MEMO>#{transactions(:credit_card_payment).memo}", @qfx
      end
    end

    context "with bankid option" do
      setup do
        @qfx = qfx(:bankid => "123999")
      end

      should "contain <BANKID>123999" do
        assert_include "<BANKID>123999", @qfx
      end
    end

    context "with acctid option" do
      setup do
        @qfx = qfx(:acctid => "999888")
      end

      should "contain <ACCTID>999888" do
        assert_include "<ACCTID>999888", @qfx
      end
    end

    context "with accttype option" do
      setup do
        @qfx = qfx(:accttype => "SAVINGS")
      end

      should "contain <ACCTTYPE>SAVINGS" do
        assert_include "<ACCTTYPE>SAVINGS", @qfx
      end
    end

    context "with dtstart option" do
      setup do
        @qfx = qfx(:dtstart => Date.new(2008, 10, 31))
      end

      should "contain <DTSTART>20081031000000" do
        assert_include "<DTSTART>20081031000000", @qfx
      end
    end

    context "with dtend option" do
      setup do
        @qfx = qfx(:dtend => Date.new(2008, 11, 2))
      end

      should "contain <DTEND>20081102000000" do
        assert_include "<DTEND>20081102000000", @qfx
      end
    end

    context "with dtposted option" do
      setup do
        @qfx = qfx(:dtposted => Date.new(2008, 11, 3))
      end

      should "contain <DTPOSTED>20081103000000" do
        assert_include "<DTPOSTED>20081103000000", @qfx
      end
    end

    context "with trnamt option" do
      setup do
        @qfx = qfx(:trnamt => "-1312.32")
      end

      should "contain <TRNAMT>-1312.32" do
        assert_include "<TRNAMT>-1312.32", @qfx
      end
    end

    context "with fitid option" do
      setup do
        @qfx = qfx(:fitid => "555777888999566")
      end

      should "contain <FITID>555777888999566" do
        assert_include "<FITID>555777888999566", @qfx
      end
    end

    context "with name option" do
      setup do
        @qfx = qfx(:name => "INTER-ACCOUNT TRANSFER")
      end

      should "contain <NAME>INTER-ACCOUNT TRANSFER" do
        assert_include "<NAME>INTER-ACCOUNT TRANSFER", @qfx
      end
    end

    context "with memo option" do
      setup do
        @qfx = qfx(:memo => "PAYPAL LTD")
      end

      should "contain <MEMO>PAYPAL LTD" do
        assert_include "<MEMO>PAYPAL LTD", @qfx
      end
    end
  end

  protected
  def qfx(options={})
    options.stringify_keys!
    options.reverse_merge!(
      "acctid"   => bank_accounts(:checking).account_number,
      "bankid"   => bank_accounts(:checking).bank_number, 
      "accttype" => "CHECKING",
      "dtstart"  => transactions(:credit_card_payment).posted_on,
      "dtend"    => transactions(:credit_card_payment).posted_on,
      "dtposted" => transactions(:credit_card_payment).posted_on,
      "trnamt"   => transactions(:credit_card_payment).amount.to_s,
      "fitid"    => transactions(:credit_card_payment).fitid,
      "name"     => transactions(:credit_card_payment).name,
      "memo"     => transactions(:credit_card_payment).memo)
    options.each_pair do |key, value|
      next unless key.starts_with?("dt")
      options[key] = qfx_timestamp(value)
    end

    returning(File.read(File.join(Rails.root, "test", "fixtures", "single_transaction.qfx"))) do |data|
      %w(bankid acctid accttype dtposted dtstart dtend fitid trnamt name memo).each do |field|
        data.gsub!("__#{field.upcase}__", options[field]) if options.has_key?(field)
      end
    end
  end

  def qfx_timestamp(value)
    value.to_time.strftime("%Y%m%d%H%M%S")
  end
end
