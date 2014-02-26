require 'google/api_client'

module Utilities
  module Google
    
    class NoAccessTokenDefined < StandardError ; end
    class GoogleClientInitializationFailed < StandardError ; end
    class GoogleClientDiscoveryFailed < StandardError ; end
    class GoogleServiceExecutionFailed < StandardError ; end

    class GoogleApiUtil < Utilities::CommonUtil

      SCOPES = {
        calendar: 'https://www.googleapis.com/auth/calendar'
      }
      
      DEFAULT_OPTIONS = { :application_name => 'sample-app', :application_version => '1.0'}

      AUTH_OPTIONS = {
        calendar: { client_id: Settings.ga.app_key, client_secret: Settings.ga.app_secret}
      }

      SERVICE_OPTIONS = {
        calendar: { service_name: 'calendar', service_api_version: 'v3' }
      }
      DEFAULT_AUTH_OPTIONS = AUTH_OPTIONS[:calendar]

      DEFAULT_SERVICE_OPTIONS = SERVICE_OPTIONS[:calendar] 

      attr_accessor :client, :service, :service_api_options

      def initialize(options={})
        @service_api_options = options[:service_api_options] || DEFAULT_SERVICE_OPTIONS
        init_google_api_client(options)
        discover_google_service
      end

      #################################
      protected
      #################################

      def init_google_api_client(options=DEFAULT_OPTIONS)
        debug("ENTER ==> init_google_api_client")
        app_options = options[:app_options] || DEFAULT_OPTIONS
        access_token = options[:access_token]
        refresh_token = options[:refresh_token]
        auth_options = AUTH_OPTIONS[service_api_options[:service_name].to_sym] || DEFAULT_AUTH_OPTIONS
        
        if !access_token.present? || !refresh_token.present?
          raise NoAccessTokenDefined, "Access/Refresh Token is not defined! Can not create google API client!"
        end

        begin
          scope = SCOPES[service_api_options[:service_name].to_sym]
          @client = ::Google::APIClient.new(app_options)
          client.authorization.scope =  scope
          client.authorization.client_id = auth_options[:client_id]
          client.authorization.client_secret = auth_options[:client_secret]
          client.authorization.access_token = access_token
          client.authorization.refresh_token = refresh_token
          if client.authorization.refresh_token && client.authorization.expired?
            client.authorization.fetch_access_token!
          end
          debug("EXIT ==> init_google_api_client")
        rescue Exception => e
          error("init_google_api_client :: #{e.message}")
          raise GoogleClientInitializationFailed, "Can't initialize google API client : #{e.message}"
        end
      end

      def discover_google_service
        debug("ENTER ==> discover_google_service")
        
        service_name = service_api_options[:service_name]
        service_api_version = service_api_options[:service_api_version]
        
        begin
          @service = (service_api_version) ? client.discovered_api(service_name, service_api_version) : client.discovered_api(service_name)
          debug("EXIT ==> discover_google_service")
        rescue Exception => e
          error("discover_google_service :: #{e.message}")
          raise GoogleClientDiscoveryFailed, "Discovering service '#{service_name}' failed : #{e.message}"
        end
      end

      def execute_service_method(method_name, params={}, body={},headers={})
        debug("ENTER ==> execute_service_method")
        begin
          result = client.execute(:api_method => method_name, 
                                  :parameters => params, 
                                  :body_object => body, 
                                  :headers => headers
                                 )
          response_data = JSON.parse(result.response.body)
          # raise GoogleServiceExecutionFailed "#{response_data['error']}" if response_data['error']
          debug("EXIT ==> execute_service_method")
          response_data
        rescue Exception => e
          error("execute_service_method :: #{e.message}")
          raise GoogleServiceExecutionFailed, "Google service execution for service '#{service_api_options[:service_name]}' has been failed for method '#{method_name}' : #{e.message}"
        end
      end
      
    end

  end
end