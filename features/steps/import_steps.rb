Given /I am on the new import page/ do
  visits "/imports/new"
end

Then /^under "(.*)" I should see "(.*)"$/ do |column, text|
  response.body.should =~ /#{text}/m
end
