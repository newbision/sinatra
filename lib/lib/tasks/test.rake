namespace :test do
	task :default => 'test:all'

	desc "Run All Tests"
	task :all => [:acceptance, :integration, :unit] do

	end

	desc "Run Acceptance Tests"
	task :acceptance do
		puts "Running Acceptance Tests"
		load "./test/acceptance/acceptance_tests.rb"
	end
	
	desc "Run Integration Tests"
	task :integration do
		puts "Running Integration Tests"
		load "./test/integration/integration_tests.rb"
	end
	
	desc "Run Unit Tests"
	task :unit do
		puts "Running Unit Tests"
		load "./test/unit/unit_tests.rb"
	end
end