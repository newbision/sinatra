Gem::Specification.new do |s|
  s.name        = 'base-sinatra'
  s.version     = '1.0.7'
  s.date        = '2016-07-12'
  s.summary     = "Base MVC"
  s.description = "Base MVC"
  s.authors     = ["Ruslan Sliz"]
  s.email       = 'slizr88@gmail.com'
  s.files       = ["lib/app.rb"]
  s.homepage    =''
  s.license     = ''

  s.add_runtime_dependency "sinatra"
  s.add_runtime_dependency "sinatra-contrib"
  s.add_runtime_dependency "sinatra-cache"
  s.add_runtime_dependency "sinatra-cacher"
  s.add_runtime_dependency "rack-abstract-format"
  s.add_runtime_dependency "nokogiri"
  s.add_runtime_dependency "activesupport"
  s.add_runtime_dependency "puma"
  s.add_runtime_dependency "minitest"
  s.add_runtime_dependency "rack-test"
  s.add_runtime_dependency "capybara"
  s.add_runtime_dependency "minitest-capybara"
  s.add_runtime_dependency "rack-allocation_stats"
  s.add_runtime_dependency "sinatra-reloader"
  s.add_runtime_dependency "sys-cpu"
  s.add_runtime_dependency "dalli"
  s.add_runtime_dependency "connection_pool"
end