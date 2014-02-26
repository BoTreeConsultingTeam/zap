class Authentication < ActiveRecord::Base
  attr_accessible :provider, :screen_name, :secret, :string, :token, :uid, :user_id, :user

  belongs_to :user
end
