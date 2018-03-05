require 'net/http'
require 'uri'
require 'json'
require 'ebay/search/api/utils'
require 'ebay/search/api/response_error'

module Ebay
  module Search
    class Api
      include Ebay::Search::Api::Utils
      
      attr_accessor :app_name, :keywords, :global_id, :per_page, :mode
      
      # FIXME: Move these constants to configuration file
      SANDBOX_URL = "http://svcs.sandbox.ebay.com/services/search/FindingService/v1".freeze
      PRODUCTION_URL = "http://svcs.ebay.com/services/search/FindingService/v1".freeze
      OPERATION_NAME = { key: 'OPERATION-NAME', value: 'findItemsByKeywords' }
      SERVICE_VERSION = { key: 'SERVICE-VERSION', value: '1.0.0' }
      SECURITY_APPNAME = { key: 'SECURITY-APPNAME' }
      GLOBAL_ID = { key: 'GLOBAL-ID', value: 'EBAY-US' }
      RESPONSE_DATA_FORMAT = { key: "RESPONSE-DATA-FORMAT", value: 'JSON' }
      PER_PAGE = { key: "paginationInput.entriesPerPage", value: 10 }
      KEYWORDS = { key: 'keywords' }
      RETRIES = 3
      
      
      def initialize(options = {})
        @app_name = options[:app_name]
        @keywords = options[:keywords]
        @global_id = options.fetch(:global_id, GLOBAL_ID[:value])
        @per_page = options.fetch(:per_page, PER_PAGE[:value])
        @mode = options.fetch(:mode, 'sandbox')
        @retries = options.fetch(:retries, RETRIES)
      end  
      
      
      ##### request 
      # This function hits ebay API and returns response. Response can be error or a valid data.
      # If error occures it checks if it should retry to hit API again for valid response of return error response.
      # ForbiddenError, GatewayTimeoutError and ServiceUnavailableError are three exceptions which try to hit API again for valid response.
      #
      def request
        begin  
          response = Net::HTTP.get_response(build_uri)
          validate_response(response)
        rescue SocketError => e            
            return build_error_response_body("Please check your network connection and try again.")
        rescue Exception => e      
          retries ||= 0                       
          if retries < @retries && e.retry
            puts "[#{retries}] Retrying to get response. Got error - #{e.message}"
            retries += 1
            retry
          else
            return build_error_response_body(e.message)
          end          
        end
        
        #TODO: Response should be Ruby object instead of JSON
        # =>  check if we can use ActiveModel::Serializer here
        JSON.parse(response.body)
      end
      
            
      ##### fetch method is use as a starting point
      ## options contents 5 parameters
      # (1) app_name: This is the application ID (AppID) for the service consumer. You obtain an AppID by joining the eBay Developers Program. (required parameter)
      # (2) keywords: A search string (required parameter)
      # (3) global_id: The unique identifier for a combination of site, language, and territory. (optional: EBAY-US as default)
      # (4) per_page: Number of items needed for per page (optional: 10 as default)
      # (5) mode: API type want to use. sandbox or production (optional: sandbox as default)
      # (6) retries: Number of retries should be done if request fails to get a response (optional: 3 as default)
      #
      # This function returns JSON object
      #
      # Usage example:
      # options = { mode: 'production', keywords: 'harry potter', app_name: '<Your Application ID >' }
      # response = Ebay::Search::Api.fetch(options)
      #
      def self.fetch(options)
        self.new(options).request
      end          
      
    end
  end
end