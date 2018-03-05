module Ebay
  module Search
    class Api
      module ResponseError
        
        #### this exceptions occures when arguments are missing or invalid
        # does not retry
        class ArgumentError < StandardError    
          attr_reader :retry
          
          def initialize(msg)
            @retry = false
            super(msg)
          end
        end
        
        
        #### this exceptions occures when server can not process the request due to an apparent client error
        # does not retry
        # Code 400
        class BadRequestError < StandardError    
          attr_reader :retry
          
          def initialize(msg)
            @retry = false
            super(msg)
          end
        end
        
        
        #### this exceptions occures when request does not have the necessary credentials
        # does not retry
        # Code: 401
        class UnauthorisedError < StandardError
          attr_reader :retry
          
          def initialize(msg)
            @retry = false
            super(msg)
          end
        end
        
        
        #### this exceptions occures when the request was valid but the server is refusing action.
        #  the user might not have necessary permission for a resource
        # does retry (Not required we might make it false in futher)
        # Code: 403
        class ForbiddenError < StandardError
          attr_reader :retry
          
          def initialize(msg)
            @retry = true
            super(msg)
          end
        end
        
        
        #### this exceptions occures when the requested resource could not be found by server.
        # does not retry 
        # Code: 404
        class NotFoundError < StandardError
          attr_reader :retry
          
          def initialize(msg)
            @retry = false
            super(msg)
          end
        end
        
        
        #### this exceptions occures when unexpected condition was encountered 
        # does not retry [FOR DEMO PURPOSE THIS IS TRUE, SHOULD BE FALSE]
        # Code: 500
        class InternalServerError < StandardError
          attr_reader :retry
          
          def initialize(msg)
            @retry = true
            super(msg)
          end
        end
        
        
        #### this exceptions occures when server was acting as a gateway or proxy and received an invalid response from the upstream server
        # does not retry
        # Code: 502
        class BadGatewayError < StandardError
          attr_reader :retry
          
          def initialize(msg)
            @retry = false
            super(msg)
          end
        end
        
                
        #### this exceptions occures when server is currently unavailable (because it is overloaded or down for maintenance)
        # does retry
        # Code: 503
        class ServiceUnavailableError < StandardError
          attr_reader :retry
          
          def initialize(msg)
            @retry = true
            super(msg)
          end
        end
        
                
        #### this exceptions occures when server was acting as a gateway or proxy and did not receive a timely response from the upstream server.
        # does retry
        # Code: 504
        class GatewayTimeoutError < StandardError
          attr_reader :retry
          
          def initialize(msg)
            @retry = true
            super(msg)
          end
        end
        
        
        # this exception occures when error is unidentical
        # does not retry
        class UnexpectedError < StandardError
          attr_reader :retry
          
          def initialize(msg)
            @retry = false
            super(msg)
          end
        end
          
      end
    end
  end
end