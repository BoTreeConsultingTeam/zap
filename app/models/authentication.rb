class Authentication < ActiveRecord::Base
  attr_accessible :provider, :screen_name, :secret, :string, :token, :uid, :user_id, :user
  attr_accessible :instance_url

  belongs_to :user
end
