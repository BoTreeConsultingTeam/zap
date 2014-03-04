module Utilities
  module Salesforce
    
    class SalesforceApiUtil < Utilities::CommonUtil

      attr_accessor :client, :service, :service_api_options

      def initialize(options={})
        @client = Databasedotcom::Client.new("config/databasedotcom.yml")
      end

      def get_events(options = {})
        client.authenticate({:token => options[:token], :instance_url => options[:instance_url],
                            :refresh_token => options[:refresh_token]})
        client.materialize("Event")
        events = Event.all
      end
      
    end

  end
end