require "spec_helper"
require 'json'


RSpec.describe Ebay::Search::Api do
  
  before :all do
    response_json = File.read("#{Dir.pwd}/spec/ebay/search/api_response.json")    
    stub_request(:get, /svcs.ebay.com/).
      with(headers: {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
      to_return(status: 200, body: response_json)
  end
  
  
  it "#fetch method should return a valid response" do
    options = { mode: 'production', keywords: 'harry potter', app_name: 'ParamiSo-dda7-47aa-97ca-b4118e6d5df2' }
    raw_response_file = File.read("#{Dir.pwd}/spec/ebay/search/api_response.json")
    raw_response_file = JSON.parse(raw_response_file)
    expect(Ebay::Search::Api.fetch(options)).to eq(raw_response_file)
    
  end
end
