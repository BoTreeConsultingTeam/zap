class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  
  def google_oauth2
    auth = request.env["omniauth.auth"]
    screen_name = auth.info.name
    session[:signed_in_with] = auth.provider
    process_callback
    session[:provider_connected] = 'google_oauth2'
    add_screen_name
  end

  def salesforce
    auth = request.env["omniauth.auth"]
    screen_name = auth.info.name
    session[:signed_in_with] = auth.provider
    process_callback
    session[:provider_connected] = 'salesforce'
    add_screen_name
  end

  private

  def process_callback
    if(!user_signed_in?)
      auth =  request.env["omniauth.auth"]
      if auth['provider'] == 'salesforce'
        email = auth.extra.email
      else
        email = auth.extra.raw_info.email 
      end
      user = User.find_by_email(email)
      sign_in :user, user if user.present?
    end

    if user_signed_in?
      add_authentication
      redirect_to root_url
    else
      process_create_user
    end
  end

  def add_authentication
    auth = request.env["omniauth.auth"]
    authentication = current_user.authentications.find_by_provider(auth.provider)
    if authentication.blank?
      current_user.register_omniauth(auth)
      current_user.save!
      flash[:notice] = "Connected to #{auth["provider"].to_s.camelize} successfully."
    else
      current_user.register_omniauth(auth)
      flash[:notice] = "#{auth['provider'].to_s.camelize} authentication successfully updated."
    end
  end

  def process_create_user
    auth = request.env["omniauth.auth"]
    authentication = Authentication.find_by_provider_and_uid(auth['provider'], auth['uid'])
    if authentication.present?
      #flash[:notice] = "Signed in successfully."
      sign_in(:user, authentication.user)
      redirect_to root_url
    else
      user = User.new
      user.apply_omniauth(auth)

      if user.save(:validate => false)
        flash[:notice] = "Account created and you have been signed in!"
        sign_in(:user, user)
        redirect_to root_url
      else
        flash[:error] = "Error while logging in! #{user.errors.full_messages.join(" and ")}"
        redirect_to root_url
      end

    end
  end

  def add_screen_name
    auth = request.env["omniauth.auth"]
    authentication = current_user.authentications.find_by_provider(auth.provider)
    if authentication.present?
     authentication.update_attribute('screen_name',auth.info.name)
    end
  end

end
