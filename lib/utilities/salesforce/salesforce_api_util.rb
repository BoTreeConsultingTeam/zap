module Utilities
  module Salesforce

    class SalesforceApiUtil < Utilities::CommonUtil

      attr_accessor :client, :service, :service_api_options

      def initialize(options={})
        @client = Databasedotcom::Client.new("config/databasedotcom.yml")
      end

      def get_events(options = {})
        authenticate(options)
        client.materialize("Event")
        events = Event.all
      end

      def create_event(options = {}, data)
        authenticate(options)
        client.create("Event", data)
      end

      def authenticate(options)
        client.authenticate({:token => options[:token], :instance_url => options[:instance_url],
                            :refresh_token => options[:refresh_token]})
      end

    end

  end
end