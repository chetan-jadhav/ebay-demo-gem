require 'ebay/search/api/response_error'

module Ebay
  module Search
    class Api
      module Utils
        
        #### #validate_params
        # Check if values passed are valid
        def validate_params!
          validate_keyword!
          validate_app_name!
        end
        
        ##### #build_uri
        # this method responsible for building a whole API url, which is base url and url params
        def build_uri
          URI.parse(base_url + "?" + query_params)
        end
        
        
        ##### #base_url
        # based on the mode passed to this method it returns production's base url or sandbox's base url
        def base_url
          self.mode == 'production' ? Ebay::Search::Api::PRODUCTION_URL : Ebay::Search::Api::SANDBOX_URL
        end
        
        
        ##### #validate_keyword
        # Raise exception if keyword is not exists or blank         
        def validate_keyword!
          raise ResponseError::ArgumentError.new("Search keyword is missing") if self.keywords.nil?
          raise ResponseError::ArgumentError.new("Search keyword is blank") if self.keywords.empty?
        end
        
        
        ##### #validate_app_name
        # Raise exception if app_name is not exists or blank (app_name is Application Id)
        def validate_app_name!
          raise ResponseError::ArgumentError.new("Application ID is missing") if self.app_name.nil?
          raise ResponseError::ArgumentError.new("Application ID is blank") if self.app_name.empty?
        end
        
        
        #### #extact_error_message
        # this method extract message from API's error response
        def extact_error_message(body)
          error_response = JSON.parse(body)
          error_response["errorMessage"][0]["error"][0]["message"][0] rescue "Unexpected error occured!"
        end
        
        
        #### #query_params
        # this method is responsible for making hash of parameters required by eBay's search API
        # and also returns url params
        def query_params
          validate_params!
          
          qargs = {
            Ebay::Search::Api::OPERATION_NAME[:key] => Ebay::Search::Api::OPERATION_NAME[:value],
            Ebay::Search::Api::SERVICE_VERSION[:key] => Ebay::Search::Api::SERVICE_VERSION[:value],
            Ebay::Search::Api::SECURITY_APPNAME[:key] => self.app_name,
            Ebay::Search::Api::GLOBAL_ID[:key] => self.global_id,
            Ebay::Search::Api::RESPONSE_DATA_FORMAT[:key] => Ebay::Search::Api::RESPONSE_DATA_FORMAT[:value],
            Ebay::Search::Api::PER_PAGE[:key] => self.per_page,
            Ebay::Search::Api::KEYWORDS[:key] => self.keywords
          }
          
          query_formatter(qargs) do |params|
            params.join("&")
          end
        end
        
        
        #### #query_formatter
        # this method builds query params from given hash
        def query_formatter(hash)
          params_str = []
          
          hash.each do |key, value|
            params_str << key.to_s + "=" + value.to_s
          end

          yield params_str
        end
        
        
        #### #validate_response
        # this method is responsible for raising proper exception if API response contents error
        # also these custom made exceptions keeps property to retry again again or not
        def validate_response(response)          
          case response.code
          when '200'  
            return
          when '400' # Bad Request error - invalid request
            raise ResponseError::BadRequestError.new(extact_error_message(response.body))
          when '401' # Unauthorised error
            raise ResponseError::UnauthorisedError.new(extact_error_message(response.body))
          when '403' # Forbidden error - valid request but server is refusing, may be due to lack of permissions (RETRY enabled)
            raise ResponseError::ForbiddenError.new(extact_error_message(response.body))
          when '404' # Not Found error - server is unable to locate the resource to serve
            raise ResponseError::NotFoundError.new(extact_error_message(response.body))
          when '500' # Internal Server error - error due to unknown reason
            raise ResponseError::InternalServerError.new(extact_error_message(response.body))
          when '502' # Bad Gateway error - error due to not receiving valid response from backend server          
            raise ResponseError::BadGatewayError.new(extact_error_message(response.body))
          when '503' # Service Unavailable error - server is overloded or under maintainance  (RETRY enabled)
            raise ResponseError::ServiceUnavailableError.new(extact_error_message(response.body))
          when '504' # Gateway Timeout error - not receiving response within the allowed time period  (RETRY enabled)
            raise ResponseError::GatewayTimeoutError.new(extact_error_message(response.body))
          else
            raise ResponseError::UnexpectedError.new(extact_error_message(response.body))
          end
        end
        
        
        #### #build_error_response_body
        # this method builds JSON response for errors / exceptions
        def build_error_response_body(message)        
          JSON.generate({
            "findItemsByKeywordsResponse": [
              {
                "ack": 'failure',
                "version": '1.0.0',
                "timestamp": Time.now.utc,
                "error_message": message,
                "searchResult": [
                  "count": 0,
                  "item": []
                ]
              }
            ]                    
          })
        end
        
      end
    end
  end
end