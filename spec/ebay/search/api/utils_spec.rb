require "ebay/search"

RSpec.describe Ebay::Search::Api::Utils do
  
  it "#base_url should return proper api url for sandbox" do
    response_json = File.read("#{Dir.pwd}/spec/ebay/search/api_response.json")    
    stub_request(:get, /svcs.ebay.com/).
      with(headers: {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
      to_return(status: 200, body: response_json)
    
    options = { mode: 'sandbox', keywords: 'harry potter', app_name: 'ParamiSo-dda7-47aa-97ca-b4118e6d5df2' }
    @api = Ebay::Search::Api.new(options)
    
    sandbox_url = "http://svcs.sandbox.ebay.com/services/search/FindingService/v1"
    expect(@api.base_url).to eq(sandbox_url)
  end
  
  it "#base_url should return proper api url for production" do
    response_json = File.read("#{Dir.pwd}/spec/ebay/search/api_response.json")    
    stub_request(:get, /svcs.ebay.com/).
      with(headers: {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
      to_return(status: 200, body: response_json)
    
    options = { mode: 'production', keywords: 'harry potter', app_name: 'ParamiSo-dda7-47aa-97ca-b4118e6d5df2' }
    @api = Ebay::Search::Api.new(options)
    
    sandbox_url = "http://svcs.ebay.com/services/search/FindingService/v1"
    expect(@api.base_url).to eq(sandbox_url)
  end
  
end
