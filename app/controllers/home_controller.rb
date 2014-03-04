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

  def create_event
    sf_auth = current_user.salesforce_auth
    sfUtil = Utilities::Salesforce::SalesforceApiUtil.new
    @events = sfUtil.get_events({:token =>  sf_auth.token, :instance_url => session[:salesforce_instance_url], refresh_token: sf_auth.secret})
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
      google_auth = current_user.google_auth
      googleUtil = Utilities::Google::GoogleCalendarUtil.new({access_token: google_auth.token,
        refresh_token: google_auth.secret})
      googleUtil.create_event({'calendarId' => 'primary'}, params, {'Content-Type' => 'application/json'})
    end
    render :show_event
  end
end
