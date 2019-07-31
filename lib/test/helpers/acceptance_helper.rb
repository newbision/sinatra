ENV['RACK_ENV'] = 'test'

require_relative '../../app' # app is the name of your app file

# These two lines are optional but make your other files cleaner
require 'bundler'
Bundler.require

require 'rack/test'
require 'minitest/autorun' # optional but makes life easier
#require 'capybara'
require 'capybara/dsl'

Capybara.app = Pumatra # the name of your app class
Capybara.register_driver :rack_test do |app|
  Capybara::RackTest::Driver.new(app, :headers =>  { 'User-Agent' => 'Capybara' })
end