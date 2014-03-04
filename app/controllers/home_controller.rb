class HomeController < ApplicationController
  def index
  end

  def disconnect_google
    current_user.remove_google
    redirect_to root_url and return
  end

  def disconnect_salesforce
    current_user.remove_salesforce
    redirect_to root_url and return
  end

  def show_event
    sfUtil = Utilities::Salesforce::SalesforceApiUtil.new
    @events = sfUtil.get_events({:token => session[:salesforce_auth_token], 
      :instance_url => session[:salesforce_instance_url],
      :refresh_token => session[:salesforce_refresh_token]})
  end

  def create_event
    sfUtil = Utilities::Salesforce::SalesforceApiUtil.new
    @events = sfUtil.get_events({:token => session[:auth_token], :instance_url => session[:instance_url]})
    @events.each do |event|
      params = {
        'summary' => event["Subject"],
        'location' => event["Location"],
        'start' => {
          'dateTime' => event["StartDateTime"]
        },
        'end' => {
          'dateTime' => event["EndDateTime"]
        }
      }
      googleUtil = Utilities::Google::GoogleCalendarUtil.new({access_token: session[:google_auth_token],
        refresh_token: session[:google_refresh_token]})
      googleUtil.create_event({'calendarId' => 'primary'}, JSON.dump(params), {'Content-Type' => 'application/json'})
    end
    
  end
end
