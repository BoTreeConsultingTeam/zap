module Utilities
  module Salesforce
    
    class SalesforceApiUtil < Utilities::CommonUtil

      attr_accessor :client, :service, :service_api_options

      def initialize(options={})
        @client = Databasedotcom::Client.new("config/databasedotcom.yml")
      end

      #################################
      protected
      #################################
      def execute_service_method(auth)
        @client.authenticate auth        
      end
      
    end

  end
end