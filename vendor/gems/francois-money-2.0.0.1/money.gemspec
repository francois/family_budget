Gem::Specification.new do |s|
  s.name = "francois-money"
  s.version = "2.0.0.1"
  s.summary = "Money and currency exchange support library"
  s.email = "hongli@phusion.nl"
  s.homepage = "http://money.rubyforge.org/"
  s.description = "Money and currency exchange support library."
  s.has_rdoc = true
  s.rubyforge_project = "money"
  s.authors = ["Tobias Luetke", "Hongli Lai"]
  
  s.files = [
      "README.rdoc", "MIT-LICENSE", "money.gemspec", "Rakefile",
      "lib/money.rb",
      "lib/money/core_extensions.rb",
      "lib/money/errors.rb",
      "lib/money/money.rb",
      "lib/money/variable_exchange_bank.rb",
      "test/core_extensions_spec.rb",
      "test/exchange_bank_spec.rb",
      "test/money_spec.rb"
  ]
end
