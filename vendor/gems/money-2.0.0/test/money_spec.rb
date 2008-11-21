$LOAD_PATH << File.expand_path(File.dirname(__FILE__) + "/../lib")
require 'money/money'

describe Money do
	it "is associated to the singleton instance of VariableExchangeBank by default" do
		Money.new(0).bank.object_id.should == Money::VariableExchangeBank.instance.object_id
	end
	
	specify "#cents returns the amount of cents passed to the constructor" do
		Money.new(200_00, "USD").cents.should == 200_00
	end
	
	it "rounds the given cents to an integer" do
		Money.new(1.00, "USD").cents.should == 1
		Money.new(1.01, "USD").cents.should == 1
		Money.new(1.50, "USD").cents.should == 2
	end
	
	specify "#currency returns the currency passed to the constructor" do
		Money.new(200_00, "USD").currency.should == "USD"
	end
	
	specify "#zero? returns whether the amount is 0" do
		Money.new(0, "USD").should be_zero
		Money.new(0, "EUR").should be_zero
		Money.new(1, "USD").should_not be_zero
		Money.new(10, "YEN").should_not be_zero
		Money.new(-1, "EUR").should_not be_zero
	end
	
	specify "#exchange_to exchanges the amount via its exchange bank" do
		money = Money.new(100_00, "USD")
		money.bank.should_receive(:exchange).with(100_00, "USD", "EUR").and_return(200_00)
		money.exchange_to("EUR")
	end
	
	specify "#exchange_to exchanges the amount properly" do
		money = Money.new(100_00, "USD")
		money.bank.should_receive(:exchange).with(100_00, "USD", "EUR").and_return(200_00)
		money.exchange_to("EUR").should == Money.new(200_00, "EUR")
	end
	
	specify "#== returns true if and only if their amount and currency are equal" do
		Money.new(1_00, "USD").should == Money.new(1_00, "USD")
		Money.new(1_00, "USD").should_not == Money.new(1_00, "EUR")
		Money.new(1_00, "USD").should_not == Money.new(2_00, "USD")
		Money.new(1_00, "USD").should_not == Money.new(99_00, "EUR")
	end
	
	specify "#* multiplies the money's amount by the multiplier while retaining the currency" do
		(Money.new(1_00, "USD") * 10).should == Money.new(10_00, "USD")
	end
	
	specify "#* divides the money's amount by the divisor while retaining the currency" do
		(Money.new(10_00, "USD") / 10).should == Money.new(1_00, "USD")
	end
	
	specify "Money.empty creates a new Money object of 0 cents" do
		Money.empty.should == Money.new(0)
	end
	
	specify "Money.ca_dollar creates a new Money object of the given value in CAD" do
		Money.ca_dollar(50).should == Money.new(50, "CAD")
	end
	
	specify "Money.ca_dollar creates a new Money object of the given value in USD" do
		Money.us_dollar(50).should == Money.new(50, "USD")
	end
	
	specify "Money.ca_dollar creates a new Money object of the given value in EUR" do
		Money.euro(50).should == Money.new(50, "EUR")
	end
	
	specify "Money.add_rate works" do
		Money.add_rate("EUR", "USD", 10)
		Money.new(10_00, "EUR").exchange_to("USD").should == Money.new(100_00, "USD")
	end
end

describe "Actions involving two Money objects" do
	describe "if the other Money object has the same currency" do
		specify "#<=> compares the two objects' amounts" do
			(Money.new(1_00, "USD") <=> Money.new(1_00, "USD")).should == 0
			(Money.new(1_00, "USD") <=> Money.new(99, "USD")).should > 0
			(Money.new(1_00, "USD") <=> Money.new(2_00, "USD")).should < 0
		end
		
		specify "#+ adds the other object's amount to the current object's amount while retaining the currency" do
			(Money.new(10_00, "USD") + Money.new(90, "USD")).should == Money.new(10_90, "USD")
		end
		
		specify "#- substracts the other object's amount from the current object's amount while retaining the currency" do
			(Money.new(10_00, "USD") - Money.new(90, "USD")).should == Money.new(9_10, "USD")
		end
	end
	
	describe "if the other Money object has a different currency" do
		specify "#<=> compares the two objects' amount after converting the other object's amount to its own currency" do
			target = Money.new(200_00, "EUR")
			target.should_receive(:exchange_to).with("USD").and_return(Money.new(300_00, "USD"))
			(Money.new(100_00, "USD") <=> target).should < 0
			
			target = Money.new(200_00, "EUR")
			target.should_receive(:exchange_to).with("USD").and_return(Money.new(100_00, "USD"))
			(Money.new(100_00, "USD") <=> target).should == 0
			
			target = Money.new(200_00, "EUR")
			target.should_receive(:exchange_to).with("USD").and_return(Money.new(99_00, "USD"))
			(Money.new(100_00, "USD") <=> target).should > 0
		end
		
		specify "#+ adds the other object's amount, converted to this object's currency, to this object's amount while retaining its currency" do
			other = Money.new(90, "EUR")
			other.should_receive(:exchange_to).with("USD").and_return(Money.new(9_00, "USD"))
			(Money.new(10_00, "USD") + other).should == Money.new(19_00, "USD")
		end
		
		specify "#- substracts the other object's amount, converted to this object's currency, from this object's amount while retaining its currency" do
			other = Money.new(90, "EUR")
			other.should_receive(:exchange_to).with("USD").and_return(Money.new(9_00, "USD"))
			(Money.new(10_00, "USD") - other).should == Money.new(1_00, "USD")
		end
	end
end
