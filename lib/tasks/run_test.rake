desc "Run Test"
task :run_test => :environment do
  # TODO: Fill in rake task for running the test and emailing the HTML report
  sh %{rspec spec/integration/run_test_spec.rb}
end