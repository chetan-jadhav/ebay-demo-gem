require "bundler/setup"
require "ebay/search"
require 'webmock/rspec'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
    
  WebMock.disable_net_connect!(allow_localhost: true)
  
  # config.before(:each) do
  #   response_json = File.read("#{Dir.pwd}/spec/ebay/search/api_response.json")    
  #   stub_request(:get, /svcs.ebay.com/).
  #     with(headers: {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
  #     to_return(status: 200, body: response_json)
  # end
end
