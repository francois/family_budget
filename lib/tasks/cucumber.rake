$:.unshift(RAILS_ROOT + '/vendor/plugins/cucumber/lib')
require 'cucumber/rake/task'

Cucumber::Rake::Task.new(:features) do |t|
  ENV["RAILS_ENV"] = RAILS_ENV = "test"
  Rake::Task["db:test:prepare"].invoke
  Rake::Task["db:fixtures:load"].invoke
  t.cucumber_opts = "--format pretty"
end
