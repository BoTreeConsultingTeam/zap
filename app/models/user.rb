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
    self.email = auth['extra']['raw_info']['email'] if auth['extra']['raw_info']['email']
    self.password = Devise.friendly_token[0,20]
    register_omniauth(auth)
  end

  def register_omniauth(auth)
    get_screen_name(auth)
    provider = auth['provider']
    secret = auth['credentials']['secret']
    secret = auth['credentials']['refresh_token'] if(provider.to_s.include? "google_")
    attributes = {:provider => provider, :uid=>auth['uid'], 
        :token=>auth['credentials']['token'], :screen_name => @screen_name}
    if secret.present? && secret != ''
      attributes[:secret] = secret
    end
    
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

end
