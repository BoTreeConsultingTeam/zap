module Utilities
  module Google
    
    class GoogleCalendarUtil < Utilities::Google::GoogleApiUtil

      def create_event(params, body, headers)
        execute_service_method(service.events.insert, params, body, headers)
      end

    end
  end
end