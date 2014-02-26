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
end
