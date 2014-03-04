class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable

  # attr_accessible :title, :body

  attr_accessible :email, :password, :password_confirmation, :remember_me
  
  has_many :authentications

  def apply_omniauth(auth)
    if auth['provider'] == 'salesforce'
      self.email = auth['extra']['email'] if auth['extra']['email']
    else
      self.email = auth['extra']['raw_info']['email'] if auth['extra']['raw_info']['email']
    end
    
    self.password = Devise.friendly_token[0,20]
    register_omniauth(auth)
  end

  def register_omniauth(auth)
    get_screen_name(auth)
    provider = auth['provider']
    secret = auth['credentials']['refresh_token'] if(provider.to_s.include?("google_") || provider.to_s.include?("salesforce"))
    attributes = {:provider => provider, :uid=>auth['uid'], 
        :token=>auth['credentials']['token'], :screen_name => @screen_name}
    if secret.present? && secret != ''
      attributes[:secret] = secret
    end
    attributes[:instance_url] = auth.credentials.instance_url if provider.to_s.include?("salesforce")
    
    db_auth = self.authentications.find_by_provider(provider.to_sym)
    
    if db_auth
      db_auth.update_attributes(attributes)
    else
      authentications.build(attributes)
    end
  end

  def get_screen_name(auth)
    @screen_name = auth['info']['name']
  end

  def google_auth
    auths = authentications.where("provider = 'google_oauth2'")
    return nil unless auths.present?
    auths.first 
  end

  def salesforce_auth
    auths = authentications.where("provider = 'salesforce'")
    return nil unless auths.present?
    auths.first 
  end

  def remove_google
    self.google_auth.destroy
  end

  def remove_salesforce
    self.salesforce_auth.destroy
  end

end
